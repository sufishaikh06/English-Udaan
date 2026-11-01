/**
 * seed-dictionary.js — repeatable seed script for `dictionary_entries`.
 *
 * Usage:
 *   node backend/seed-dictionary.js
 *
 * Environment variables required:
 *   MONGODB_URI      — MongoDB connection string
 * 
 *   MONGODB_DATABASE — database name (default: test)
 *
 * The script uses upsert so it is safe to run multiple times.
 * Existing entries are updated; new entries are inserted.
 */

require('dotenv').config({ path: require('path').join(__dirname, '.env') });

const mongoose = require('mongoose');
const { Schema, model } = mongoose;

// ── Inline minimal schema (avoids importing the full app) ─────────────────────
const exSchema = new Schema({ english: String, urdu: String }, { _id: false });
const entrySchema = new Schema(
  {
    englishWord: { type: String, required: true },
    urduMeaning: { type: String, required: true },
    urduWord: String,
    simpleDefinition: String,
    partOfSpeech: String,
    examples: { type: [exSchema], default: [] },
    searchIndex: String,
  },
  { collection: 'dictionary_entries', timestamps: true },
);
entrySchema.index({ englishWord: 1 }, { unique: true, collation: { locale: 'en', strength: 2 } });
entrySchema.pre('save', function () {
  this.searchIndex = [this.englishWord, this.urduMeaning, this.urduWord || '']
    .map((s) => (s || '').toLowerCase())
    .filter(Boolean)
    .join(' ');
});
const Entry = model('DictionaryEntry', entrySchema);

