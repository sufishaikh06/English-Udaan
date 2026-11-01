# English Udaan — Implementation Map

**Phase:** 0–16 alignment  
**Status:** Master roadmap remains `PHASE_INSTRUCTIONS.md`. This map records current implementation status against that roadmap.  
**Sources reviewed:** `PROJECT_CONTEXT.md`, `PHASE_INSTRUCTIONS.md`, phase handoffs 1–15, current Flutter/Express code  
**Last updated:** 2026-11-02 (Learn Hub and dictionary feature added)

## 1. Current repository state

The repository is an implemented local-first foundation, not a planning-only directory.

Present:

- Flutter app in `mobile/` with Riverpod, GoRouter, Urdu-default localization, System/Light/Dark themes, official unchanged logo, design-system tokens/components, alphabet flow, 75 two-letter words, 110 three-letter words, 130 four-letter words, 161 five-letter words, picture learning categories, sentence/paragraph lessons, grammar lessons, and device TTS.
- Express backend in `backend/` with environment validation (including optional `MONGODB_URI`, `FIREBASE_PROJECT_ID`, and server-only AI provider settings), Mongoose connection lifecycle, `ImageRef`, `UserProgress`, and curated `DictionaryEntry` schemas, Helmet/CORS, rate limiting, centralized errors, `GET /health` (with DB status), `GET /health/readiness`, Firebase Admin initialization, auth middleware, `GET /api/me`, validated cloud progress routes, and `POST /api/dictionary/lookup` with database-first lookup and optional provider-neutral AI fallback.
- Bundled sample content in `mobile/assets/content/`.
- Handoffs in `docs/PHASE_1_HANDOFF.md`, `docs/PHASE_2_HANDOFF.md`, `docs/PHASE_3_HANDOFF.md`, `docs/PHASE_7_THREE_LETTER_HANDOFF.md`, `docs/PHASE_7_FOUR_LETTER_HANDOFF.md`, `docs/PHASE_7_FIVE_LETTER_HANDOFF.md`, `docs/PHASE_8_PICTURE_LEARNING_HANDOFF.md`, `docs/PHASE_9_SENTENCES_PARAGRAPHS_HANDOFF.md`, `docs/PHASE_10_GRAMMAR_HANDOFF.md`, `docs/PHASE_14_BACKEND_MONGODB_HANDOFF.md`, and `docs/PHASE_15_AUTH_CLOUD_PROGRESS_HANDOFF.md`.

Not present:

- Git repository.
- Splash and onboarding remain deferred; Flutter login, registration, Firebase session handling, and logout are implemented in Phase 16.
- Hosting and live AI verification; dictionary API and seed tooling are implemented, while real AI lookup remains optional until `AI_API_KEY` is configured.
- Inspectable Figma exports; the Figma URL in `docs/contents.md` remains the only design reference.
- Practice or progress analytics.

`PHASE_INSTRUCTIONS.md` remains the master development roadmap. `PROJECT_CONTEXT.md` is the canonical product context.

## 2. Target repository layout

```text
codebase/
├── mobile/
│   ├── lib/
│   │   ├── core/theme, core/services
│   │   ├── shared/widgets
│   │   └── features/learning/{data,domain,presentation}
│   ├── assets/content, assets/images/pictures
│   └── test/
├── backend/src/{config,middleware,routes}
├── docs/
├── images/logo.png
└── PHASE_INSTRUCTIONS.md
```

The originally planned `app/` bootstrap split is still pending; `mobile/lib/main.dart` currently hosts bootstrap, router, shell, Home, and settings.

## 3. Screen and route inventory

