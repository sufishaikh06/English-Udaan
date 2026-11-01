const assert = require('node:assert/strict');
const test = require('node:test');

const { ImageRef } = require('../src/models/image-ref');
const { UserProgress, VALID_SECTIONS } = require('../src/models/user-progress');

test('VALID_SECTIONS contains expected section names', () => {
  assert.ok(VALID_SECTIONS.includes('alphabet'));
  assert.ok(VALID_SECTIONS.includes('vocabulary-two-letter'));
  assert.ok(VALID_SECTIONS.includes('vocabulary-five-letter'));
  assert.ok(VALID_SECTIONS.includes('picture-fruits'));
  assert.ok(VALID_SECTIONS.includes('sentences'));
  assert.ok(VALID_SECTIONS.includes('grammar'));
});

test('ImageRef schema requires itemId', async () => {
  const doc = new ImageRef({
    category: 'fruits',
    englishLabel: 'mango',
    urduLabel: 'آم',
    sourceType: 'local',
    assetPath: 'assets/images/pictures/fruits/mango.png',
  });
  const error = await doc.validate().catch((e) => e);
  assert.ok(error && error.errors['itemId'], 'itemId should be required');
});

test('ImageRef schema requires category', async () => {
  const doc = new ImageRef({
    itemId: 'fruit-001',
    englishLabel: 'mango',
    urduLabel: 'آم',
    sourceType: 'local',
    assetPath: 'assets/images/pictures/fruits/mango.png',
  });
  const error = await doc.validate().catch((e) => e);
  assert.ok(error && error.errors['category'], 'category should be required');
});

test('ImageRef schema requires englishLabel', async () => {
  const doc = new ImageRef({
    itemId: 'fruit-001',
    category: 'fruits',
    urduLabel: 'آم',
    sourceType: 'local',
    assetPath: 'assets/images/pictures/fruits/mango.png',
  });
  const error = await doc.validate().catch((e) => e);
  assert.ok(error && error.errors['englishLabel'], 'englishLabel should be required');
});

test('ImageRef schema requires sourceType and rejects unknown values', async () => {
  const doc = new ImageRef({
    itemId: 'fruit-001',
    category: 'fruits',
    englishLabel: 'mango',
    urduLabel: 'آم',
    sourceType: 'cdn',
  });
  const error = await doc.validate().catch((e) => e);
  assert.ok(error && error.errors['sourceType'], 'sourceType should reject unknown enum value "cdn"');
});

test('ImageRef schema accepts valid local document', async () => {
  const doc = new ImageRef({
    itemId: 'fruit-001',
    category: 'fruits',
    englishLabel: 'mango',
    urduLabel: 'آم',
    sourceType: 'local',
    assetPath: 'assets/images/pictures/fruits/mango.png',
  });
  await assert.doesNotReject(() => doc.validate(), 'Valid local ImageRef should not produce validation errors');
});

test('ImageRef schema accepts valid remote document', async () => {
  const doc = new ImageRef({
    itemId: 'fruit-002',
    category: 'fruits',
    englishLabel: 'apple',
    urduLabel: 'سیب',
    sourceType: 'remote',
    remoteUrl: 'https://example.com/images/apple.png',
  });
  await assert.doesNotReject(() => doc.validate(), 'Valid remote ImageRef should not produce validation errors');
});

// Phase 15: ownership key changed from deviceId to firebaseUid.
// deviceId is now optional (retained for backward compatibility).
test('UserProgress schema requires firebaseUid (Phase 15 ownership key)', async () => {
  const doc = new UserProgress({
    sections: [],
    quizResults: [],
  });
  const error = await doc.validate().catch((e) => e);
  assert.ok(error && error.errors['firebaseUid'], 'firebaseUid should be required');
});

test('UserProgress schema accepts valid document with firebaseUid and defaults', async () => {
  const doc = new UserProgress({
    firebaseUid: 'firebase-uid-abc-123',
  });
  await assert.doesNotReject(() => doc.validate(), 'Valid UserProgress should not produce validation errors');
  assert.equal(doc.currentStreak, 0);
  assert.equal(doc.longestStreak, 0);
  assert.deepEqual(doc.sections, []);
  assert.deepEqual(doc.quizResults, []);
});

test('UserProgress rejects invalid section name', async () => {
  const doc = new UserProgress({
    firebaseUid: 'firebase-uid-abc-123',
    sections: [{ section: 'not-a-valid-section', completed: false }],
  });
  const error = await doc.validate().catch((e) => e);
  assert.ok(error, 'Should produce a validation error for invalid section name');
});

test('UserProgress accepts valid section progress', async () => {
  const doc = new UserProgress({
    firebaseUid: 'firebase-uid-abc-123',
    sections: [{ section: 'alphabet', completed: true, completedAt: new Date() }],
    quizResults: [{ category: 'vocabulary', score: 8, total: 10 }],
    currentStreak: 3,
    longestStreak: 7,
    lastActivityDate: new Date(),
  });
  await assert.doesNotReject(() => doc.validate(), 'Valid UserProgress with sections and quiz results should pass');
});

test('UserProgress rejects negative streak', async () => {
  const doc = new UserProgress({
    firebaseUid: 'firebase-uid-abc-123',
    currentStreak: -1,
  });
  const error = await doc.validate().catch((e) => e);
  assert.ok(error && error.errors['currentStreak'], 'Negative streak should fail validation');
});
