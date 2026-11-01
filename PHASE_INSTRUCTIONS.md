# English Udaan — Antigravity Phased Development Instructions

**Read first:** `ENGLISH_UDAAN_PROJECT_CONTEXT.md`  
**UI source of truth:** approved Figma. **Brand source:** owner-provided logo.

## Confirmed stack — do not change without approval
Flutter/Dart; Riverpod; GoRouter; Node.js/Express REST API; MongoDB Atlas/Mongoose; Local JSON + MongoDB; hybrid bundled/remote images; database-first + live AI dictionary via backend; login + cloud progress; device TTS; Urdu default RTL / English LTR; System/Light/Dark themes.

**Not yet decided:** AI provider, authentication method/provider, hosting vendor, token/session strategy, and progress-sync conflict rules. Document options and obtain approval for decisions affecting cost, security, or UX.

## Universal rules
1. Inspect context, repository, Figma, logo, and assets before coding.
2. Keep changes scoped, buildable, tested, and coordinated across agents.
3. Reuse components; no giant datasets in widgets or raw HTTP calls in widgets.
4. Never expose AI/database/JWT secrets in Flutter or Git.
5. Never store large image binaries in MongoDB.
6. Do not fake AI, login, sync, or payments.
7. Urdu is default; preserve RTL and all theme modes.
8. Document assumptions, blockers, and handoffs.

## Suggested agent ownership
- Architect/integrator: architecture, dependencies, contracts, integration.
- UI/design: Figma, tokens, shared widgets.
- Localization/accessibility: Urdu/English, RTL/LTR, copy and accessibility QA.
- Content/data: models, JSON, content counts and Urdu review.
- Learning: alphabet, vocabulary, pictures, sentences, paragraphs, grammar, TTS.
- Practice/progress: quiz state, scoring, local persistence and sync.
- Backend: Express, Mongoose, APIs, auth and authorization.
- AI dictionary: lookup, AI provider abstraction, limits and dictionary UX.
- QA/release: regression, visual, security, performance and APK checks.

## Phase 0 — Discovery
Inspect Figma, repository, logo/assets, routes, screens, languages/themes, API/data needs, and open decisions.
**Deliverable:** `docs/IMPLEMENTATION_MAP.md` with screen/routes, ownership, component inventory, data/API matrix, dependencies, open decisions.
**Gate:** ownership and dependencies understood.

## Phase 1 — Foundation
Set up Flutter, Riverpod, GoRouter, modular folders, localization, RTL/LTR, System/Light/Dark themes, local preference storage, API/repository conventions, linting/tests. Create backend skeleton and `.env.example` if backend starts now.
**Gate:** app builds; placeholder routes, language/theme switching and preference persistence work.

## Phase 2 — Design system
Translate Figma tokens (color, typography, spacing, radii, elevation, icons). Build reusable buttons, search, word/picture/lesson/sentence/progress cards, chips, audio button, header, navigation, settings rows, loading/error/empty states.
**Gate:** core components match Figma in both languages and themes.

## Phase 3 — Splash, onboarding, authentication
Use official logo; first launch Urdu; implement language selection, onboarding, and approved login/register/session flows. Do not fake authentication.
**Gate:** Urdu-first flow, RTL/LTR, themes, and auth states verified.

## Phase 4 — App shell and Home
Implement Home/Learn/Practice/Progress/Profile navigation and Figma hierarchy. No dead buttons.
**Gate:** navigation works in every language/theme.

## Phase 5 — Data contracts/local content
Define models for alphabet, vocabulary, category, sentence, paragraph, grammar, quiz, dictionary, user, and progress. Add validated local JSON repositories, remote DTOs, versioning, and local/remote precedence. Agree sync/conflict rules.
**Gate:** add content without UI edits; invalid data caught.

## Phase 6 — Alphabet + TTS
A–Z/lowercase overview/detail, example, Urdu, optional image, previous/next. Reusable SpeechService with voice availability and failure handling.
**Gate:** pronunciation works or degrades gracefully.

## Phase 7 — Vocabulary
Build 2/3/4/5-letter sections, required ranges, search/filter, cards/detail, Urdu meanings, examples, audio, optional images. Validate counts, word length, IDs, duplicates.
**Gate:** data counts verified; shared components used.

## Phase 8 — Picture learning
Fruits, vegetables, domestic/wild animals, birds, vehicles, indoor/outdoor, body parts, colours, shapes, numbers, directions. Indoor/outdoor target 100+ each. Hybrid images, cache, placeholders, fallback, rights/source record.
**Gate:** smooth lists; no image binaries in MongoDB.

## Phase 9 — Sentences/paragraphs
Simple/medium/long sentences and progressive paragraphs; English + Urdu, TTS where applicable; handle long text and mixed direction.
**Gate:** no overflow or malformed RTL.

