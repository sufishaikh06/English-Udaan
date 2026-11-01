/**
 * ai-provider.js — provider-neutral AI dictionary lookup service.
 *
 * Supported providers (set via AI_PROVIDER env var):
 *   'openai'  — OpenAI Chat Completions API (gpt-4o-mini by default)
 *   'google'  — Google Gemini API (gemini-1.5-flash by default)
 *
 * The AI key is NEVER passed to the Flutter client or logged.
 *
 * Changing the provider requires only updating AI_PROVIDER + AI_API_KEY
 * in the server .env — no Flutter or client changes are needed.
 *
 * Required environment variables (set in backend/.env):
 *   AI_PROVIDER  — 'openai' | 'google'  (default: 'openai')
 *   AI_API_KEY   — Provider API key (secret — never commit)
 *   AI_MODEL     — Override model name (optional)
 *
 * callAiProvider throws:
 *   { code: 'AI_UNAVAILABLE', message }       — network / auth failure
 *   { code: 'AI_INVALID_RESPONSE', message }  — response did not parse
 */

const https = require('https');

const AI_REQUEST_TIMEOUT_MS = 15_000;

// ── Prompt builder ────────────────────────────────────────────────────────────

function buildSystemPrompt() {
  return `You are a bilingual Urdu-English dictionary assistant.
When given a word or phrase, reply with a single JSON object (no markdown, no code fences) in exactly this shape:

{
  "englishWord": "<canonical English word or phrase>",
  "urduMeaning": "<primary Urdu meaning>",
  "simpleDefinition": "<one simple English sentence explanation>",
  "partOfSpeech": "<noun | verb | adjective | adverb | other>",
  "examples": [
    { "english": "<example sentence 1>", "urdu": "<Urdu translation 1>" },
    { "english": "<example sentence 2>", "urdu": "<Urdu translation 2>" }
  ],
  "pronunciationText": "<word to speak via TTS, usually the English word>"
}

Rules:
- Provide exactly 2 examples.
- Keep simpleDefinition under 25 words.
- Use natural, correct Urdu — not transliterations.
- Do not add any field not listed above.
- Do not wrap the JSON in markdown.`;
}

function buildUserPrompt(query, sourceLanguage, targetLanguage) {
  if (sourceLanguage === 'ur') {
    return `Look up the Urdu word or phrase: ${query}`;
  }
  return `Look up the English word or phrase: ${query}`;
}

// ── Response validator ────────────────────────────────────────────────────────

function validateAiResponse(data, query, sourceLanguage) {
  if (typeof data !== 'object' || data === null) {
    throw aiError('AI_INVALID_RESPONSE', 'Response is not an object.');
  }
  const required = ['englishWord', 'urduMeaning', 'simpleDefinition', 'partOfSpeech', 'examples'];
  for (const field of required) {
    if (!data[field]) {
      throw aiError('AI_INVALID_RESPONSE', `Missing field: ${field}`);
    }
  }
  if (!Array.isArray(data.examples) || data.examples.length === 0) {
    throw aiError('AI_INVALID_RESPONSE', 'examples must be a non-empty array.');
  }
  for (const ex of data.examples) {
    if (!ex.english || !ex.urdu) {
      throw aiError('AI_INVALID_RESPONSE', 'Each example must have english and urdu strings.');
    }
  }
  return {
    query,
    source: 'ai',
    englishWord: String(data.englishWord).trim(),
    urduMeaning: String(data.urduMeaning).trim(),
    simpleDefinition: String(data.simpleDefinition).trim(),
    partOfSpeech: String(data.partOfSpeech).trim(),
    examples: data.examples.slice(0, 2).map((ex) => ({
      english: String(ex.english).trim(),
      urdu: String(ex.urdu).trim(),
    })),
    pronunciationText: data.pronunciationText
      ? String(data.pronunciationText).trim()
      : String(data.englishWord).trim(),
  };
}

function aiError(code, message) {
  const error = new Error(message);
  error.code = code;
  return error;
}

function classifyProviderFailure(provider, status, body) {
  let detail = '';
  try {
    const parsed = JSON.parse(body);
    detail = parsed?.error?.message || parsed?.error?.status || '';
  } catch (_) {
    detail = '';
  }
  const suffix = detail ? ` ${detail}` : '';
  if (status === 401 || status === 403) {
    return aiError('AI_INVALID_KEY', `${provider} rejected the API key.${suffix}`);
  }
  if (status === 429) {
    return aiError('AI_QUOTA_EXCEEDED', `${provider} rate limit or quota exceeded.${suffix}`);
  }
  if (status === 404) {
    return aiError('AI_UNSUPPORTED_MODEL', `${provider} model was not found or is unsupported.${suffix}`);
  }
  return aiError('AI_UNAVAILABLE', `${provider} returned HTTP ${status}.${suffix}`);
}

// ── HTTP helper ───────────────────────────────────────────────────────────────

