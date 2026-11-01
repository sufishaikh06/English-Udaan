# English Udaan — Complete Project Context

**Product:** English Udaan | **Domain:** englishudaan.com | **Platform:** Android | **Audience:** Urdu-speaking learners of all ages | **Design:** approved Figma prototype and owner-provided logo | **IDE:** Antigravity with multiple AI agents.

## Confirmed architecture (do not change without owner approval)
- **Mobile:** Flutter + Dart
- **State management:** Riverpod
- **Navigation:** GoRouter
- **Backend:** Node.js + Express.js REST API
- **Database:** MongoDB Atlas + Mongoose
- **Learning content:** Local JSON + MongoDB. Bundle foundational content for offline/fast access; remote content supports updates. Use repositories to hide source differences.
- **Images:** Hybrid. Bundle essential optimized assets; serve additional assets remotely. Store image paths/URLs and metadata in MongoDB, never large image binaries.
- **Dictionary:** Hybrid database lookup + live AI fallback, routed through backend. Provider is not selected yet; keep provider-neutral service interface.
- **Accounts:** Login + cloud progress. Auth method/provider and token strategy require explicit technical decision before implementation.
- **Audio:** Android/device TTS behind a reusable SpeechService.
- **Localization:** Urdu default/RTL; English/LTR.
- **Themes:** System, Light, Dark; initial preference System, with in-app control and persisted preference.

## Product vision
A polished, accessible English-learning app: understand in Urdu → learn English → listen → practice → track progress. Must feel like a real product, not a generic template or children's-only game.

## Brand and design
Use the owner's official logo exactly; never redraw, recolor, distort, or replace it. Figma is the UI source of truth. Reference palette:
- Primary teal `#159A9C`; deep teal `#087B7D`
- Light teal `#DDF5F3`; very light teal `#F1FBFA`
- Light background `#F7F9F9`; surface `#FFFFFF`
- Primary text `#172022`; secondary text `#5E6A6D`; divider `#E4E9E9`
Follow Figma for final details; keep category accents restrained.

## Required content/features
1. A–Z and lowercase, pronunciation/TTS, examples, Urdu meanings, optional images, detail/previous-next.
2. Two-letter words: minimum 75.
3. Three-letter words: 100–125.
4. Four-letter words: 125–150.
5. Five-letter words: 150–175.
6. 100+ outdoor things and 100+ indoor things.
7. Fruits, vegetables, domestic/wild animals, birds, vehicles.
8. Shapes, body parts, numbers, colours, directions and everyday objects.
9. Small/simple, medium where useful, and long sentences.
10. Small and larger paragraphs, progressive difficulty.
11. Grammar: parts of speech, nouns, pronouns, verbs, adjectives, adverbs, prepositions, conjunctions, articles, tenses, modals, subject-verb agreement, active/passive, direct/indirect, degrees, sentence structure, common errors, examples and practice.
12. Practice: vocabulary/picture/sentence/grammar quizzes, scoring, accuracy and results.
13. Progress: words learned, lessons completed, accuracy, streak, overall progress, recent activity.
14. Urdu→English dictionary: search, meanings, examples, pronunciation; database-first, AI fallback/contextual explanations.

## AI dictionary rules
Flutter calls Express only; never call the AI provider directly from the app. Backend validates input, searches known entries, then invokes configured AI when appropriate. Add timeout, rate limiting, usage/cost controls, safe errors, and graceful offline/quota/provider-failure states. Keep keys server-side. Distinguish database and AI results where useful. AI provider and operating cost are not yet finalized.

## Accounts and cloud progress
Login and cloud progress are required. Decide auth method before implementation. Hash passwords if password auth is used; never store plaintext. Protect private endpoints and authorize per-user progress. Define local/cloud sync, retry, and conflict resolution. Never trust a client-supplied user ID for authorization.

## Data and images
Use stable IDs and structured records (English, Urdu, category, word length, difficulty, examples, TTS text, local/remote image reference, version). Do not put large datasets in UI widgets. Bundle essential optimized images; remote images need caching, fallbacks, and documented licensing. No arbitrary copyrighted scraping or unstable hotlinks.

## Suggested organization
Flutter: `app/`, `core/` (config, localization, theme, networking, storage, services, errors), `shared/`, and feature modules for auth, home, alphabet, vocabulary, picture learning, sentences, paragraphs, grammar, practice, dictionary, progress, profile, settings.
Backend: `config/`, `middleware/`, `models/`, `routes/`, `controllers/`, `services/`, `validators/`, `utils/`, tests, `.env.example`.
Keep presentation, state, repositories, and data sources separated. No raw HTTP calls in widgets or DB queries in route handlers.

## Navigation
Home, Learn, Practice, Progress, Profile. Major features ideally within 2–3 taps.

## Accessibility/performance
Readable text, generous touch targets, contrast, clear audio controls, no reliance on color alone, restrained animation. Lazy-load lists, optimize/cache images, avoid needless requests/rebuilds. Foundational bundled lessons should work offline.

## Localization
Urdu is the first-launch default and must use true RTL. English uses LTR. Localize all UI, review Urdu spelling/punctuation, and test mixed-direction strings. Approved examples: `شروع کریں`, `سیکھیں`, `پریکٹس`, `پیش رفت`, `پروفائل`, `حروف تہجی`, `الفاظ سیکھیں`, `تصاویر سے سیکھیں`, `انگریزی گرامر`, `اردو سے انگریزی ڈکشنری`, `روشن`, `تاریک`, `سسٹم کے مطابق`, `لفظ تلاش کریں`, `تلفظ سنیں`.

## Future scope
English→Urdu, richer AI/voice input, videos, premium content, subscriptions/payments, admin/CMS and advanced analytics. Do not fake features or payments; obtain separate approval.

## Commercial context
Initial quote ₹10,500; negotiation target ₹10,000; minimum ₹9,500. First-year technical support free. Maintenance from Year 2: ₹2,000/year. Maintenance excludes major features/redesigns, AI usage, video hosting, payments/subscriptions, major restructuring, large content entry, third-party/cloud charges, and Play Store fees.

## Quality standard
Professional, bilingual, Urdu-first, RTL-aware, theme-aware, modular, secure, maintainable, and client-presentable. Never prioritize agent speed over correctness, security, Urdu quality, or Figma consistency.