## Phase 10 — Grammar
Data-driven topics: parts of speech, nouns, pronouns, verbs, adjectives, adverbs, prepositions, conjunctions, articles, tenses, modals, agreement, active/passive, direct/indirect, degrees, sentence structure, common errors. Add explanations, examples, practice.
**Gate:** expandable content and Urdu review.

## Phase 11 — Practice
Vocabulary/picture/sentence/grammar quiz flow, MCQ, feedback, next, results, score and accuracy. Prevent double submission and handle exit/restart.
**Gate:** scoring and progress events verified.

## Phase 12 — Progress
Words, lessons, accuracy, streak, overall progress, recent activity. Persist locally; model cloud sync states and retry.
**Gate:** calculations verified; offline progress retained.

## Phase 13 — Profile/settings
Account state, logout, language, appearance, audio and approved help/about. Handle session expiry.
**Gate:** preferences persist and apply app-wide.

## Phase 14 — Backend/MongoDB
Express structure, Mongoose models, Atlas config, health endpoint, validation, consistent responses, centralized errors, useful indexes, `.env` secrets.
**Gate:** starts/connects/responds securely.

## Phase 15 — Auth/cloud progress APIs
Approve auth method; implement registration/login/session, password hashing if relevant, protected endpoints, per-user progress, validation/rate limits, and sync semantics.
**Gate:** unauthorized requests rejected; users cannot access others' progress.

## Phase 16 — Flutter/backend integration
API client, repositories, secure token storage, auth/session handling, content endpoints, cloud progress, loading/error/retry/offline/sync states. Keep local JSON/cache fallback.
**Gate:** online/offline behavior coherent; no raw HTTP in widgets.

## Phase 17 — Hybrid dictionary/live AI
Search database first; use backend AI fallback for missing/contextual requests. Provider-neutral service, server-only keys, validation, timeouts, rate/usage limits, cost controls, loading/error/offline/quota states. Distinguish AI output where useful.
**Gate:** database hits avoid AI; configured fallback works; failure paths tested; no secrets in app.

## Phase 18 — Future feature boundaries
Only prepare extension points for English→Urdu, richer AI/voice, video, premium/subscription/payment, admin/CMS. No fake flows; separate approval required.
**Gate:** no misleading controls.

## Phase 19 — Figma visual QA
Compare spacing, typography, colors, radii, icons, image crop, navigation, RTL and dark mode.
**Deliverable:** `docs/FIGMA_QA_REPORT.md`, issues Critical/Major/Minor.
**Gate:** critical/major issues fixed.

## Phase 20 — Language/accessibility QA
Review all Urdu/English strings, punctuation, RTL, mixed-direction text, dialogs/errors/empty states, font scaling, contrast, touch targets and screen-reader labels.
**Gate:** no known blocking localization/accessibility defects.

## Phase 21 — Theme QA
Test System/Light/Dark on all major screens, including auth and dictionary; check contrast, surfaces, icons, fields, dialogs, system-theme changes.
**Gate:** no unreadable/unthemed major screen.

## Phase 22 — Performance QA
Check startup, scrolling, image caching, memory, rebuilds, API volume, JSON parsing and TTS. Fix material bottlenecks.
**Gate:** document residual limitations.

## Phase 23 — Security/privacy QA
No secrets in client/Git; `.env` ignored; no Mongo URI or AI key in Flutter; hashed passwords where applicable; authorization, validation, rate limits, safe logs/errors, user data isolation.
**Gate:** checklist passes or risks documented.

## Phase 24 — Full integration/regression
Verify routes/providers, localization/theme, assets/local data, auth, Mongo/API, TTS, AI fallback, progress sync, offline/error states. Run tests and resolve conflicts.
**Gate:** integrated app and backend work together.

## Phase 25 — Release candidate
Build APK; test emulator and at least one physical Android device. Test first-launch Urdu, English, RTL/LTR, all themes, auth/logout/session expiry, offline lessons, cloud progress, TTS, content counts/search, pictures, grammar/practice, dictionary AI fallback, and network failures. Document setup, environment variables, limitations and release notes.

## Definition of Done
Figma-aligned; Urdu/English and RTL/LTR work; all themes work; navigation/state/data correct; relevant loading/error/offline states exist; security checks pass; tests/manual checks pass; no obvious crash or fake functionality.

## Agent handoff
```text
PHASE:
STATUS: Complete / Blocked
COMPLETED:
FILES CHANGED:
TESTS:
KNOWN ISSUES / ASSUMPTIONS:
DECISIONS NEEDED:
NEXT OWNER:
```

## Final objective
Build one coherent, professional Urdu-first Android learning product using the confirmed stack, local-first content, hybrid images, database + live AI dictionary, and login/cloud progress—not disconnected agent-generated modules.