function httpsPost(url, { headers, body }) {
  return new Promise((resolve, reject) => {
    const parsed = new URL(url);
    const options = {
      hostname: parsed.hostname,
      path: parsed.pathname + parsed.search,
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...headers },
    };
    const req = https.request(options, (res) => {
      let raw = '';
      res.on('data', (chunk) => (raw += chunk));
      res.on('end', () => resolve({ status: res.statusCode, body: raw }));
    });
    req.on('error', reject);
    req.setTimeout(AI_REQUEST_TIMEOUT_MS, () => {
      req.destroy(new Error('AI provider request timed out'));
    });
    req.write(body);
    req.end();
  });
}

// ── OpenAI ────────────────────────────────────────────────────────────────────

async function callOpenAi({ query, sourceLanguage, targetLanguage, apiKey, model }) {
  const resolvedModel = model || 'gpt-4o-mini';
  const requestBody = JSON.stringify({
    model: resolvedModel,
    messages: [
      { role: 'system', content: buildSystemPrompt() },
      { role: 'user', content: buildUserPrompt(query, sourceLanguage, targetLanguage) },
    ],
    max_tokens: 500,
    temperature: 0.2,
  });

  let res;
  try {
    res = await httpsPost('https://api.openai.com/v1/chat/completions', {
      headers: { Authorization: `Bearer ${apiKey}` },
      body: requestBody,
    });
  } catch (err) {
    throw aiError('AI_UNAVAILABLE', `OpenAI network error: ${err.message}`);
  }

  if (res.status !== 200) throw classifyProviderFailure('OpenAI', res.status, res.body);

  let parsed;
  try {
    parsed = JSON.parse(res.body);
  } catch {
    throw aiError('AI_INVALID_RESPONSE', 'Could not parse OpenAI response as JSON.');
  }

  const content = parsed?.choices?.[0]?.message?.content;
  if (!content) throw aiError('AI_INVALID_RESPONSE', 'OpenAI response missing content.');

  let data;
  try {
    // Strip markdown code fences if the model wrapped the JSON anyway.
    const cleaned = content.replace(/```json?|```/g, '').trim();
    data = JSON.parse(cleaned);
  } catch {
    throw aiError('AI_INVALID_RESPONSE', `Could not parse AI content as JSON: ${content.slice(0, 200)}`);
  }

  return validateAiResponse(data, query, sourceLanguage);
}

// ── Google Gemini ─────────────────────────────────────────────────────────────

async function callGoogle({ query, sourceLanguage, targetLanguage, apiKey, model }) {
  // Gemini API model names evolve; this model is currently recommended by the
  // configured API for generateContent when AI_MODEL is omitted.
  const resolvedModel = model || 'gemini-3.8-flash';
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${resolvedModel}:generateContent?key=${apiKey}`;

  const requestBody = JSON.stringify({
    systemInstruction: { parts: [{ text: buildSystemPrompt() }] },
    contents: [
      { role: 'user', parts: [{ text: buildUserPrompt(query, sourceLanguage, targetLanguage) }] },
    ],
    generationConfig: { maxOutputTokens: 500, temperature: 0.2 },
  });

  let res;
  try {
    res = await httpsPost(url, { body: requestBody });
  } catch (err) {
    throw aiError('AI_UNAVAILABLE', `Google AI network error: ${err.message}`);
  }

  if (res.status !== 200) throw classifyProviderFailure('Google Gemini', res.status, res.body);

  let parsed;
  try {
    parsed = JSON.parse(res.body);
  } catch {
    throw aiError('AI_INVALID_RESPONSE', 'Could not parse Google AI response.');
  }

  const content = parsed?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!content) throw aiError('AI_INVALID_RESPONSE', 'Google AI response missing content.');

  let data;
  try {
    const cleaned = content.replace(/```json?|```/g, '').trim();
    data = JSON.parse(cleaned);
  } catch {
    throw aiError('AI_INVALID_RESPONSE', `Could not parse AI content as JSON: ${content.slice(0, 200)}`);
  }

  return validateAiResponse(data, query, sourceLanguage);
}

// ── Public API ────────────────────────────────────────────────────────────────

/**
 * Call the configured AI provider.
 *
 * @param {{ query, sourceLanguage, targetLanguage, apiKey, model, provider }} options
 * @returns {Promise<object>} validated dictionary result
 */
async function callAiProvider({ query, sourceLanguage, targetLanguage, apiKey, model, provider }) {
  const resolvedProvider = (provider || process.env.AI_PROVIDER || 'openai').toLowerCase();

  switch (resolvedProvider) {
    case 'openai':
      return callOpenAi({ query, sourceLanguage, targetLanguage, apiKey, model });
    case 'google':
      return callGoogle({ query, sourceLanguage, targetLanguage, apiKey, model });
    default:
      throw aiError('AI_UNAVAILABLE', `Unknown AI provider: "${resolvedProvider}". Supported: openai, google.`);
  }
}

module.exports = { callAiProvider, validateAiResponse };
