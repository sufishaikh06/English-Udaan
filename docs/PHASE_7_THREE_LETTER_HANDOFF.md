# Phase 7 — Three-letter Vocabulary Handoff

**Status:** Complete for the 100–125 three-letter vocabulary requirement  
**Date:** 2026-09-27

## Completed

- Added **110 three-letter words** to `mobile/assets/content/vocabulary_sample.json`.
- Preserved all existing **75 two-letter words** unchanged.
- Kept schema version `0.1.0-sample`.
- Enforced three-letter count (100–125), exact word length, unique IDs, unique words, and required Urdu meaning/example fields in `LearningRepository`.
- Added a 2-letter / 3-letter section switch on `VocabularyScreen` so each length loads independently.
- Search, result count, empty-state, TTS, and lesson-completion behavior now apply to the selected word-length section.
- Existing two-letter completion key `lesson.vocabulary.two-letter.complete` is unchanged. Three-letter completion uses `lesson.vocabulary.three-letter.complete`.

## Number of words added

| Section | Count | Required |
|---|---:|---|
| Two-letter (preserved) | 75 | ≥ 75 |
| Three-letter (new) | **110** | 100–125 |

## Files changed

```text
mobile/assets/content/vocabulary_sample.json
mobile/lib/features/learning/data/learning_repository.dart
mobile/lib/features/learning/presentation/learning_screens.dart
mobile/test/learning_repository_test.dart
docs/IMPLEMENTATION_MAP.md
docs/PHASE_7_THREE_LETTER_HANDOFF.md
```

## Validation and tests

| Command / check | Result |
|---|---|
| `flutter analyze` | Passed — no issues |
| `learning_repository_test.dart` | Passed — 5 tests, including 75 two-letter and 110 three-letter count/length/Urdu/example validation |
| `widget_test.dart` | Passed — Urdu RTL default and English LTR switch |
| `npm test` | Passed — 2 backend health tests |

`learning_flow_test.dart` still has pre-existing `pumpAndSettle` timeouts when navigating into the vocabulary list. Those timeouts existed before this three-letter work and are not caused by the new dataset. Count, uniqueness, word-length, and required-field validation are covered by the repository tests.

Physical-device TTS was **not** tested in this pass.

## Known issues / assumptions

- Three-letter content is sample curriculum pending owner Urdu review.
- Optional image references are not present; the current schema does not require them.
- Four-letter and five-letter sections were not started.
- MongoDB, authentication, cloud sync, hosting, and live AI dictionary remain out of scope.

## Confirmation

Existing two-letter vocabulary remains functional: same 75 IDs, same schema, independent load via `loadVocabulary(wordLength: 2)`, and unchanged completion key.

## Next recommended task

Four-letter vocabulary, targeting **125–150** valid four-letter English words, using the same JSON schema, repository validation, section switch, search, TTS, and local completion pattern.