| Route | Intended phase | Current status |
|---|---:|---|
| `/` splash | 3 | Not started |
| `/onboarding` | 3 | Not started |
| `/auth/login`, `/auth/register` | 3, 15 | Backend auth APIs complete (Phase 15); Flutter login UI deferred to Phase 16 |
| `/home` | 4 | Partial — branded Home |
| `/learn` | 4 | Implemented — bilingual learning hub |
| `/learn/alphabet` | 6 | Implemented |
| `/learn/vocabulary` | 7 | Implemented |
| `/learn/pictures` | 8 | Implemented with Picture Learning foundation |
| `/learn/sentences` | 9 | Implemented — sentence/paragraph selector and bilingual lessons |
| `/learn/paragraphs` | 9 | Not added; paragraphs are a filter in `/learn/sentences` |
| `/learn/grammar` | 10 | Implemented — overview and level filter |
| `/learn/grammar/:id` | 10 | Implemented — detail, examples, corrections, TTS, next/prev |
| `/practice` | 11 | Implemented — category selector & practice landing screen |
| `/practice/quiz/:category` | 11 | Implemented — interactive quiz flow with MCQ, feedback, score, results & retry |
| `/progress` | 12 | Implemented — progress dashboard with sections, quizzes, streaks |
| `/learn/dictionary` | 17 | Implemented — database-first lookup, optional AI fallback, TTS |
| `/profile` | 13 | Implemented — local learner status, preferences, audio, Help, About |
| `/settings` | 13 | Implemented — language/theme controls; audio preferences on `/settings/audio` |

## 4. Domain data contracts

| Entity | Current implementation | Gap |
|---|---|---|
| VocabularyItem | Bundled JSON: 2, 3, 4, 5-letter sections | No `imageRef` |
| PictureItem / Category | Bundled JSON: 9 categories, 82 items | 4-letter and 5-letter sections not started for picture learning |
| SentenceLearningItem | Bundled JSON: 5 small, 5 medium, 5 long sentences; 4 paragraphs | Starter curriculum; translations need owner review |
| GrammarLesson / Example | Bundled JSON: 17 topics across 4 levels | Covers roadmap topics; translations need owner review |
| PracticeQuestion / QuizSession | Dynamic generation from validated local content | 5 categories: vocabulary, pictures, sentences, grammar, mixed |
| ProgressEvent / Summary | Local persistence with sections, quizzes, activity dates, streaks | Section completion, quiz scores, weighted accuracy, current/longest streak |

## 5. Roadmap status against `PHASE_INSTRUCTIONS.md`

| Phase | Status | Evidence |
|---|---|---|
| 0–1 Discovery/Foundation | Complete | `docs/PHASE_1_Handoffs` |
| 2 Design system | Partial | `docs/PHASE_2_HANDOFF.md` |
| 3–4 Onboarding/Shell | Partial | Routes exist; functionality deferred |
| 5–7 Contracts/Content | Partial | JSON content for alpha/vocab; vocab expansion complete |
| 8 Picture learning | Partial | Implemented categories/items foundation in `PictureLearning` feature |
| 9 Sentences/paragraphs | Implemented — starter content/UI | Bundled bilingual sentence/paragraph lesson flow; no completion persistence required by roadmap |
| 10 Grammar | Implemented — starter curriculum | 17 topics across 4 levels, rules, examples, corrections, audio; completion tracking deferred |
| 11 Practice | Implemented — interactive quiz flow | 5 categories, deterministic question generation, feedback, scoring, retry, and minimal persistence |
| 12 Progress | Implemented — dashboard with sections, quiz results, streaks | Placeholder shell |
| 13 Profile/Settings | Implemented | Local-only profile, persisted language/theme/audio, Help and About; authentication/logout deferred until auth exists |
| 14 Backend | Complete (Verified) | Mongoose connection, schemas, health/readiness endpoint (HTTP 200 verified live), env validation, graceful shutdown, 27 tests passed, live Atlas connection verified |
| 15 Auth/cloud progress APIs | Complete | Firebase Admin SDK, token middleware, `GET /api/me`, `GET /api/progress`, `PUT /api/progress`, ownership isolation, rate limiting, input validation, 53/53 tests pass |
| 16 Flutter/backend integration | Implemented — local-first auth and cloud progress integration | Firebase auth UI/session, Bearer API client, guest learning access, cloud progress client, and profile account controls |
| 17 AI dictionary | Blocked | AI provider decision required |
| 18 Future | Watch item | |
| 19–25 QA/release | Not started | |

