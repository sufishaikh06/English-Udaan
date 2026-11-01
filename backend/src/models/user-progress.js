const mongoose = require('mongoose');

const VALID_SECTIONS = [
  'alphabet',
  'vocabulary-two-letter',
  'vocabulary-three-letter',
  'vocabulary-four-letter',
  'vocabulary-five-letter',
  'picture-fruits',
  'picture-vegetables',
  'picture-domestic-animals',
  'picture-wild-animals',
  'picture-birds',
  'picture-vehicles',
  'picture-body-parts',
  'picture-indoor',
  'picture-outdoor',
  'sentences',
  'grammar',
];

const sectionProgressSchema = new mongoose.Schema(
  {
    section: {
      type: String,
      enum: VALID_SECTIONS,
      required: true,
    },
    completed: {
      type: Boolean,
      default: false,
    },
    completedAt: {
      type: Date,
    },
  },
  { _id: false },
);

const quizResultSchema = new mongoose.Schema(
  {
    category: {
      type: String,
      required: true,
      trim: true,
    },
    score: {
      type: Number,
      required: true,
      min: 0,
    },
    total: {
      type: Number,
      required: true,
      min: 1,
    },
    playedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { _id: false },
);

/**
 * UserProgress schema — Phase 15 update.
 *
 * `firebaseUid` is now the primary ownership key (unique per user, set from
 * the verified Firebase UID — never from client-supplied request body).
 *
 * `deviceId` is retained as an optional field for backward compatibility with
 * Phase 14 data. It is NOT used for authorization decisions.
 *
 * Conflict / merge semantics:
 *  - PUT /api/progress overwrites the server document with the client payload.
 *    A blind overwrite is intentional for Phase 15; Phase 16 will implement
 *    a safer merge strategy with `updatedAt` timestamps on individual fields.
 *  - The server never trusts a UID from the request body; it always uses the
 *    verified UID attached by the auth middleware.
 */
const userProgressSchema = new mongoose.Schema(
  {
    // Primary ownership key — always set from the verified Firebase UID.
    firebaseUid: {
      type: String,
      required: true,
      trim: true,
      index: { unique: true },
    },
    // Retained for Phase 14 backward compatibility; not used for authorization.
    deviceId: {
      type: String,
      trim: true,
    },
    sections: {
      type: [sectionProgressSchema],
      default: [],
      // Limit to avoid unbounded growth; one entry per valid section at most.
      validate: {
        validator(arr) {
          if (arr.length > VALID_SECTIONS.length) return false;
          const names = arr.map((s) => s.section);
          return new Set(names).size === names.length;
        },
        message: 'sections must contain unique section names and cannot exceed the number of valid sections.',
      },
    },
    quizResults: {
      type: [quizResultSchema],
      default: [],
      validate: {
        validator(arr) {
          return arr.length <= 500;
        },
        message: 'quizResults cannot exceed 500 entries.',
      },
    },
    currentStreak: {
      type: Number,
      default: 0,
      min: 0,
    },
    longestStreak: {
      type: Number,
      default: 0,
      min: 0,
    },
    lastActivityDate: {
      type: Date,
    },
  },
  {
    timestamps: true,
    collection: 'user_progress',
  },
);

// Guard against duplicate model registration in test environments.
const UserProgress =
  mongoose.models.UserProgress || mongoose.model('UserProgress', userProgressSchema);

module.exports = { UserProgress, VALID_SECTIONS };