// ── Seed data ─────────────────────────────────────────────────────────────────
const SEED = [
  {
    englishWord: 'apple',
    urduWord: 'سیب',
    urduMeaning: 'سیب',
    simpleDefinition: 'A round fruit that is usually red, green, or yellow.',
    partOfSpeech: 'noun',
    examples: [
      { english: 'She ate a red apple for breakfast.', urdu: 'اس نے ناشتے میں سرخ سیب کھایا۔' },
      { english: 'An apple a day keeps the doctor away.', urdu: 'روزانہ ایک سیب ڈاکٹر کو دور رکھتا ہے۔' },
    ],
  },
  {
    englishWord: 'book',
    urduWord: 'کتاب',
    urduMeaning: 'کتاب',
    simpleDefinition: 'A set of written or printed pages bound together.',
    partOfSpeech: 'noun',
    examples: [
      { english: 'He is reading a book.', urdu: 'وہ کتاب پڑھ رہا ہے۔' },
      { english: 'I bought a new book from the market.', urdu: 'میں نے بازار سے نئی کتاب خریدی۔' },
    ],
  },
  {
    englishWord: 'water',
    urduWord: 'پانی',
    urduMeaning: 'پانی',
    simpleDefinition: 'A clear liquid that is essential for life.',
    partOfSpeech: 'noun',
    examples: [
      { english: 'Please give me a glass of water.', urdu: 'براہ کرم مجھے ایک گلاس پانی دیں۔' },
      { english: 'Water is very important for our health.', urdu: 'پانی ہماری صحت کے لیے بہت ضروری ہے۔' },
    ],
  },
  {
    englishWord: 'school',
    urduWord: 'مدرسہ',
    urduMeaning: 'مدرسہ / اسکول',
    simpleDefinition: 'A place where children go to learn.',
    partOfSpeech: 'noun',
    examples: [
      { english: 'The children go to school every morning.', urdu: 'بچے ہر صبح اسکول جاتے ہیں۔' },
      { english: 'Our school has a big playground.', urdu: 'ہمارے اسکول میں بڑا میدان ہے۔' },
    ],
  },
  {
    englishWord: 'beautiful',
    urduWord: 'خوبصورت',
    urduMeaning: 'خوبصورت / حسین',
    simpleDefinition: 'Very pleasing to look at.',
    partOfSpeech: 'adjective',
    examples: [
      { english: 'The garden is very beautiful.', urdu: 'باغ بہت خوبصورت ہے۔' },
      { english: 'She has a beautiful smile.', urdu: 'اس کی مسکراہٹ بہت خوبصورت ہے۔' },
    ],
  },
  {
    englishWord: 'run',
    urduWord: 'دوڑنا',
    urduMeaning: 'دوڑنا',
    simpleDefinition: 'To move quickly on your legs.',
    partOfSpeech: 'verb',
    examples: [
      { english: 'The boy can run very fast.', urdu: 'لڑکا بہت تیز دوڑ سکتا ہے۔' },
      { english: 'We run in the park every morning.', urdu: 'ہم ہر صبح پارک میں دوڑتے ہیں۔' },
    ],
  },
  {
    englishWord: 'house',
    urduWord: 'گھر',
    urduMeaning: 'گھر / مکان',
    simpleDefinition: 'A building where people live.',
    partOfSpeech: 'noun',
    examples: [
      { english: 'My house is near the park.', urdu: 'میرا گھر پارک کے قریب ہے۔' },
      { english: 'They built a new house last year.', urdu: 'انہوں نے پچھلے سال نیا گھر بنایا۔' },
    ],
  },
  {
    englishWord: 'happy',
    urduWord: 'خوش',
    urduMeaning: 'خوش / مسرور',
    simpleDefinition: 'Feeling pleased and glad.',
    partOfSpeech: 'adjective',
    examples: [
      { english: 'I am very happy today.', urdu: 'میں آج بہت خوش ہوں۔' },
      { english: 'The children were happy to see their teacher.', urdu: 'بچے اپنے استاد کو دیکھ کر خوش ہوئے۔' },
    ],
  },
  {
    englishWord: 'eat',
    urduWord: 'کھانا',
    urduMeaning: 'کھانا',
    simpleDefinition: 'To put food in your mouth and swallow it.',
    partOfSpeech: 'verb',
    examples: [
      { english: 'We eat three meals a day.', urdu: 'ہم دن میں تین وقت کھانا کھاتے ہیں۔' },
      { english: 'She likes to eat rice.', urdu: 'اسے چاول کھانا پسند ہے۔' },
    ],
  },
  {
    englishWord: 'friend',
    urduWord: 'دوست',
    urduMeaning: 'دوست',
    simpleDefinition: 'A person you like and trust.',
    partOfSpeech: 'noun',
    examples: [
      { english: 'He is my best friend.', urdu: 'وہ میرا بہترین دوست ہے۔' },
      { english: 'A good friend always helps you.', urdu: 'ایک اچھا دوست ہمیشہ آپ کی مدد کرتا ہے۔' },
    ],
  },
  {
    englishWord: 'quickly',
    urduWord: 'جلدی',
    urduMeaning: 'جلدی / تیزی سے',
    simpleDefinition: 'At a fast speed; without delay.',
    partOfSpeech: 'adverb',
    examples: [
      { english: 'She finished her work quickly.', urdu: 'اس نے اپنا کام جلدی ختم کیا۔' },
      { english: 'Please come quickly — we are late.', urdu: 'جلدی آئیں — ہمیں دیر ہو رہی ہے۔' },
    ],
  },
  {
    englishWord: 'love',
    urduWord: 'محبت',
    urduMeaning: 'محبت / پیار',
    simpleDefinition: 'A strong feeling of deep affection for someone.',
    partOfSpeech: 'noun / verb',
    examples: [
      { english: 'Mother\'s love is the purest love.', urdu: 'ماں کی محبت سب سے خالص محبت ہے۔' },
      { english: 'I love reading books.', urdu: 'مجھے کتابیں پڑھنا پسند ہے۔' },
    ],
  },
  {
    englishWord: 'work',
    urduWord: 'کام',
    urduMeaning: 'کام / محنت',
    simpleDefinition: 'An activity in which you use effort or skill.',
    partOfSpeech: 'noun / verb',
    examples: [
      { english: 'My father goes to work every day.', urdu: 'میرے والد ہر روز کام پر جاتے ہیں۔' },
      { english: 'Hard work leads to success.', urdu: 'محنت کامیابی کی طرف لے جاتی ہے۔' },
    ],
  },
  {
    englishWord: 'time',
    urduWord: 'وقت',
    urduMeaning: 'وقت',
    simpleDefinition: 'The passing of events measured in seconds, minutes, and hours.',
    partOfSpeech: 'noun',
    examples: [
      { english: 'Time is very valuable.', urdu: 'وقت بہت قیمتی ہے۔' },
      { english: 'What time does school start?', urdu: 'اسکول کس وقت شروع ہوتا ہے؟' },
    ],
  },
  {
    englishWord: 'speak',
    urduWord: 'بولنا',
    urduMeaning: 'بولنا / کلام کرنا',
    simpleDefinition: 'To say words and express yourself.',
    partOfSpeech: 'verb',
    examples: [
      { english: 'Can you speak English?', urdu: 'کیا آپ انگریزی بول سکتے ہیں؟' },
      { english: 'Please speak slowly so I can understand.', urdu: 'براہ کرم آہستہ بولیں تاکہ میں سمجھ سکوں۔' },
    ],
  },
];

// ── Main ──────────────────────────────────────────────────────────────────────
async function main() {
  const uri = process.env.MONGODB_URI;
  const dbName = process.env.MONGODB_DATABASE || 'test';

  if (!uri) {
    console.error('MONGODB_URI is not set. Set it in backend/.env and retry.');
    process.exit(1);
  }

  await mongoose.connect(uri, { dbName });
  console.log(`Connected to MongoDB database: ${dbName}`);

  let inserted = 0;
  let updated = 0;

  for (const data of SEED) {
    const searchIndex = [data.englishWord, data.urduMeaning, data.urduWord || '']
      .map((s) => (s || '').toLowerCase())
      .filter(Boolean)
      .join(' ');

    const result = await Entry.findOneAndUpdate(
      { englishWord: data.englishWord },
      { $set: { ...data, searchIndex } },
      { upsert: true, new: true, runValidators: true },
    );

    if (result.createdAt?.getTime() === result.updatedAt?.getTime()) {
      inserted++;
    } else {
      updated++;
    }
    console.log(`  ✓ ${data.englishWord} — ${data.urduMeaning}`);
  }

  console.log(`\nDone. Inserted: ${inserted}  Updated: ${updated}`);
  await mongoose.disconnect();
}

main().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
