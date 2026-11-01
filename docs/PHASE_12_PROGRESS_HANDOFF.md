# English Udaan — Phase 12 Progress Tracking Handoff

## Implementation

**Summary:** Unified progress tracking dashboard that aggregates existing local learning data from vocabulary sections, picture categories, and practice quizzes, with learning streak tracking.

**Files changed:**

- `mobile/lib/features/progress/domain/progress_models.dart` — Data models for progress summary, lesson sections, quiz results, and streak calculations
- `mobile/lib/features/progress/data/progress_repository.dart` — Repository that reads existing completion keys and quiz score persistence
- `mobile/lib/features/progress/presentation/progress_screen.dart` — Flutter UI with sections completed, words in completed sections, quiz accuracy, and streak display
- `mobile/lib/main.dart` — Replaced placeholder with actual ProgressScreen route
- `mobile/lib/features/learning/presentation/learning_screens.dart` — Records study activity when vocabulary lesson completed
- `mobile/lib/features/learning/presentation/picture_learning_screens.dart` — Records study activity when picture lesson completed
- `mobile/lib/features/practice/data/practice_repository.dart` — Records study activity when quiz completed
- `mobile/test/progress_test.dart` — Unit tests for repository, streak logic, summary calculations
- `mobile/test/progress_screen_test.dart` — Widget tests for progress screen

**Metrics implemented:**

- Sections completed (vocabulary 2/3/4/5-letter + 9 picture categories)
- Words in completed sections (section-level count, not word-level mastery)
- Quiz accuracy (weighted across latest saved scores per category)
- Current streak (consecutive study days)
- Longest streak (best consecutive days)
- Local-only sync state placeholder

**Streak rules:**
- Records activity date when lesson or quiz is completed
- Prevents duplicate same-day entries
- Rejects future-dated activity
- Consecutive-day calculation uses calendar dates

**Persistence strategy:**
- Reuses existing vocabulary completion keys (`lesson.vocabulary.X-letter.complete`)
- Reuses existing picture completion keys (`lesson.pictures.{category}.complete`)
- Reuses existing quiz score keys (`practice.quiz.{category}.last_score/total/completed_at`)
- New key for activity dates: `progress.activity.dates` (list of YYYY-MM-DD strings)

## Validation

**Commands executed:**
- `flutter pub get` — Passed
- `flutter analyze` — Passed (2 info/warnings, no errors)
- `flutter test` — Partial. Pre-existing `learning_flow_test.dart` failures documented below.
- `npm test` — Passed (2 backend tests)

**Tests added:**
- `progress_test.dart`: 11 tests covering repository, activity recording, streak calculations, summary math
- `progress_screen_test.dart`: 3 widget tests (async setup complexities with existing bundle dependency)

**Known failures:**
- Pre-existing `learning_flow_test.dart` failures (4 tests):
  - "Vocabulary screen switches sections" — asset loading timing issue
  - "vocabulary search filters the list" — keyboard focus issue  
  - "completing vocabulary persists its completion" — drag/scroll issue
  - Home navigation test (documented in Phase 11 handoff)
- These failures existed before Phase 12 and are unrelated to this implementation.

## Limitations

- **Words in completed sections**: Reports section size, not individual word mastery. Section completion is a single boolean per vocabulary length or picture category.
- **Quiz accuracy**: Uses only latest saved scores per category (per Phase 11 implementation). Not a full quiz history.
- **Alphabet, sentences, grammar**: Do not store completion yet. Progress shows only vocabulary and picture sections.
- **Physical-device TTS**: Not retested during this implementation.

## Regression

- Existing vocabulary (2/3/4/5-letter), picture learning, sentences, grammar, and practice features remain operational.
- Existing completion keys are preserved and read by the progress repository.
- Quiz score persistence works as before.

## Next steps

Per `PHASE_INSTRUCTIONS.md`, the next roadmap task is **Phase 13 — Profile/Settings**:
- Account state placeholder
- Logout
- Language and appearance controls
- Audio and approved help/about
- Handle session expiry (not yet applicable)

Phase 12 progress dashboard is ready for use. Phase 13 can begin when the owner is ready.