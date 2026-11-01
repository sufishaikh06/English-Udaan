# Phase 2 — Design System and Phase 3 Localization Readiness Handoff

**Status:** Foundation ready for the next learning-flow implementation  
**Date:** 2026-09-23

## Inputs reviewed

- Implementation map: `docs/IMPLEMENTATION_MAP.md`
- Figma link supplied in `docs/contents.md`
- Official logo: `images/logo.png`
- Existing Phase 1 Flutter and Express implementation

The supplied Figma URL was reviewed through the available document fetcher, but its publicly fetchable response contained only a generic Figma page marker and no inspectable screen/layout/token data. Therefore, this delivery uses the approved project reference palette and avoids claiming pixel-exact Figma parity. The official logo was copied unchanged into `mobile/assets/images/logo.png` and is rendered by `AppLogo` without recoloring, redrawing, or distortion.

## Phase 2 completed

### Design tokens

`mobile/lib/core/theme/app_theme.dart` centralizes:

- Brand teal: `#159A9C`
- Deep teal: `#087B7D`
- Soft teal: `#DDF5F3`
- Light background: `#F7F9F9`
- Light text: `#172022`
- Secondary text: `#5E6A6D`
- Divider: `#E4E9E9`
- Dark background/surface tokens
- Spacing, radii, component geometry, input, card, button, navigation, and AppBar styles

### Reusable components

`mobile/lib/shared/widgets/app_components.dart` provides:

- `AppLogo` — official asset only
- `AppSectionHeader`
- `LearningCard`
- `AppSearchField`
- `AudioButton` — visual/accessibility foundation; it intentionally has no TTS action yet
- `AppStateView` — reusable empty/error/offline style state

### Foundation UI application

`mobile/lib/main.dart` now applies the shared theme and component set, uses the official logo on Home, and includes a non-fake Home visual foundation showing planned learning and progress cards. Existing Phase 1 routing and preference persistence were retained.

## Phase 3 localization and theme review

- **Urdu is the initial language** through `PreferencesController`.
- Flutter's Urdu `Locale('ur')` and Material localization delegates yield an RTL `Directionality`; the widget test verifies this.
- Switching to English updates the app locale and yields LTR `Directionality`; the widget test verifies this.
- Language and theme selections are persisted with `shared_preferences`.
- System, Light, and Dark themes all use the centralized design-system tokens. A device visual check remains necessary after Figma-specific screens are available.
- App strings currently cover the foundation/navigation/settings experience. Full localization of all later learning, auth, errors, and dictionary states is a continuing Phase 3/20 responsibility.

## Proposed first end-to-end learning flow

This is the next implementation scope, not a claim that it is already functional:

```text
Home
  → “Alphabet” learning card
  → Alphabet overview (A–Z grid/list, local versioned content)
  → Letter detail (letter, lowercase, English example, Urdu meaning,
                   optional image reference, previous/next)
  → SpeechService audio control (real device TTS, voice/failure state)
  → “Continue with words”
  → Small vocabulary lesson (initially a reviewed 2-letter-word set)
  → Completion event stored locally for the later progress model
```

### Required implementation components for that flow

1. `AlphabetItem` and `VocabularyItem` domain models plus validated bundled JSON repositories.
2. Content samples reviewed for accurate Urdu and licensed/owned image references.
3. Alphabet overview/detail routes and `SpeechService` using a maintained Flutter TTS package.
4. A vocabulary lesson route; no MongoDB is required for this local-first flow.
5. Local progress event abstraction; cloud synchronization stays deferred pending the conflict-resolution and authentication decisions.

## Remaining decisions/assets needed

1. A Figma view/export with inspect access or screen captures that expose precise typography, dimensions, spacing, iconography, and dark/RTL variants. The current Figma link could not be inspected programmatically.
2. Confirmation that `images/logo.png` is the final Android-ready official logo asset, including expected clearspace and intended display variants. It has been preserved unchanged.
3. Reviewed starting alphabet and vocabulary content (English, Urdu meanings, examples, phonetic/TTS text, and content version), plus image ownership/licensing metadata if images are supplied.
4. Approval to select a Flutter device-TTS package for Phase 6. No audio behavior has been faked.
5. The previously recorded decisions on authentication/session, progress conflicts, AI provider/cost controls, hosting, and MongoDB policy remain required only for their later phases.

## Validation

| Command | Result |
|---|---|
| `flutter analyze` | Passed — no issues |
| `flutter test` | Passed — 2 tests, including Urdu RTL and English LTR checks |
| `npm test` | Passed — 2 backend health tests |

```text
PHASE: 2 — Design system; Phase 3 localization readiness review
STATUS: Complete for available Figma data; pixel-level Figma QA blocked by inaccessible inspect data
COMPLETED: Centralized theme/tokens, reusable shared widgets, unchanged official logo integration, localized/theme-aware Home foundation, Urdu RTL/English LTR verification.
FILES CHANGED: mobile/pubspec.yaml; mobile/assets/images/logo.png; mobile/lib/core/theme/app_theme.dart; mobile/lib/shared/widgets/app_components.dart; mobile/lib/main.dart; mobile/test/widget_test.dart; docs/PHASE_2_HANDOFF.md
TESTS: flutter analyze; flutter test; npm test — all passed
KNOWN ISSUES / ASSUMPTIONS: Figma link exists but did not expose inspectable screens/tokens using the available fetcher. Existing project reference palette is used; exact Figma comparison is deferred.
DECISIONS NEEDED: Figma inspect/export/screens, logo delivery confirmation, reviewed starter content, image licenses, TTS package approval.
NEXT OWNER: Learning/content + mobile implementation for Phase 5–6 local-first Home → Alphabet → letter detail → small vocabulary flow.
```