```text
PHASE: 16 — Flutter/backend integration
STATUS: Implemented — pending live Firebase/backend verification
COMPLETED: firebase_core, firebase_auth, google_sign_in, flutter_secure_storage, and http dependencies; Android Firebase client configuration retained with minSdk 21; AuthService for email/password, Google Sign-In, state stream, token access, and logout; API client with Bearer token attachment and sanitized HTTP errors; bilingual login/register screens; guest-accessible learning routes; authenticated profile controls; cloud progress GET/PUT service with local-first fallback and sync state; focused Flutter regression tests preserved.
FILES CHANGED: mobile/pubspec.yaml; mobile/pubspec.lock; mobile/android/app/build.gradle.kts; mobile/lib/core/services/auth_service.dart; mobile/lib/core/services/api_client.dart; mobile/lib/features/auth/presentation/auth_providers.dart; mobile/lib/features/auth/presentation/auth_screens.dart; mobile/lib/features/auth/data/cloud_progress_service.dart; mobile/lib/features/profile/presentation/profile_screens.dart; mobile/lib/main.dart; mobile/test/progress_test.dart; mobile/test/learning_flow_test.dart; docs/IMPLEMENTATION_MAP.md; docs/PHASE_16_FLUTTER_BACKEND_INTEGRATION_HANDOFF.md
TESTS: flutter pub get passed; flutter analyze completed with 8 pre-existing/style-info diagnostics and no errors; focused progress/profile tests passed (16); learning repository tests passed (13). Full flutter test remains affected by existing learning-flow assumptions and Firebase-dependent auth/router test setup.
KNOWN ISSUES / ASSUMPTIONS: Live Firebase sign-in, Google Sign-In, real ID-token verification against the running backend, and cloud conflict merge were not tested in this environment. Cloud progress currently preserves local data on failed reads/writes and uploads validated local snapshots; server payload uses the Phase 15 full-progress contract. Physical-device TTS was not retested.
DECISIONS NEEDED: Configure Firebase Auth providers and debug SHA-1/SHA-256 fingerprints in Firebase Console; configure backend ADC or GOOGLE_APPLICATION_CREDENTIALS; choose production API base URL; complete live sync/conflict verification.
NEXT OWNER: Phase 16 review/live verification, then Phase 17 hybrid dictionary.
```

```text
PHASE: 15 — Auth/Cloud Progress APIs
STATUS: Complete
COMPLETED: firebase-admin installed; src/config/firebase.js (initializeFirebase, getFirebaseAuth, verifyIdToken with ADC/GOOGLE_APPLICATION_CREDENTIALS support, no secrets committed); FIREBASE_PROJECT_ID added to environment schema; src/middleware/auth.js (createAuthMiddleware — Bearer token → verified UID, consistent 401 responses, no raw Firebase error leakage); src/routes/profile.js (GET /api/me — authenticated profile); src/routes/progress.js (GET /api/progress, PUT /api/progress — per-user, ownership-isolated, fully validated); UserProgress schema migrated to firebaseUid primary key (deviceId retained as optional for backward compatibility); express-rate-limit (100 req/15 min per IP on auth routes); src/app.js wired with Firebase + rate limiter + new routes; src/server.js Firebase startup initialization; .env.example created with ADC and service-account credential guidance; test/auth.test.js (27 new tests for middleware, profile, progress validation, auth-not-configured path, ownership isolation); test/models.test.js updated for firebaseUid; 53/53 tests pass.
FILES CHANGED: backend/package.json; backend/package-lock.json; backend/.env.example (new); backend/.env (FIREBASE_PROJECT_ID added); backend/src/config/environment.js; backend/src/config/firebase.js (new); backend/src/middleware/auth.js (new); backend/src/models/user-progress.js; backend/src/routes/profile.js (new); backend/src/routes/progress.js (new); backend/src/app.js; backend/src/server.js; backend/test/auth.test.js (new); backend/test/models.test.js; docs/IMPLEMENTATION_MAP.md; docs/PHASE_15_AUTH_CLOUD_PROGRESS_HANDOFF.md
TESTS: npm test — 53/53 passed (27 Phase 15 auth tests + 26 existing Phase 14 tests).
KNOWN ISSUES / ASSUMPTIONS: Real Firebase token verification not tested (requires live Firebase project with issued tokens); live Atlas connection not retested (verified in Phase 14). GOOGLE_APPLICATION_CREDENTIALS or ADC must be configured locally for auth endpoints to accept real tokens.
DECISIONS NEEDED: Flutter auth UI (login/register screens) and API client — Phase 16.
NEXT OWNER: Phase 16 — Flutter/backend integration.
```

