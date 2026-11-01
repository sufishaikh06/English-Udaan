/**
 * Cloud progress routes — protected by Firebase auth middleware.
 *
 * GET  /api/progress      — read the authenticated user's cloud progress.
 * PUT  /api/progress      — write (overwrite) the authenticated user's cloud progress.
 *
 * Ownership: the Firebase UID from the verified token is ALWAYS used as the
 * ownership key. UIDs supplied in the request body or URL are ignored for
 * authorization, preventing one account from reading or writing another's data.
 *
 * Conflict / merge semantics (Phase 15):
 *   PUT performs a full overwrite of the server document with the validated
 *   client payload.  Phase 16 will introduce field-level merge with optimistic
 *   concurrency.  The current behaviour is documented deliberately, not by
 *   oversight.
 */

const { Router } = require('express');
const { UserProgress, VALID_SECTIONS } = require('../models/user-progress');

// ---------------------------------------------------------------------------
// Input validation helpers
// ---------------------------------------------------------------------------

/**
 * Validate a single section-progress entry.
 * @param {unknown} entry
 * @returns {{ valid: boolean, error?: string }}
 */
function validateSectionEntry(entry) {
  if (typeof entry !== 'object' || entry === null) {
    return { valid: false, error: 'Each section entry must be an object.' };
  }
  if (!VALID_SECTIONS.includes(entry.section)) {
    return { valid: false, error: `Unknown section: "${entry.section}".` };
  }
  if (typeof entry.completed !== 'boolean') {
    return { valid: false, error: `"completed" must be a boolean for section "${entry.section}".` };
  }
  if (entry.completedAt !== undefined && entry.completedAt !== null) {
    const d = new Date(entry.completedAt);
    if (isNaN(d.getTime())) {
      return { valid: false, error: `"completedAt" is not a valid date for section "${entry.section}".` };
    }
  }
  return { valid: true };
}

/**
 * Validate a single quiz-result entry.
 * @param {unknown} entry
 * @param {number} index
 * @returns {{ valid: boolean, error?: string }}
 */
function validateQuizResultEntry(entry, index) {
  if (typeof entry !== 'object' || entry === null) {
    return { valid: false, error: `quizResults[${index}] must be an object.` };
  }
  if (typeof entry.category !== 'string' || entry.category.trim().length === 0) {
    return { valid: false, error: `quizResults[${index}].category must be a non-empty string.` };
  }
  if (typeof entry.score !== 'number' || !Number.isInteger(entry.score) || entry.score < 0) {
    return { valid: false, error: `quizResults[${index}].score must be a non-negative integer.` };
  }
  if (typeof entry.total !== 'number' || !Number.isInteger(entry.total) || entry.total < 1) {
    return { valid: false, error: `quizResults[${index}].total must be a positive integer.` };
  }
  if (entry.score > entry.total) {
    return { valid: false, error: `quizResults[${index}].score cannot exceed total.` };
  }
  return { valid: true };
}

/**
 * Validate the full progress payload from the client.
 * Returns { valid: true, data } or { valid: false, error }.
 *
 * @param {unknown} body
 * @returns {{ valid: boolean, error?: string, data?: object }}
 */
function validateProgressPayload(body) {
  if (typeof body !== 'object' || body === null) {
    return { valid: false, error: 'Request body must be a JSON object.' };
  }

  // --- sections ---
  const sections = body.sections ?? [];
  if (!Array.isArray(sections)) {
    return { valid: false, error: '"sections" must be an array.' };
  }
  if (sections.length > VALID_SECTIONS.length) {
    return { valid: false, error: `"sections" cannot contain more than ${VALID_SECTIONS.length} entries.` };
  }
  const sectionNames = new Set();
  for (const entry of sections) {
    const result = validateSectionEntry(entry);
    if (!result.valid) return { valid: false, error: result.error };
    if (sectionNames.has(entry.section)) {
      return { valid: false, error: `Duplicate section "${entry.section}" in sections array.` };
    }
    sectionNames.add(entry.section);
  }

  // --- quizResults ---
  const quizResults = body.quizResults ?? [];
  if (!Array.isArray(quizResults)) {
    return { valid: false, error: '"quizResults" must be an array.' };
  }
  if (quizResults.length > 500) {
    return { valid: false, error: '"quizResults" cannot exceed 500 entries.' };
  }
  for (let i = 0; i < quizResults.length; i++) {
    const result = validateQuizResultEntry(quizResults[i], i);
    if (!result.valid) return { valid: false, error: result.error };
  }

  // --- streaks ---
  const currentStreak = body.currentStreak ?? 0;
  const longestStreak = body.longestStreak ?? 0;
  if (!Number.isInteger(currentStreak) || currentStreak < 0) {
    return { valid: false, error: '"currentStreak" must be a non-negative integer.' };
  }
  if (!Number.isInteger(longestStreak) || longestStreak < 0) {
    return { valid: false, error: '"longestStreak" must be a non-negative integer.' };
  }

  // --- lastActivityDate ---
  let lastActivityDate;
  if (body.lastActivityDate !== undefined && body.lastActivityDate !== null) {
    const d = new Date(body.lastActivityDate);
    if (isNaN(d.getTime())) {
      return { valid: false, error: '"lastActivityDate" is not a valid date.' };
    }
    lastActivityDate = d;
  }

  return {
    valid: true,
    data: {
      sections: sections.map((s) => ({
        section: s.section,
        completed: s.completed,
        completedAt: s.completedAt ? new Date(s.completedAt) : undefined,
      })),
      quizResults: quizResults.map((q) => ({
        category: q.category.trim(),
        score: q.score,
        total: q.total,
        playedAt: q.playedAt ? new Date(q.playedAt) : new Date(),
      })),
      currentStreak,
      longestStreak,
      lastActivityDate,
    },
  };
}

