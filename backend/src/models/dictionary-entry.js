/**
 * Mongoose model for curated dictionary entries.
 *
 * Each document represents one English word (or phrase) with its Urdu
 * meaning and optional metadata. The schema is intentionally simple and
 * forward-compatible with a future MongoDB Atlas back-end.
 *
 * Index strategy:
 *  - `englishWord`  — case-insensitive unique lookup by English form.
 *  - `urduWord`     — full-text / exact lookup by Urdu form.
 *  - `searchIndex`  — lowercase normalised copy of both words for fast prefix
 *                     matching without a full-text index.
 */

const { Schema, model } = require('mongoose');

const exampleSchema = new Schema(
  {
    english: { type: String, required: true, trim: true },
    urdu: { type: String, required: true, trim: true },
  },
  { _id: false },
);

const dictionaryEntrySchema = new Schema(
  {
    /** Canonical English word or short phrase, e.g. "apple". */
    englishWord: {
      type: String,
      required: true,
      trim: true,
      index: { unique: false }, // uniqueness enforced via collation index below
    },

    /** Primary Urdu meaning, e.g. "سیب". */
    urduMeaning: { type: String, required: true, trim: true },

    /** Urdu word / phrase used as the search key for Urdu→English lookups. */
    urduWord: { type: String, required: false, trim: true },

    /** Beginner-friendly English explanation. */
    simpleDefinition: { type: String, required: false, trim: true },

    /** Grammatical category: noun, verb, adjective … */
    partOfSpeech: { type: String, required: false, trim: true },

    /** Up to 2 example sentence pairs. */
    examples: { type: [exampleSchema], default: [] },

    /**
     * Lower-cased concatenation of englishWord + urduMeaning used for
     * lightweight prefix/contains searches without a full-text index.
     */
    searchIndex: { type: String, required: false, index: true },
  },
  {
    timestamps: true,
    collection: 'dictionary_entries',
  },
);

// Case-insensitive unique index on the English word.
dictionaryEntrySchema.index(
  { englishWord: 1 },
  { unique: true, collation: { locale: 'en', strength: 2 } },
);

// Sparse index for Urdu word lookups.
dictionaryEntrySchema.index({ urduWord: 1 }, { sparse: true });

// Pre-save hook — populate the searchIndex automatically.
dictionaryEntrySchema.pre('save', function () {
  this.searchIndex = [
    (this.englishWord || '').toLowerCase(),
    (this.urduMeaning || '').toLowerCase(),
    (this.urduWord || '').toLowerCase(),
  ]
    .filter(Boolean)
    .join(' ');
});

const DictionaryEntry = model('DictionaryEntry', dictionaryEntrySchema);

module.exports = { DictionaryEntry };