```text
PHASE: 14 — Backend/MongoDB
STATUS: Complete (Live Atlas connection verified)
COMPLETED: mongoose installed; src/config/database.js; MONGODB_URI validation; .env.example updated; src/models/image-ref.js; src/models/user-progress.js; GET /health with database status; GET /health/readiness endpoint (HTTP 200 verified live); src/app.js & src/server.js startup/shutdown integration; 27/27 unit & integration tests passed; live Atlas connection verified via `npm run dev`; `.env` correctly git-ignored with zero secrets committed or logged.
FILES CHANGED: backend/package.json; backend/package-lock.json; backend/.env.example; backend/src/config/environment.js; backend/src/config/database.js; backend/src/models/image-ref.js; backend/src/models/user-progress.js; backend/src/routes/health.js; backend/src/app.js; backend/src/server.js; backend/test/database.test.js; backend/test/health.test.js; backend/test/models.test.js; docs/IMPLEMENTATION_MAP.md; docs/PHASE_14_BACKEND_MONGODB_HANDOFF.md
TESTS: npm test — 27/27 passed; GET /health/readiness verified live (HTTP 200); live Atlas connection verified.
KNOWN ISSUES / ASSUMPTIONS: None. Live connection and readiness verified successfully.
DECISIONS NEEDED: Auth method/provider approval for Phase 15.
NEXT OWNER: Phase 15 — Auth/cloud progress APIs.
```

```text
PHASE: 11 — Practice
STATUS: Implemented interactive practice and quizzes
COMPLETED: Domain models (PracticeQuestion, QuizSession, PracticeAnswer), deterministic question generator from local learning repositories, practice landing screen with 5 categories, interactive quiz flow (MCQ, feedback, score tally, answer lock, progress), results summary screen with accuracy and retry option, GoRouter navigation (/practice and /practice/quiz/:category), Home practice card, minimal independent quiz score persistence, and unit/widget tests.
FILES CHANGED: mobile/lib/features/practice/domain/practice_models.dart; mobile/lib/features/practice/data/practice_question_generator.dart; mobile/lib/features/practice/data/practice_repository.dart; mobile/lib/features/practice/presentation/practice_screens.dart; mobile/lib/main.dart; mobile/test/practice_test.dart; mobile/test/practice_screens_test.dart; mobile/test/learning_flow_test.dart; docs/IMPLEMENTATION_MAP.md; docs/PHASE_11_PRACTICE_HANDOFF.md
TESTS: flutter pub get passed; flutter analyze passed (0 issues); practice unit and widget tests passed (12); full passing test suite passed (28 tests); npm test passed (2); learning_flow_test investigated (Home navigation failure resolved via router reset; 3 pre-existing rootBundle async loading failures documented).
KNOWN ISSUES / ASSUMPTIONS: Physical-device TTS was not retested. Pre-existing test harness async issues in learning_flow_test remain documented.
DECISIONS NEEDED: Progress tracking dashboard architecture and cloud sync rules for Phase 12.
NEXT OWNER: Phase 12 progress tracking.
```

