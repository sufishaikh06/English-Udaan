# Phase 9 — Sentences & Paragraphs Handoff

**Status:** Implemented initial roadmap-aligned local learning flow  
**Date:** 2026-10-13

## Implementation

- Added `SentenceLearningItem` and `LearningContentType` in `mobile/lib/features/learning/domain/learning_models.dart` with strict required text, supported type, positive order, and supported difficulty validation.
- Added validated `loadSentenceLearningItems()` in `mobile/lib/features/learning/data/learning_repository.dart`; it validates section/version, non-empty items, unique IDs/orders, all four required types, and sorted order.
- Added `mobile/assets/content/sentences_paragraphs_sample.json` and registered it in `mobile/pubspec.yaml`.
- Initial content scope, since the roadmap specifies no exact quantity: **5 small sentences, 5 medium sentences, 5 long sentences, and 4 progressively longer paragraphs (19 total)**. Each record has English, complete Urdu translation, difficulty, stable ID/order, and TTS text.
- Added reusable filtered bilingual lesson screen at `mobile/lib/features/learning/presentation/sentence_learning_screen.dart`, route `/learn/sentences`, and a Home entry point. English and Urdu are explicitly rendered LTR and RTL, respectively. Content uses wrapping cards/list scrolling to accommodate long text.
- Pronunciation is wired to the existing `SpeechService` / `DeviceSpeechService` implementation. No new progress persistence was added because Phase 9 roadmap does not require it; Phase 12 is the progress phase.
- No schema version change; existing `0.1.0-sample` convention retained.

## Validation

- `flutter pub get`: passed.
- `flutter analyze`: passed, no issues.
- `flutter test test/learning_repository_test.dart`: passed, 10 tests including Phase 9 data and invalid-type validation.
- `flutter test`: failed in four existing `learning_flow_test.dart` vocabulary/home tests (Home learn words card scroll finder, vocabulary initial content, search and completion tests). The full suite must not be considered passing. These were existing tests and the test source was not altered by this task; they indicate test harness/layout or asynchronous FutureBuilder behavior.
- `npm test`: passed, 2 backend health tests.
- `learning_flow_test.dart` originally documented an asynchronous `pumpAndSettle`/`runAsync` issue; the full-suite failures remain visible and no tests were removed/disabled.

## Content review

The roadmap does not specify numerical content counts; the 19-item starter set is a scoped initial dataset, not a claim of complete curriculum coverage. Urdu text should receive fluent Urdu-speaking owner review for preferred phrasing and regional style before release. No known intentionally uncertain individual translation was identified.

## Regression and device testing

Phase 7 vocabulary and Phase 8 picture functionality were not edited. A full Flutter suite was attempted but had the failures listed above, so regression is not certified by a passing full suite. **Physical-device TTS was not retested during this implementation.**

## Next roadmap task

Proceed to **Phase 10 — Grammar**, as defined by `PHASE_INSTRUCTIONS.md`.