// ---------------------------------------------------------------------------
// Router factory
// ---------------------------------------------------------------------------

function createProgressRouter({ authMiddleware }) {
  const router = Router();

  /**
   * GET /api/progress
   * Returns the cloud progress document for the authenticated user.
   * Creates an empty document when none exists yet.
   */
  router.get('/', authMiddleware, async (req, res, next) => {
    try {
      const uid = req.uid;
      const requestId = req.headers['x-progress-request-id'] || 'none';
      let doc = await UserProgress.findOne({ firebaseUid: uid }).lean();

      if (!doc) {
        // Return an empty progress structure — do not create a DB record yet.
        console.info(`[progress][${requestId}] GET uid_suffix=${uid.slice(-6)} sections=0 quizzes=0 -> 200 (empty)`);
        return res.status(200).json({
          success: true,
          data: {
            firebaseUid: uid,
            sections: [],
            quizResults: [],
            currentStreak: 0,
            longestStreak: 0,
            lastActivityDate: null,
          },
        });
      }

      console.info(`[progress][${requestId}] GET uid_suffix=${uid.slice(-6)} sections=${doc.sections.length} quizzes=${doc.quizResults.length} -> 200`);
      return res.status(200).json({
        success: true,
        data: {
          firebaseUid: uid,
          sections: doc.sections,
          quizResults: doc.quizResults,
          currentStreak: doc.currentStreak,
          longestStreak: doc.longestStreak,
          lastActivityDate: doc.lastActivityDate ?? null,
          updatedAt: doc.updatedAt,
        },
      });
    } catch (error) {
      next(error);
    }
  });

  /**
   * PUT /api/progress
   * Overwrites the cloud progress for the authenticated user.
   *
   * The request body must be a JSON object with:
   *   - sections: array of { section, completed, completedAt? }
   *   - quizResults: array of { category, score, total, playedAt? }
   *   - currentStreak: non-negative integer
   *   - longestStreak: non-negative integer
   *   - lastActivityDate?: ISO date string or null
   *
   * The UID is ALWAYS taken from the verified token — not from the request body.
   */
  router.put('/', authMiddleware, async (req, res, next) => {
    try {
      const uid = req.uid;
      const requestId = req.headers['x-progress-request-id'] || 'none';
      console.info(`[progress][${requestId}] PUT uid_suffix=${uid.slice(-6)} fields=${Object.keys(req.body || {}).join(',')} sections=${Array.isArray(req.body?.sections) ? req.body.sections.length : 0} quizzes=${Array.isArray(req.body?.quizResults) ? req.body.quizResults.length : 0}`);

      const validation = validateProgressPayload(req.body);
      if (!validation.valid) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'INVALID_PROGRESS_PAYLOAD',
            message: validation.error,
          },
        });
      }

      const { data } = validation;

      // Merge with the existing account document. A stale/incomplete client
      // snapshot must not erase sections or stronger quiz results.
      const existing = await UserProgress.findOne({ firebaseUid: uid }).lean();
      const sectionsByName = new Map((existing?.sections ?? []).map((s) => [s.section, s]));
      for (const section of data.sections) {
        const previous = sectionsByName.get(section.section);
        sectionsByName.set(section.section, {
          section: section.section,
          completed: Boolean(previous?.completed || section.completed),
          completedAt: previous?.completedAt ?? section.completedAt,
        });
      }
      const quizzesByCategory = new Map((existing?.quizResults ?? []).map((q) => [q.category, q]));
      for (const quiz of data.quizResults) {
        const previous = quizzesByCategory.get(quiz.category);
        if (!previous || quiz.score > previous.score ||
            (quiz.score === previous.score && quiz.total >= previous.total)) {
          quizzesByCategory.set(quiz.category, quiz);
        }
      }
      const latestActivity = [existing?.lastActivityDate, data.lastActivityDate]
        .filter(Boolean)
        .sort((a, b) => b - a)[0];
      const doc = await UserProgress.findOneAndUpdate(
        { firebaseUid: uid },
        {
          $set: {
            firebaseUid: uid, // always enforce ownership key
            sections: [...sectionsByName.values()],
            quizResults: [...quizzesByCategory.values()],
            currentStreak: Math.max(existing?.currentStreak ?? 0, data.currentStreak),
            longestStreak: Math.max(existing?.longestStreak ?? 0, data.longestStreak),
            lastActivityDate: latestActivity,
          },
        },
        { upsert: true, new: true, runValidators: true },
      );

      console.info(`[progress][${requestId}] PUT persisted sections=${doc.sections.length} quizzes=${doc.quizResults.length} -> 200`);
      return res.status(200).json({
        success: true,
        data: {
          firebaseUid: uid,
          sections: doc.sections,
          quizResults: doc.quizResults,
          currentStreak: doc.currentStreak,
          longestStreak: doc.longestStreak,
          lastActivityDate: doc.lastActivityDate ?? null,
          updatedAt: doc.updatedAt,
        },
      });
    } catch (error) {
      // Surface Mongoose validation errors with a 400 instead of a 500.
      if (error.name === 'ValidationError') {
        return res.status(400).json({
          success: false,
          error: {
            code: 'INVALID_PROGRESS_PAYLOAD',
            message: error.message,
          },
        });
      }
      next(error);
    }
  });

  return router;
}

module.exports = { createProgressRouter, validateProgressPayload, validateSectionEntry, validateQuizResultEntry };