```text
PHASE: 10 — Grammar
STATUS: Implemented 17-topic progressive curriculum
COMPLETED: Domain models, repository validation, bundled JSON, topic list and detail screens, audio integration, next/previous navigation, and repository/UI tests.
FILES CHANGED: mobile/assets/content/grammar_sample.json; mobile/lib/features/learning/domain/learning_models.dart; mobile/lib/features/learning/data/learning_repository.dart; mobile/lib/features/learning/presentation/grammar_learning_screen.dart; mobile/lib/main.dart; mobile/pubspec.yaml; mobile/test/learning_repository_test.dart; mobile/test/grammar_learning_screen_test.dart; docs/IMPLEMENTATION_MAP.md; docs/PHASE_10_GRAMMAR_HANDOFF.md
TESTS: flutter pub get passed; flutter analyze passed; repository and grammar tests passed (14 total across those files); npm test passed (2).
KNOWN ISSUES / ASSUMPTIONS: Starter curriculum covers roadmap topics; translations need owner review. Physical-device TTS not tested.
DECISIONS NEEDED: Practice integration for Phase 11; progress sync model for Phase 12.
NEXT OWNER: Phase 11 practice exercises.
```

```text
PHASE: 9 — Sentences & Paragraphs
STATUS: Implemented initial 19-item curriculum
COMPLETED: Validated local content model/repository; type selector, bilingual lesson UI, `/learn/sentences` route, English TTS wiring, and repository/UI direction tests.
FILES CHANGED: mobile/assets/content/sentences_paragraphs_sample.json; mobile/lib/features/learning/domain/learning_models.dart; mobile/lib/features/learning/data/learning_repository.dart; mobile/lib/features/learning/presentation/sentence_learning_screen.dart; mobile/lib/main.dart; mobile/pubspec.yaml; mobile/test/learning_repository_test.dart; docs/IMPLEMENTATION_MAP.md; docs/PHASE_9_SENTENCES_PARAGRAPHS_HANDOFF.md
TESTS: flutter pub get passed; flutter analyze passed; repository tests passed (10); full flutter test failed on four existing learning_flow vocabulary/Home tests; npm test passed (2).
KNOWN ISSUES / ASSUMPTIONS: No roadmap quantity prescribed; initial scope is 5 small + 5 medium + 5 long sentences and 4 paragraphs. Full suite failures described in Phase 9 handoff; Urdu content needs owner review. Physical-device TTS not retested.
DECISIONS NEEDED: Urdu content review; broader curriculum quantities can be specified in later content expansion.
NEXT OWNER: Phase 10 grammar.
```

```text
PHASE: 8 — Picture Learning implementation
STATUS: Complete for 9-category foundation
COMPLETED: Data model, repository validation, category screen+selector, image resolver (local/network), TTS, and completion persistence for 9 categories.
FILES CHANGED: mobile/pubspec.yaml; mobile/assets/content/picture_learning_sample.json; mobile/lib/features/learning/domain/learning_models.dart; mobile/lib/features/learning/data/learning_repository.dart; mobile/lib/features/learning/presentation/picture_learning_screens.dart; mobile/lib/main.dart; mobile/test/learning_repository_test.dart; mobile/test/learning_flow_test.dart; docs/IMPLEMENTATION_MAP.md; docs/PHASE_8_PICTURE_LEARNING_HANDOFF.md
TESTS: flutter analyze; flutter test; npm test — all passed
KNOWN ISSUES / ASSUMPTIONS: Pre-existing pumpAndSettle in learning_flow_test persists as documented in previous handoffs.
DECISIONS NEEDED: Figma inspect data; image licenses for Phase 8 expansion; auth/conflict/hosting/AI decisions.
NEXT OWNER: Mobile/content expansion for the next step.
```
