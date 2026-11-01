# English Udaan — Roadmap Status Report

**Date:** 2026-09-27  
**Master roadmap:** `PHASE_INSTRUCTIONS.md` (unchanged)  
**Canonical product context:** `PROJECT_CONTEXT.md`

This report compares the original phase definitions with the current code. It does not claim a phase complete unless the instruction gate is met.

## Completed

| Phase | What is actually complete |
|---|---|
| 0 Discovery | Ownership, routes, contracts, APIs, and open decisions documented |
| 1 Foundation | Flutter/Riverpod/GoRouter app, Urdu default, RTL/LTR, System/Light/Dark, preference persistence, Express health skeleton, tests |

## Partial

| Phase | What exists | What is still outstanding |
|---|---|---|
| 2 Design system | Tokens, reusable widgets, official unchanged logo | Pixel-level Figma match; inspectable Figma data unavailable |
| 4 App shell / Home | Five shell destinations; branded Home; alphabet card works | Learn/Practice/Progress/Profile remain placeholders; Home “Learn words” card has no action |
| 5 Data contracts | Alphabet and sample vocabulary JSON/models/repository | Remaining entities, remote DTOs, versioned local/remote precedence, sync/conflict rules |
| 6 Alphabet + TTS | A–Z overview/detail, previous/next, Urdu meaning, real TTS with failure messaging | Physical Android TTS verification; optional letter images; `phoneticText` field |
| 14 Backend | Express health, validation, centralized errors, `.env.example` | MongoDB/Mongoose, Atlas, indexes, remaining APIs |

## Not started or blocked

| Phase | Status | Reason |
|---|---|---|
| **3 Splash, onboarding, authentication** | **Not started / blocked** | No splash, onboarding, login, register, or session code. Auth method is still undecided. Do not treat `docs/PHASE_3_HANDOFF.md` as Phase 3 completion. |
| 7 Vocabulary | Not started for required counts | 22 two-letter sample words exist; required minimum is 75 |
| 8 Picture learning | Not started | Needs licensed/owned images |
| 9–13 Sentences, grammar, practice, progress, profile | Not started | Placeholders or settings-only |
| 15–17 Auth/cloud/AI | Blocked | Auth, token, conflict, AI, and hosting decisions remain |
| 18 Future boundaries | Watch item | Inactive Home “Learn words” card currently looks like a dead control |
| 19–25 QA/release | Not started | No Figma QA report, device QA, APK release notes |

## Working features to preserve

- Official logo, unchanged
- Urdu default + RTL; English + LTR
- System/Light/Dark themes and persisted preferences
- Home → alphabet overview → letter detail → previous/next → continue with words
- Real `flutter_tts` SpeechService with visible failure state
- 26-letter sample alphabet JSON
- 22-word two-letter sample JSON
- Express `GET /health`
- Existing automated tests

## Current two-letter sample review

Source: `mobile/assets/content/vocabulary_sample.json`  
Version: `0.1.0-sample`  
Count: **22 words**  
Required Phase 7 minimum: **75 two-letter words**

Existing IDs, all unique, all length 2:

`am, an, at, be, by, do, go, he, if, in, is, it, me, my, no, of, on, or, to, up, us, we`

Content notes for owner review, not claimed as final curriculum:

- Function words dominate; that is acceptable for beginners but should be labeled as such.
- `an` mapped to `ایک` is pedagogically simplified; it is an article, not the numeral “one”.
- `by` and `of` use slash-separated Urdu senses; keep or split during review.
- `at` and `on` both currently use `پر`; later review may distinguish them.
- No `category`, `length`, `difficulty`, or `imageRef` fields yet.

## Dependencies and blockers

1. Auth method/provider and token strategy — blocks Phase 3 and 15.
2. Progress conflict rules — blocks cloud progress.
3. AI provider/budget — blocks dictionary fallback.
4. Hosting and MongoDB policy — blocks production backend.
5. Inspectable Figma export — blocks visual QA.
6. Owner review of the 75-word two-letter expansion list — blocks Phase 7 implementation.
7. Image licenses — blocks Phase 8.

## Next recommended task after approval

Implement Phase 7 two-letter vocabulary only:

1. Keep the 22 existing records.
2. Add 53 additional two-letter words to reach 75.
3. Keep data in JSON, not widgets.
4. Add search/filter and a working Home “Learn words” card.
5. Validate counts, IDs, duplicates, word length, Urdu meanings, and examples.
6. Reuse existing TTS, RTL/LTR, and themes.
7. Do not start 3/4/5-letter sections, MongoDB, auth, cloud sync, or AI in that pass unless separately approved.
