/**
 * Dictionary route — POST /api/dictionary/lookup
 *
 * This endpoint is intentionally PUBLIC (no Firebase auth required) so that
 * learners without an account can also use the dictionary.
 *
 * Algorithm:
 *  1. Validate the request (query length, language codes).
 *  2. Search the curated MongoDB database first.
 *     - For English queries: case-insensitive match on englishWord.
 *     - For Urdu queries: case-insensitive match on urduWord / urduMeaning.
 *  3. If a database entry is found, return it immediately (no AI call).
 *  4. If NO database entry is found AND an AI provider key is configured,
 *     call the provider, validate the response, and return it.
 *  5. If NO database entry AND NO AI key, return 404 with a clear message.
 *
 * AI provider interface (provider-neutral):
 *  - Read AI_PROVIDER, AI_API_KEY, AI_MODEL from environment.
 *  - Provider IDs: 'openai' | 'google' (Gemini)
 *  - Changing the provider requires only an .env change — no Flutter change.
 *
 * Security:
 *  - Request body is validated with length limits.
 *  - AI keys are never returned to the client.
 *  - All AI responses are validated before forwarding.
 *  - Rate limiting is applied at the app level (authRateLimiter in app.js).
 */

const { Router } = require('express');
const { z } = require('zod');
const { DictionaryEntry } = require('../models/dictionary-entry');
const { callAiProvider } = require('../services/ai-provider');

// ── Request schema ────────────────────────────────────────────────────────────

const lookupSchema = z.object({
  query: z
    .string()
    .trim()
    .min(1, 'query must not be empty')
    .max(100, 'query must not exceed 100 characters'),
  sourceLanguage: z.enum(['ur', 'en']).default('ur'),
  targetLanguage: z.enum(['ur', 'en']).default('en'),
});

// ── Database search ───────────────────────────────────────────────────────────

/**
 * Search the curated database for a matching entry.
 * @param {string} query
 * @param {'ur'|'en'} sourceLanguage
 * @returns {Promise<object|null>}
 */
async function searchDatabase(query, sourceLanguage) {
  const normalised = query.trim().toLowerCase();

  if (sourceLanguage === 'en') {
    // English → search englishWord case-insensitively.
    return DictionaryEntry.findOne({ englishWord: new RegExp(`^${escapeRegex(normalised)}$`, 'i') })
      .lean()
      .exec();
  }

  // Urdu → search urduWord or urduMeaning.
  return DictionaryEntry.findOne({
    $or: [
      { urduWord: query.trim() },
      { urduMeaning: new RegExp(escapeRegex(query.trim())) },
    ],
  })
    .lean()
    .exec();
}

function escapeRegex(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// ── Result formatters ─────────────────────────────────────────────────────────

function formatDatabaseResult(entry, query) {
  return {
    query,
    source: 'database',
    englishWord: entry.englishWord,
    urduMeaning: entry.urduMeaning,
    simpleDefinition: entry.simpleDefinition || '',
    partOfSpeech: entry.partOfSpeech || '',
    examples: (entry.examples || []).map((ex) => ({
      english: ex.english,
      urdu: ex.urdu,
    })),
    pronunciationText: entry.englishWord,
  };
}

// ── Router factory ────────────────────────────────────────────────────────────

function createDictionaryRouter({ environment = {} } = {}) {
  const router = Router();

  /**
   * POST /api/dictionary/lookup
   *
   * Body: { query, sourceLanguage?, targetLanguage? }
   * Returns: { success: true, data: DictionaryResult }
   */
  router.post('/lookup', async (req, res, next) => {
    // 1. Validate input.
    const parsed = lookupSchema.safeParse(req.body);
    if (!parsed.success) {
      const message = parsed.error.issues.map((i) => i.message).join('; ');
      return res.status(400).json({
        success: false,
        error: { code: 'INVALID_REQUEST', message },
      });
    }

    const { query, sourceLanguage, targetLanguage } = parsed.data;

    try {
      // 2. Search the database first.
      const dbEntry = await searchDatabase(query, sourceLanguage);

      if (dbEntry) {
        console.info(`[dictionary] DB hit: "${query}" (${sourceLanguage}→${targetLanguage})`);
        return res.status(200).json({
          success: true,
          data: formatDatabaseResult(dbEntry, query),
        });
      }

      // 3. No database entry — try AI provider.
      // Use the same validated configuration that bootstrapped the app. Do
      // not read process.env here: doing so can diverge from dotenv/Zod config.
      const aiKey = environment.AI_API_KEY;
      if (!aiKey) {
        console.info(`[dictionary] DB miss, no AI key configured: "${query}"`);
        return res.status(404).json({
          success: false,
          error: {
            code: 'NOT_FOUND',
            message: `"${query}" was not found in the dictionary. Live AI lookup is not currently configured.`,
          },
        });
      }

      console.info(`[dictionary] DB miss, calling AI: "${query}" (${sourceLanguage}→${targetLanguage})`);
      const aiResult = await callAiProvider({
        query,
        sourceLanguage,
        targetLanguage,
        apiKey: aiKey,
        model: environment.AI_MODEL,
        provider: environment.AI_PROVIDER || 'openai',
      });

      return res.status(200).json({ success: true, data: aiResult });
    } catch (error) {
      // Surface known AI errors as 503 so the client can handle gracefully.
      if (error.code === 'AI_UNAVAILABLE') {
        console.warn(`[dictionary] AI provider unavailable: ${error.message}`);
        return res.status(503).json({
          success: false,
          error: {
            code: 'AI_UNAVAILABLE',
            message: 'The AI lookup service is temporarily unavailable. Database results still work.',
          },
        });
      }
      if (['AI_INVALID_KEY', 'AI_QUOTA_EXCEEDED', 'AI_UNSUPPORTED_MODEL'].includes(error.code)) {
        console.warn(`[dictionary] AI provider configuration error: ${error.code}`);
        return res.status(error.code === 'AI_QUOTA_EXCEEDED' ? 429 : 502).json({
          success: false,
          error: {
            code: error.code,
            message: error.code === 'AI_INVALID_KEY'
              ? 'The configured AI API key was rejected.'
              : error.code === 'AI_QUOTA_EXCEEDED'
                ? 'The configured AI provider quota or rate limit was exceeded.'
                : 'The configured AI model is unavailable.',
          },
        });
      }
      if (error.code === 'AI_INVALID_RESPONSE') {
        console.warn(`[dictionary] AI returned invalid response: ${error.message}`);
        return res.status(502).json({
          success: false,
          error: {
            code: 'AI_INVALID_RESPONSE',
            message: 'The AI returned an unusable response. Please try again.',
          },
        });
      }
      next(error);
    }
  });

  return router;
}

module.exports = { createDictionaryRouter };
