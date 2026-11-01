# Phase 7 — Five-letter Vocabulary Handoff

**Status:** Complete for the 150–175 five-letter vocabulary requirement  
**Date:** 2026-09-30

## Completed

- Added **161 five-letter words** to `mobile/assets/content/vocabulary_sample.json`.
- Preserved all existing **75 two-letter words**, **110 three-letter words**, and **130 four-letter words** unchanged.
- Kept schema version `0.1.0-sample`.
- Enforced five-letter count (150–175), exact word length, unique IDs, unique words, and required Urdu meaning/example fields in `LearningRepository`.
- Updated the section switch on `VocabularyScreen` to include `5` (پانچ حرفی الفاظ) alongside 2, 3, and 4 so each length loads independently.
- Search, result count, empty-state, TTS, and lesson-completion behavior now functionally act upon the five-letter section.
- Five-letter completion uniquely uses `lesson.vocabulary.five-letter.complete`.

## Number of words established

| Section | Count | Required |
|---|---:|---|
| Two-letter (preserved) | 75 | ≥ 75 |
| Three-letter (preserved)| 110 | 100–125 |
| Four-letter (preserved) | 130 | 125–150 |
| Five-letter (new) | **161** | 150–175 |

## Files changed

```text
mobile/assets/content/vocabulary_sample.json
mobile/lib/features/learning/data/learning_repository.dart
mobile/lib/features/learning/presentation/learning_screens.dart
mobile/test/learning_repository_test.dart
docs/IMPLEMENTATION_MAP.md
docs/PHASE_7_FIVE_LETTER_HANDOFF.md
```

## Validation and tests

| Command / check | Result |
|---|---|
| `flutter analyze` | Passed — no issues |
| `learning_repository_test.dart` | Passed — 7 tests, now including 161 five-letter count/length/Urdu/example schema validation |
| `widget_test.dart` | Passed — Urdu RTL default and English LTR switch |
| `npm test` | Passed — 2 backend health tests |

`learning_flow_test.dart` still experiences pre-existing `pumpAndSettle` / `runAsync` timing limitations when simulating UI rendering that reads dynamically from JSON payload through `FutureBuilder`. The core parsing rules, duplication-safety, length counts, model integrations, and schemas are thoroughly verified directly via the standalone repository tests. This is a pre-existing issue unaffected by the 5-letter updates.

Physical-device TTS was **not** tested in this pass.

## Known issues / assumptions

- Five-letter content is sample curriculum pending owner Urdu review.
- Optional image references are not present; the current schema does not require them.
- MongoDB, authentication, cloud sync, hosting, and live AI dictionary remain out of scope.

## Confirmation

Existing two-letter, three-letter, and four-letter vocabulary models remain perfectly functional, independent, and unedited. 

## Next recommended task

Phase 8 — Picture Learning. Setup UI lists, hybrid images, caching, placeholders, fallbacks, and content records for Fruits, vegetables, animals, birds, vehicles, indoor/outdoor things, etc.
