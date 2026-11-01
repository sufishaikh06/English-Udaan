# English Udaan — Five-Letter Vocabulary Implementation

## Objective

Implement the **five-letter English vocabulary section** in the existing English Udaan Flutter app.

Target **150–175 unique five-letter English words**.

This is the next scoped segment of Phase 7. Do not begin picture learning, backend integration, authentication, AI dictionary, or unrelated roadmap work.

---

## 1. Read the project documentation first

Before making any changes, read:

- `PHASE_INSTRUCTIONS.md` — master roadmap
- `PROJECT_CONTEXT.md` — project architecture and decisions
- `docs/IMPLEMENTATION_MAP.md` — current implementation status
- `docs/PHASE_7_HANDOFF.md` — two-letter vocabulary
- `docs/PHASE_7_THREE_LETTER_HANDOFF.md` — three-letter vocabulary
- `docs/PHASE_7_FOUR_LETTER_HANDOFF.md` — latest four-letter implementation

Inspect the existing implementation before editing it.

**Do not rewrite working vocabulary functionality. Extend the existing architecture.**

---

## 2. Five-letter vocabulary content

Add **150–175 valid, unique five-letter English words** to:

`mobile/assets/content/vocabulary_sample.json`

Requirements:

- Every word must contain exactly **5 English letters**.
- Words must be unique.
- IDs must be unique and stable.
- Follow the existing vocabulary JSON schema exactly.
- Include the required English word, Urdu meaning, English example, and Urdu example fields used by the current schema.
- Use common, age-appropriate vocabulary suitable for Urdu-speaking English learners.
- Avoid duplicate words already present in the five-letter segment.
- Preserve all existing 2-letter, 3-letter, and 4-letter entries.
- Do not unnecessarily change the schema version.

### Urdu content

Provide Urdu meanings and example translations according to the existing content structure.

Do not fabricate uncertain translations.

If any Urdu translation is questionable, flag it clearly in the handoff for owner review rather than silently presenting uncertain content as authoritative.

---

## 3. Repository validation

Extend `LearningRepository` using the same architecture already established for the previous vocabulary segments.

The five-letter segment must be validated **independently**.

Validation must ensure:

- Count is between **150 and 175**.
- Every five-letter word contains exactly 5 letters.
- IDs are unique.
- Words are unique.
- Required fields exist.
- Existing 2-letter, 3-letter, and 4-letter validation continues to work.
- Invalid five-letter entries cannot silently pass validation.

Do not weaken or bypass validation used by the existing vocabulary segments.

---

## 4. Vocabulary UI

Extend the existing `VocabularyScreen`.

Add the five-letter section to the existing segmented vocabulary selector.

Use the existing naming/style convention, with the Urdu label appropriate to the current UI, e.g.:

**5 — پانچ حرفی الفاظ**

Reuse the existing:

- Section switching
- Search
- Vocabulary count
- Empty state
- Word cards
- Urdu RTL presentation
- English LTR presentation
- TTS behavior
- Completion/progress behavior
- Theme support

Do not redesign the vocabulary screen.

The five-letter section must load independently and must not interfere with the existing 2-, 3-, or 4-letter sections.

---

## 5. Completion tracking

Create/use a **separate completion key** for five-letter vocabulary.

Follow the existing naming convention established for the previous sections.

For example, if the existing convention is:

`lesson.vocabulary.two-letter.complete`

`lesson.vocabulary.three-letter.complete`

`lesson.vocabulary.four-letter.complete`

then use the corresponding five-letter key:

`lesson.vocabulary.five-letter.complete`

Do not overwrite or reuse another section's completion key.

Verify that:

- Completing five-letter vocabulary does not mark other sections complete.
- Existing completion states remain intact.
- Progress persists after app restart.

---

## 6. Tests

Add or update tests for the five-letter segment.

At minimum verify:

### Repository tests
- Five-letter count is **150–175**.
- Every word has exactly five letters.
- IDs are unique.
- Words are unique.
- Required fields are present.
- Existing 2/3/4-letter validation still passes.

### Widget/UI tests
Verify where practical that:

- Five-letter section appears in the vocabulary selector.
- Five-letter vocabulary loads when selected.
- Search works against five-letter content.
- The displayed count is correct.
- Existing sections remain selectable.
- RTL behavior remains intact.

### Progress tests
Verify five-letter completion uses its own persistence key and does not affect other sections.

---

## 7. Run validation

Run the appropriate project checks:

```text
flutter pub get
flutter analyze
flutter test
npm test
```

Report the **actual result** of every command.

Do not claim a test passed unless it actually passed.

Do not hide failures by weakening assertions or removing tests.

### Existing learning-flow timeout

There has previously been a `pumpAndSettle()` timeout in:

`learning_flow_test.dart`

related to asynchronous/FutureBuilder behavior.

Do not simply hide or delete this test.

If it remains an issue:

1. Determine whether the five-letter changes caused or affected it.
2. Keep the existing functionality intact.
3. Make only a minimal, justified test-side improvement if appropriate.
4. Clearly document whether the issue is pre-existing or introduced by this task.
5. Do not claim the full Flutter test suite passes if that test still fails.

---

## 8. TTS

Reuse the existing real-device TTS implementation.

Do not replace it with mocked or artificial audio.

If physical-device TTS is not tested during this task, explicitly state:

**Physical-device TTS was not retested during this implementation.**

Do not claim device verification without actually performing it.

Devices without a supported TTS voice must continue to receive the existing graceful fallback/error behavior.

---

## 9. Preserve existing functionality

The following must remain unchanged and operational:

- 2-letter vocabulary
- 3-letter vocabulary
- 4-letter vocabulary
- Existing search behavior
- Existing TTS behavior
- Existing completion persistence
- Urdu RTL support
- English LTR support
- Existing theme system
- Official logo
- Existing app architecture

Do not perform unrelated refactoring.

---

## 10. Documentation

Update:

`docs/IMPLEMENTATION_MAP.md`

Then create:

`docs/PHASE_7_FIVE_LETTER_HANDOFF.md`

The handoff should document:

### Implementation
- Files changed
- Five-letter vocabulary count
- Schema used
- Repository validation
- UI changes
- Completion key

### Validation
- `flutter analyze` result
- `flutter test` result
- `npm test` result
- Any remaining failures
- Whether physical-device TTS was tested

### Content review
- Any Urdu translations requiring owner review
- Any content limitations or concerns

### Regression
Explicitly confirm whether 2-, 3-, and 4-letter functionality remained intact.

### Remaining roadmap
Identify the next task from `PHASE_INSTRUCTIONS.md`.

---

## 11. Scope restrictions

Do **not**:

- Start picture-learning implementation.
- Add vocabulary images.
- Start MongoDB integration.
- Start authentication.
- Start cloud sync.
- Start live AI dictionary.
- Start subscriptions.
- Start videos.
- Redesign the existing vocabulary UI.
- Replace the current architecture.
- Modify the official logo.
- Rewrite working 2/3/4-letter functionality.
- Claim the entire Phase 7 is complete unless the master roadmap actually defines it as complete after this segment.

This task is **only the five-letter vocabulary segment**.

---

## Completion criteria

Stop when all of the following are true:

1. `vocabulary_sample.json` contains **150–175 valid five-letter words**.
2. Five-letter validation is independent and enforced.
3. Five-letter vocabulary appears in the existing vocabulary UI.
4. Search works.
5. TTS integration is preserved.
6. Five-letter completion persistence is independent.
7. Existing 2-, 3-, and 4-letter functionality remains intact.
8. Tests have been run and actual results documented.
9. `IMPLEMENTATION_MAP.md` is updated.
10. `docs/PHASE_7_FIVE_LETTER_HANDOFF.md` is created.
11. No unrelated roadmap work has been started.

At the end, provide a concise implementation report containing:

- Final five-letter word count
- Files changed
- Tests and actual results
- Any unresolved issues
- Whether physical-device TTS was tested
- Confirmation that 2/3/4-letter sections were preserved
- Recommended next roadmap task

**Stop after completing this scope.**

# English Udaan — Phase 8: Picture Learning Implementation

## Objective

Implement **Phase 8 — Picture Learning** for English Udaan.

The goal is to introduce image-based vocabulary learning for common visual categories while preserving all existing Phase 7 vocabulary functionality.

This task should establish a clean, scalable picture-learning foundation that can later support larger content sets, remote images, MongoDB metadata, and future content expansion.

**Do not start Phase 9 sentence/paragraph learning or backend integration.**

---

# 1. Read the project documentation first

Before making any changes, read:

- `PHASE_INSTRUCTIONS.md` — master roadmap
- `PROJECT_CONTEXT.md` — architecture and product decisions
- `docs/IMPLEMENTATION_MAP.md` — current implementation status
- `docs/PHASE_7_HANDOFF.md`
- `docs/PHASE_7_THREE_LETTER_HANDOFF.md`
- `docs/PHASE_7_FOUR_LETTER_HANDOFF.md`
- `docs/PHASE_7_FIVE_LETTER_HANDOFF.md`

Also inspect the current vocabulary implementation and existing reusable UI components before writing code.

### Important

Phase 7 is now considered functionally complete.

Do not rewrite the working 2-, 3-, 4-, or 5-letter vocabulary implementation.

There is a known `learning_flow_test.dart` asynchronous `pumpAndSettle()` issue documented by previous work. Do not silently delete, disable, or hide it.

---

# 2. Phase 8 scope

Implement the first picture-learning foundation for common visual vocabulary.

The picture-learning foundation should support categories such as:

- Fruits
- Vegetables
- Domestic animals
- Wild animals
- Birds
- Vehicles
- Body parts
- Indoor things
- Outdoor things

Use the existing roadmap and project documentation to determine the exact initial scope if it specifies one.

Do not attempt to populate every possible category with hundreds of images in this task unless the roadmap explicitly requires it.

The architecture should make additional categories easy to add later.

---

# 3. Image strategy

Follow the project's existing cost-sensitive hybrid image strategy.

The intended architecture is:

### Local/bundled assets
Use optimized local assets for high-frequency, foundational learning content where appropriate.

### Remote images
Allow the data model to support remote image URLs for content that should not be bundled into the application.

### Future MongoDB
Keep the content model compatible with the future backend architecture.

MongoDB should eventually store **image references/metadata**, not large binary image files.

Do not implement MongoDB in this phase.

Do not introduce a paid image service or external image API without explicit approval.

---

# 4. Image data model

Create or extend a clean picture-learning content model following the existing project conventions.

Each picture-learning item should support the information actually needed by the UI, such as:

- Stable ID
- Category
- English name
- Urdu name/meaning
- Image source/type
- Local asset path when applicable
- Remote URL when applicable
- Optional example or supporting metadata if the existing architecture requires it

Do not create duplicate representations of the same content unnecessarily.

Prefer a model that can later map cleanly to MongoDB documents.

### Image source handling

The model should distinguish between:

- Local asset
- Remote image

The UI should not need to know how the source is stored internally.

Create a reusable image resolver/provider abstraction if appropriate.

---

# 5. Local content

Create the initial picture-learning content in the project's existing local content architecture.

Use stable IDs.

Do not embed large binary image data into JSON.

If local images are used:

- Store them under the appropriate `mobile/assets/images/` or existing asset directory.
- Update `pubspec.yaml` only as necessary.
- Keep asset organization predictable by category.
- Use optimized image dimensions/file sizes suitable for mobile learning.
- Avoid unnecessary duplicate images.

If suitable image files are not already available in the project, **do not invent fake asset paths and claim the images exist**.

Instead, establish the content/data architecture and clearly document any image assets that still require sourcing or approval.

---

# 6. Picture-learning UI

Create a dedicated picture-learning experience using the existing English Udaan design system.

Reuse existing:

- Theme
- Typography
- Cards
- Buttons
- Spacing
- RTL/LTR behavior
- Navigation patterns
- TTS behavior where applicable

The UI should be simple and child/family friendly.

Each picture-learning card should make the relationship between image, English word, and Urdu meaning obvious.

At minimum, support:

- Category selection
- Picture card/grid/list
- English label
- Urdu label
- Tap-to-hear pronunciation
- Basic empty/loading/error states

Do not redesign the overall app shell.

---

# 7. Category navigation

Provide a scalable way to navigate picture categories.

For example:

- Fruits
- Vegetables
- Animals
- Birds
- Vehicles
- Body Parts
- Indoor
- Outdoor

Use the exact category structure required by the roadmap where specified.

Do not create separate hard-coded screens for every category if a reusable category-based screen can handle them.

Prefer:

**Category → content collection → reusable picture card**

rather than:

**Category → completely separate implementation**

---

# 8. Search and filtering

If the existing picture-learning requirements call for search/filtering, implement it using the same principles as vocabulary search.

Search should work against:

- English name
- Urdu name where practical

Do not introduce complex search infrastructure for the initial local dataset.

Keep the implementation lightweight and offline-friendly.

---

# 9. TTS

Reuse the existing `flutter_tts` implementation.

When a learner taps a picture/word:

- Pronounce the English word.
- Handle unavailable TTS voices gracefully.
- Do not crash if TTS fails.

Do not replace the existing TTS implementation.

Do not claim physical-device TTS verification unless it is actually performed during this task.

---

# 10. Progress tracking

If Phase 8 requires picture-learning completion/progress, implement it using the same persistence architecture already used by the vocabulary lessons.

Progress must be scoped independently by category/lesson.

Do not overwrite Phase 7 completion keys.

For example, follow the existing naming convention rather than inventing a completely different persistence system.

If progress is intentionally deferred by the master roadmap, document that rather than implementing it prematurely.

---

# 11. Offline behavior

Picture learning should remain functional for local/bundled content without an internet connection.

For remote images:

- Provide graceful loading state.
- Provide graceful error/fallback state.
- Never allow a broken remote image to crash the learning screen.

Do not introduce a mandatory network dependency for the entire picture-learning feature.

---

# 12. Image caching

If the project roadmap specifically requires image caching at this stage, implement a lightweight and maintainable solution.

Otherwise, keep the abstraction ready for caching without introducing unnecessary dependencies.

Do not add a large image-cache framework simply for future speculation.

Any dependency added must be justified and documented.

---

# 13. Tests

Add appropriate tests covering:

### Data/repository
- Picture content loads successfully.
- IDs are unique.
- Required fields are present.
- Categories are valid.
- Local/remote source handling is validated.
- Invalid content fails safely.

### UI
- Category selection works.
- Picture content renders.
- English and Urdu labels render correctly.
- RTL/LTR behavior remains correct.
- Empty/loading/error states work.
- TTS interaction is wired correctly.

### Regression
Verify that existing Phase 7 vocabulary functionality remains intact.

Do not remove existing tests.

---

# 14. Run project validation

Run:

```text
flutter pub get
flutter analyze
flutter test
npm test
```

Report the actual result of each command.

Do not claim `flutter test` passed if `learning_flow_test.dart` still fails.

The previously documented `pumpAndSettle()` issue must remain visible unless it is genuinely resolved.

If you modify that test:

- Explain exactly why.
- Keep the change minimal.
- Do not weaken assertions merely to make the suite pass.

---

# 15. Documentation

Update:

`docs/IMPLEMENTATION_MAP.md`

Create:

`docs/PHASE_8_PICTURE_LEARNING_HANDOFF.md`

The handoff must include:

### Implementation
- Files changed
- Data model
- Categories implemented
- Number of picture-learning items
- Local vs remote image strategy
- UI implementation
- TTS integration
- Progress implementation, if applicable

### Testing
- `flutter analyze`
- `flutter test`
- `npm test`
- Individual tests added/changed
- Actual results

### Assets
Clearly list:

- Existing image assets reused
- New image assets added
- Assets still required
- Any image licensing/source considerations that require owner review

Do not claim an image is available when it was not actually added.

### Known issues
Document:
- Existing `learning_flow_test.dart` timeout if still present
- Missing image assets
- Translation/content review items
- Any other unresolved implementation issue

### Next step
Identify the next task according to `PHASE_INSTRUCTIONS.md`.

---

# 16. Scope restrictions

Do NOT:

- Implement MongoDB.
- Implement authentication.
- Implement cloud synchronization.
- Implement live AI dictionary.
- Implement subscriptions.
- Implement video lessons.
- Start Phase 9 sentences/paragraphs.
- Rewrite Phase 7 vocabulary.
- Replace the existing app architecture.
- Replace the official logo.
- Introduce unnecessary third-party services.
- Download or embed copyrighted image collections without appropriate rights.
- Invent image URLs or fake local asset files.
- Claim pixel-perfect Figma matching unless the actual Figma design can be inspected.
- Claim physical-device testing that was not performed.

---

# 17. Important implementation principle

Before creating new abstractions, inspect what already exists.

Prefer extending existing:

- Repository patterns
- Models
- Content loading
- Shared widgets
- Theme components
- TTS service
- Persistence
- Routing

Avoid duplicate infrastructure.

The implementation should feel like a natural extension of English Udaan rather than a separate feature system.

---

# Completion criteria

Phase 8's initial implementation is complete when:

1. A reusable picture-learning data model exists.
2. The initial roadmap-required categories are implemented.
3. Picture content loads from the project's local content architecture.
4. Local/remote image handling is structured for future expansion.
5. Picture cards display English + Urdu labels.
6. English pronunciation uses the existing TTS system.
7. Loading/error/empty states are handled safely.
8. RTL/LTR behavior is correct.
9. Existing Phase 7 vocabulary remains intact.
10. Tests and validation are run and honestly reported.
11. `IMPLEMENTATION_MAP.md` is updated.
12. `docs/PHASE_8_PICTURE_LEARNING_HANDOFF.md` is created.
13. No Phase 9/backend/auth/AI work is started.

At the end, provide a concise implementation report with:

- Categories implemented
- Number of picture items
- Image assets added/available/missing
- Files changed
- Tests and actual results
- TTS testing status
- Known issues
- Confirmation that Phase 7 remains intact
- Recommended next roadmap task

**Stop after completing this Phase 8 scope.**

# English Udaan — Phase 9: Sentences & Paragraphs

## Objective

Implement **Phase 9 — Sentences & Paragraphs** in the existing English Udaan Android application.

Build a structured learning experience that helps Urdu-speaking learners progress from simple English sentences to longer sentences and short paragraphs, with Urdu translations and pronunciation support.

**This task covers Phase 9 only.** Do not begin grammar lessons, practice exercises, backend integration, authentication, cloud sync, or AI dictionary implementation.

## 1. Read documentation before coding

Read these files first:

- `PHASE_INSTRUCTIONS.md` — master roadmap and Phase 9 requirements
- `PROJECT_CONTEXT.md` — project architecture and product decisions
- `docs/IMPLEMENTATION_MAP.md` — current implementation status
- `docs/PHASE_7_HANDOFF.md`
- `docs/PHASE_7_THREE_LETTER_HANDOFF.md`
- `docs/PHASE_7_FOUR_LETTER_HANDOFF.md`
- `docs/PHASE_7_FIVE_LETTER_HANDOFF.md`
- `docs/PHASE_8_PICTURE_LEARNING_HANDOFF.md`

Inspect the existing learning models, repository, navigation, reusable UI components, localization, TTS service, and progress persistence before making changes.

If the master roadmap specifies different or additional Phase 9 requirements, follow the master roadmap and document any discrepancy before implementation.

Do not rewrite working features or duplicate existing infrastructure.

## 2. Content requirements

Create structured, local sentence-and-paragraph learning content using the existing content-loading conventions.

Support these learning types:

1. **Small sentences:** short, beginner-friendly English sentences.
2. **Long sentences:** more developed sentences appropriate for learners who have mastered basic constructions.
3. **Short paragraphs:** connected English sentences forming a coherent passage.

Each content item should follow the established schema and include, as applicable:

- Stable, unique ID
- Content type or lesson category
- English title or text
- Urdu title or translation
- Appropriate difficulty level
- Lesson ordering or sequence
- Any additional fields required by the existing architecture

For paragraphs, provide the complete English passage and a complete Urdu translation.

Use natural, grammatically correct English and accurate, natural Urdu translations. Avoid literal translations that distort meaning.

Do not fabricate translations when uncertain. Flag questionable translations in the handoff for owner review.

### Content quantity

Inspect `PHASE_INSTRUCTIONS.md` and implement the exact Phase 9 quantities and coverage defined there.

If the master roadmap does not specify quantities, establish a reasonable initial dataset, document the chosen scope, and keep it easy to expand.

Do not claim that the entire Phase 9 content requirement is complete unless the required quantities and content types have actually been implemented.

## 3. Content storage and validation

Use the existing local JSON/content architecture.

Follow the project's established file organization and schema conventions. Avoid creating a parallel content system.

Add repository validation for:

- Valid JSON structure
- Unique, stable IDs
- Required fields
- Supported content types
- Non-empty English text
- Non-empty Urdu translations
- Valid lesson ordering and difficulty values, where applicable
- Correct paragraph and sentence data structures

Keep content versions consistent with existing conventions. Change the schema version only if necessary and document the reason.

Do not implement MongoDB or a remote content API in this phase.

## 4. User interface

Build a dedicated sentence-and-paragraph learning experience that matches the existing English Udaan design system.

Reuse existing theme, typography, cards, spacing, navigation, and localization patterns.

The interface should support:

- A landing screen or section selector for the available learning types
- A list of lessons or learning items
- A clear English text presentation
- A corresponding Urdu translation
- Navigation between lessons or items
- Loading, empty, and error states appropriate to local content

Make the learning experience easy to understand for beginners and suitable for a broad age range.

Do not redesign the app shell or introduce unrelated visual changes.

### Translation presentation

Keep English text left-to-right and Urdu text right-to-left.

Use the project's existing localization and direction-handling conventions. Do not hard-code the entire app into one text direction.

The learner should be able to distinguish the English source text from its Urdu meaning clearly.

## 5. Text-to-speech

Reuse the existing `flutter_tts` integration.

Provide a pronunciation action for English sentences and, where appropriate, paragraph text.

Requirements:

- Speak the English text using the existing TTS service.
- Preserve existing error handling and unsupported-voice fallback behavior.
- Avoid overlapping speech when a learner quickly selects another item.
- Do not introduce another TTS package unless a demonstrated technical need exists and approval is obtained.

Do not claim physical-device TTS verification unless it is actually performed during this task.

## 6. Progress persistence

Inspect the existing vocabulary and picture-learning completion mechanisms before implementing progress.

If Phase 9 requires progress tracking, use the existing persistence architecture and create independent keys for sentence and paragraph lessons.

Progress in this feature must not overwrite completion records for:

- Alphabet lessons
- Two-letter vocabulary
- Three-letter vocabulary
- Four-letter vocabulary
- Five-letter vocabulary
- Picture-learning categories

If the master roadmap defers progress tracking, document that decision instead of implementing it prematurely.

## 7. Navigation

Integrate the feature using the existing GoRouter structure and naming conventions.

Add routes only as necessary for the Phase 9 experience.

Ensure navigation works from the appropriate existing learning entry point without disrupting Home, Learn, Practice, Progress, or Profile.

Do not create redundant routes or replace the existing routing architecture.

## 8. Tests

Add or update tests using the project's existing testing conventions.

### Repository tests

Verify:

- Content loads successfully.
- All required content types are represented.
- IDs are unique.
- Required English and Urdu fields are present.
- Paragraphs contain complete text and translations.
- Content ordering and difficulty values are valid.
- Invalid content fails safely.

### Widget tests

Verify, where practical:

- The Phase 9 entry point renders.
- Learning-type selection works.
- Sentence and paragraph content displays correctly.
- Urdu translations are visible.
- English and Urdu text directions are correct.
- Lesson navigation works.
- Pronunciation controls are connected to the existing TTS service.
- Empty and error states behave appropriately.

### Regression tests

Verify that the existing alphabet, vocabulary, picture-learning, theme, localization, and navigation functionality remains intact.

Do not remove existing tests or weaken assertions simply to obtain a passing result.

## 9. Existing asynchronous test issue

Previous handoffs reported a `pumpAndSettle()` timeout in `learning_flow_test.dart` related to asynchronous content loading and `FutureBuilder` behavior.

Inspect the current test and existing documentation before changing it.

Determine whether the issue affects Phase 9 or is independent of this implementation.

If the issue remains:

- Preserve the failing test.
- Make only a minimal, justified test improvement if appropriate.
- Document the actual failure and investigation.
- Do not attribute it to Phase 9 without evidence.
- Do not claim the entire Flutter test suite passed if it still fails.

## 10. Run validation

Run the relevant commands:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `npm test`

Report the actual outcome of each command.

If individual tests pass but the full Flutter test suite fails, clearly distinguish those results.

Do not claim device testing, complete regression coverage, or a clean test suite unless the evidence supports those claims.

## 11. Documentation and handoff

Update:

`docs/IMPLEMENTATION_MAP.md`

Create:

`docs/PHASE_9_SENTENCES_PARAGRAPHS_HANDOFF.md`

The handoff must include:

### Implementation
- Summary of the feature
- Files changed
- Content files and schema
- Number of small sentences, long sentences, and paragraphs
- Lesson navigation and UI behavior
- TTS integration
- Progress implementation, if applicable

### Validation
- Commands executed
- Actual test results
- Failures and unresolved issues
- Regression testing performed

### Content review
- Translation issues requiring owner review
- Any roadmap requirements not completed
- Any limitations in the initial content dataset

### Next steps
Identify the next task according to `PHASE_INSTRUCTIONS.md`.

Keep the master roadmap as the source of truth. Update its status only according to the existing documentation conventions and actual implementation results.

## 12. Scope restrictions

Do not:

- Start Phase 10 grammar implementation.
- Start Phase 11 practice exercises.
- Implement MongoDB or remote content APIs.
- Implement authentication or cloud sync.
- Implement live AI dictionary functionality.
- Add subscriptions or video lessons.
- Rewrite existing vocabulary or picture-learning features.
- Replace the existing architecture.
- Change the official logo.
- Introduce unnecessary dependencies.
- Claim that unimplemented content or tests are complete.

## Completion criteria

Phase 9 is complete when:

1. All Phase 9 requirements in `PHASE_INSTRUCTIONS.md` are implemented.
2. Small sentences, long sentences, and paragraphs are supported as required.
3. English and Urdu content follows the established schema.
4. Repository validation and appropriate tests are implemented.
5. The learning UI and navigation work with the existing architecture.
6. Existing TTS behavior is preserved.
7. Progress is handled according to the master roadmap.
8. Existing Phase 6–8 functionality remains intact.
9. Validation results and unresolved issues are accurately documented.
10. `docs/IMPLEMENTATION_MAP.md` is updated.
11. `docs/PHASE_9_SENTENCES_PARAGRAPHS_HANDOFF.md` is created.

At completion, provide a concise report with content counts, files changed, test results, known issues, regression status, and the recommended next roadmap task.

**Stop after Phase 9. Do not begin Phase 10.**

# English Udaan — Phase 10: Complete English Grammar

## Objective

Implement **Phase 10 — Grammar** in the existing English Udaan Android application.

Build a structured English grammar learning module for Urdu-speaking learners, progressing from beginner foundations toward advanced grammar.

The learning experience should include clear English explanations, natural Urdu explanations/translations, practical examples, and English pronunciation through the existing TTS service.

**This task covers Phase 10 only.** Do not start practice exercises, progress dashboards, backend integration, authentication, or AI dictionary implementation.

---

## 1. Read project documentation first

Before coding, read:

- `PHASE_INSTRUCTIONS.md` — master roadmap and Phase 10 requirements
- `PROJECT_CONTEXT.md` — architecture and product decisions
- `docs/IMPLEMENTATION_MAP.md` — current implementation status
- `docs/PHASE_7_HANDOFF.md`
- `docs/PHASE_7_THREE_LETTER_HANDOFF.md`
- `docs/PHASE_7_FOUR_LETTER_HANDOFF.md`
- `docs/PHASE_7_FIVE_LETTER_HANDOFF.md`
- `docs/PHASE_8_PICTURE_LEARNING_HANDOFF.md`
- `docs/PHASE_9_SENTENCES_PARAGRAPHS_HANDOFF.md`

Inspect the existing learning models, repository, navigation, sentence-learning screen, theme components, localization, and speech service.

Follow the master roadmap if it specifies requirements not explicitly listed in this prompt. Document any discrepancy rather than silently changing scope.

**Do not rewrite working features or create duplicate infrastructure.**

---

## 2. Grammar curriculum

Create a structured curriculum organized by topic and difficulty.

Use the exact categories and content quantities specified in `PHASE_INSTRUCTIONS.md`.

If the roadmap does not define exact quantities, create a clearly documented starter curriculum that is easy to expand.

The curriculum should be organized progressively, for example:

### Level 1 — Beginner foundations
- Alphabet and basic word/sentence concepts, linking to existing lessons where appropriate
- Nouns
- Pronouns
- Verbs
- Adjectives
- Articles
- Singular and plural nouns
- Basic sentence structure
- Subject and predicate

### Level 2 — Elementary grammar
- Present simple
- Present continuous
- Past simple
- Future forms
- Helping verbs
- Subject–verb agreement
- Adverbs
- Prepositions
- Conjunctions
- Question formation
- Negative sentences

### Level 3 — Intermediate grammar
- Present perfect and other required perfect forms
- Past continuous and other relevant continuous forms
- Modal verbs
- Comparatives and superlatives
- Countable and uncountable nouns
- Determiners
- Clauses and phrases
- Active and passive voice
- Direct and indirect speech
- Conditional sentences

### Level 4 — Advanced grammar
- Perfect and perfect-continuous tense distinctions
- Advanced conditionals
- Relative clauses
- Reported speech in more complex contexts
- Complex sentence construction
- Common grammar errors and corrections
- Other advanced topics required by the master roadmap

This list is a curriculum guide, not permission to ignore the roadmap or mark every topic complete without implementing its content.

Avoid unnecessary duplication with the existing alphabet and sentence-learning modules. Reuse or reference existing lessons where appropriate.

---

## 3. Grammar lesson content

Use the existing local JSON/content architecture.

Each grammar lesson should follow the project's conventions and include the fields needed by the UI, such as:

- Stable, unique lesson ID
- Grammar topic and category
- Difficulty or learning level
- English topic title
- Urdu topic title
- English explanation
- Urdu explanation
- Correct English examples
- Urdu translations of examples
- Incorrect examples and corrections where appropriate
- Lesson ordering
- TTS text or suitable source text for pronunciation

Use a reusable structure for examples instead of placing every example into one unstructured string.

The schema should support multiple examples per topic and future curriculum expansion.

### Content quality

- Use accurate, natural English grammar.
- Use clear Urdu explanations suitable for Urdu-speaking learners.
- Explain technical terminology in accessible language.
- Include practical everyday examples.
- Clearly distinguish rules from exceptions.
- Avoid teaching incorrect grammar as a universal rule.
- Flag uncertain Urdu translations for owner review.
- Avoid repetitive or filler lessons added only to meet a quantity target.

Do not claim the entire English grammar curriculum is complete if only a starter dataset has been implemented.

---

## 4. Repository and validation

Extend the existing learning repository using the current architecture.

Implement validation for:

- Valid JSON structure
- Unique IDs
- Required fields
- Supported categories and difficulty levels
- Valid lesson ordering
- Non-empty English and Urdu explanations
- Correct example structures
- Required translations for examples
- Corrected examples when a lesson defines an error/correction exercise

Invalid content must fail safely and produce useful diagnostics.

Preserve the existing content schema conventions. Change the schema version only if necessary and document why.

Do not implement MongoDB or remote APIs in this phase.

---

## 5. Grammar learning UI

Create a dedicated grammar-learning experience consistent with the existing English Udaan design system.

Reuse existing:

- Theme and color system
- Typography and spacing
- Cards and buttons
- Navigation conventions
- Reusable learning components
- RTL/LTR handling
- Speech service
- Local content-loading patterns

The UI should support:

1. Grammar landing page
2. Learning-level or category selection
3. Topic list with titles and difficulty
4. Grammar lesson detail screen
5. English explanation and Urdu explanation
6. English examples with Urdu translations
7. Correct/incorrect examples where appropriate
8. Navigation between lessons

Use readable layouts suitable for a wide range of ages and screen sizes.

Do not redesign the overall app shell.

---

## 6. English and Urdu localization

Preserve English left-to-right and Urdu right-to-left text behavior.

Use the project's existing direction-handling conventions.

Ensure:

- English examples render LTR.
- Urdu explanations and translations render RTL.
- Mixed-language cards remain readable.
- Long explanations wrap without clipping.
- Text scales appropriately.
- Existing language and theme preferences remain functional.

Do not hard-code the entire application to one language direction.

---

## 7. Text-to-speech

Reuse the existing `SpeechService` / `DeviceSpeechService` implementation.

Allow learners to hear relevant English grammar examples and other appropriate English text.

Requirements:

- Pronounce English text through the existing service.
- Handle rapid changes between examples safely.
- Preserve unsupported-voice and error fallback behavior.
- Avoid adding another TTS dependency.

Do not claim physical-device TTS verification unless you actually test it during this task.

---

## 8. Navigation and integration

Integrate grammar into the existing GoRouter and learning navigation structure.

Add only the routes required for grammar.

Ensure the grammar entry point is accessible through the appropriate existing learning interface or Home screen.

Do not break:

- Home
- Alphabet learning
- Two-letter vocabulary
- Three-letter vocabulary
- Four-letter vocabulary
- Five-letter vocabulary
- Picture learning
- Sentences and paragraphs
- Practice, Progress, and Profile placeholders
- Existing localization and theme settings

Do not replace the existing routing architecture.

---

## 9. Progress tracking

Inspect the master roadmap and existing implementation before adding progress tracking.

If Phase 10 requires lesson completion persistence, use the existing persistence architecture with grammar-specific keys.

Grammar completion must not overwrite progress for alphabet, vocabulary, picture learning, or sentences.

If progress tracking belongs to a later roadmap phase, do not implement it prematurely. Document the intended future integration.

---

## 10. Testing

Add tests following existing project conventions.

### Repository tests
Verify:

- Grammar content loads.
- Required categories and difficulty levels are represented.
- IDs are unique.
- Required fields are present.
- English and Urdu explanations are non-empty.
- Example structures and translations are valid.
- Lesson ordering is correct.
- Invalid records are rejected appropriately.

### Widget tests
Verify, where practical:

- Grammar entry point renders.
- Category/level selection works.
- Topic lists display correctly.
- Lesson details display English and Urdu explanations.
- Examples and translations are visible.
- RTL/LTR layout remains correct.
- Lesson navigation works.
- Pronunciation controls invoke the existing speech service.

### Regression tests
Preserve existing tests and verify the current learning features remain intact.

Do not delete or weaken tests merely to obtain a passing result.

---

## 11. Existing Flutter test failures

The Phase 9 handoff reports four failures in `learning_flow_test.dart` involving Home navigation, vocabulary content, search, and completion.

Before changing tests:

1. Inspect the current failure output and test implementation.
2. Determine whether the failures are caused by the test harness, asynchronous loading, layout assumptions, or a production regression.
3. Keep the investigation scoped to the current task.
4. Do not assume the failures are harmless simply because they were reported previously.
5. Do not claim they are resolved unless the relevant tests pass.

Make minimal, justified fixes where appropriate. Never hide failures by disabling tests or weakening assertions.

---

## 12. Run validation

Run the relevant commands:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `npm test`

Report actual outcomes for each command.

Clearly distinguish individual passing tests from a failing full test suite.

Do not claim a clean regression suite, physical-device testing, or complete curriculum coverage unless verified.

---

## 13. Documentation and handoff

Update:

`docs/IMPLEMENTATION_MAP.md`

Create:

`docs/PHASE_10_GRAMMAR_HANDOFF.md`

The handoff must include:

### Implementation
- Files changed
- Curriculum levels and categories implemented
- Number of grammar topics and examples
- Content schema and validation
- UI and navigation
- TTS integration
- Progress implementation or documented deferral

### Validation
- Commands executed
- Actual results
- Tests added or modified
- Existing failures and their status

### Content quality
- Urdu translations requiring review
- Known curriculum gaps
- Any roadmap requirements not implemented

### Next steps
- Identify Phase 11 or the next task specified by `PHASE_INSTRUCTIONS.md`.
- Do not start the next phase.

Keep the master roadmap as the source of truth and update phase status accurately.

---

## 14. Scope restrictions

Do not:

- Start Phase 11 practice exercises.
- Implement progress dashboards prematurely.
- Implement MongoDB or backend APIs.
- Implement authentication or cloud sync.
- Implement the AI dictionary.
- Add subscriptions or videos.
- Rewrite Phase 6–9 features.
- Replace the existing architecture.
- Change the official logo.
- Introduce unnecessary dependencies.
- Claim complete English grammar coverage without implementing the required curriculum.

---

## Completion criteria

Phase 10 is complete when:

1. All Phase 10 requirements in `PHASE_INSTRUCTIONS.md` are implemented.
2. Grammar topics are organized into the required levels/categories.
3. Required English and Urdu explanations and examples are available.
4. Repository validation is implemented.
5. The grammar UI and navigation work.
6. RTL/LTR behavior is correct.
7. Existing TTS integration is preserved.
8. Progress behavior follows the master roadmap.
9. Existing features remain intact.
10. Tests and actual outcomes are documented.
11. `docs/IMPLEMENTATION_MAP.md` is updated.
12. `docs/PHASE_10_GRAMMAR_HANDOFF.md` is created.

At completion, provide a concise report covering:

- Grammar topics implemented
- Content counts
- Files changed
- Tests and actual results
- Known issues
- Translation review requirements
- Regression status
- Recommended next roadmap task

**Stop after Phase 10. Do not begin Phase 11.**

# English Udaan — Phase 11: Practice & Interactive Quizzes

## Objective

Implement **Phase 11 — Practice** in the existing English Udaan Flutter application.

Create an interactive practice experience that helps Urdu-speaking learners reinforce what they have learned through vocabulary, picture learning, sentences, and grammar.

The practice experience should provide questions, answer selection, feedback, scoring, and a clear completion summary.

**This task covers Phase 11 only.** Do not begin Phase 12 progress dashboards, backend integration, authentication, cloud sync, or AI dictionary implementation.

---

## 1. Read the project documentation first

Before making changes, read:

- `PHASE_INSTRUCTIONS.md` — master roadmap and Phase 11 requirements
- `PROJECT_CONTEXT.md` — architecture and project decisions
- `docs/IMPLEMENTATION_MAP.md` — current implementation status
- `docs/PHASE_7_HANDOFF.md`
- `docs/PHASE_7_THREE_LETTER_HANDOFF.md`
- `docs/PHASE_7_FOUR_LETTER_HANDOFF.md`
- `docs/PHASE_7_FIVE_LETTER_HANDOFF.md`
- `docs/PHASE_8_PICTURE_LEARNING_HANDOFF.md`
- `docs/PHASE_9_SENTENCES_PARAGRAPHS_HANDOFF.md`
- `docs/PHASE_10_GRAMMAR_HANDOFF.md`

Inspect the existing learning models, repository, routing, theme, localization, TTS service, and current Practice screen or placeholder.

Follow the master roadmap if it defines additional requirements or different quiz types.

Do not rewrite existing learning features or create duplicate infrastructure.

---

## 2. Practice categories

Build practice activities from the existing local learning content.

Support the categories required by `PHASE_INSTRUCTIONS.md`. At minimum, assess whether the existing content supports:

- Vocabulary practice: 2-, 3-, 4-, and 5-letter words
- Picture vocabulary practice: identify or match pictured items
- Sentence practice: understand sentences and their Urdu meanings
- Grammar practice: identify correct answers and correct common mistakes

Provide an all-categories option if it fits the existing roadmap and architecture.

Do not invent a new content system when the existing repositories can provide the required learning material.

If a content type does not yet have enough structured information to support a particular question format, document the limitation and use a suitable supported question type instead.

---

## 3. Question types

Implement the question formats required by the master roadmap.

Where appropriate, support:

- Multiple-choice questions
- Select the correct English word for an Urdu meaning
- Select the correct Urdu meaning for an English word
- Match picture vocabulary with the correct word
- Choose the correct sentence or translation
- Select the grammatically correct option
- Identify a correction to an incorrect grammar example

Use only question types supported by the available content.

Each question should have:

- A stable question ID where appropriate
- Question text
- Optional Urdu translation or instruction
- Answer options
- Correct answer reference
- Optional image/content reference
- Category or topic metadata

Keep answer evaluation separate from widget presentation so it can be tested independently.

Do not expose the correct answer to the learner before the learner submits a response.

---

## 4. Quiz flow

Create a reusable quiz experience with the following flow:

1. Practice landing screen
2. Category or practice-mode selection
3. Question presentation
4. Answer selection
5. Answer submission
6. Correct/incorrect feedback
7. Progress through the current quiz
8. Final results screen

Follow the exact flow required by the master roadmap if it differs.

Requirements:

- Prevent accidental duplicate scoring for the same question.
- Do not allow the learner to submit multiple answers for one question.
- Clearly distinguish correct and incorrect answers.
- Provide a way to continue to the next question.
- Handle the final question without navigation errors.
- Support retrying a quiz if required by the roadmap.
- Provide an appropriate empty state if there are insufficient questions.

Keep the interface simple, accessible, and suitable for learners of different ages.

---

## 5. Question generation and content integrity

Reuse the existing repositories and data models wherever practical.

Questions should be generated from validated local content, not from arbitrary hard-coded copies of vocabulary and grammar lessons.

Requirements:

- Use stable references to the original learning content.
- Avoid duplicate questions within a quiz where possible.
- Ensure every question has a valid answer.
- Ensure multiple-choice options are distinct.
- Ensure the correct answer is among the available options.
- Avoid ambiguous questions with multiple plausible correct answers.
- Avoid using the correct answer as a misleading distractor elsewhere in the same question.
- Handle categories with too few suitable items gracefully.

Use deterministic question-generation logic where practical so tests can verify the results.

If randomness is used, inject or control the random source for deterministic testing.

Do not introduce a paid question-generation API or live AI dependency.

---

## 6. Scoring and feedback

Implement the scoring rules specified by the master roadmap.

If the roadmap does not define scoring details, use a documented, straightforward system:

- One point for each correctly answered question.
- No points for an incorrect answer.
- Each question contributes to the quiz total only once.
- Show the final score and total questions.
- Show the percentage score when the quiz contains at least one question.

Use correct rounding and avoid division by zero.

Provide a clear summary after the quiz, including:

- Correct answers
- Incorrect answers
- Total questions
- Score or percentage
- A retry option, where appropriate
- A return-to-practice option

Do not introduce complex ranking, rewards, leaderboards, or achievements unless the master roadmap explicitly requires them.

---

## 7. User interface and localization

Use the existing English Udaan design system.

Reuse:

- Theme colors and typography
- Existing reusable cards and buttons
- Navigation patterns
- Localization and direction handling
- Existing spacing and responsive layouts
- Existing TTS integration where useful

Requirements:

- English text renders left-to-right.
- Urdu text renders right-to-left.
- Mixed-language questions remain readable.
- Answer options are clearly selectable.
- Feedback is understandable and not conveyed by color alone.
- Buttons have clear labels and accessible tap targets.
- Long text wraps without clipping.
- Light, dark, and system theme modes remain supported.

Do not redesign the overall app shell or change the official logo.

---

## 8. Text-to-speech

Reuse the existing `SpeechService` / `DeviceSpeechService`.

Where appropriate, allow learners to hear English vocabulary, sentences, or examples during practice.

Requirements:

- Reuse existing speech functionality.
- Preserve graceful fallback behavior for unsupported voices.
- Prevent overlapping speech when learners move quickly between questions.
- Do not add another TTS package.

Do not claim physical-device TTS testing unless it is performed during this task.

---

## 9. Progress and persistence boundaries

Phase 12 is the designated progress-tracking phase.

Read `PHASE_INSTRUCTIONS.md` and inspect the existing progress architecture before implementing persistence.

Implement only the scoring or session state required by Phase 11.

Do not prematurely introduce a complete progress dashboard, cross-device synchronization, or a new progress database.

If Phase 11 requires persistent practice results, implement only the specified minimal persistence using existing conventions and document the boundary with Phase 12.

Do not overwrite existing vocabulary, picture, sentence, or grammar completion keys.

---

## 10. Testing

Add tests using the existing project testing conventions.

### Question-generation tests

Verify:

- Questions are generated from valid source content.
- Question IDs are unique within the applicable scope.
- Every question has a valid correct answer.
- Answer options are distinct.
- The correct answer is present.
- Insufficient source content is handled safely.
- Duplicate questions are avoided where required.
- Randomized behavior is testable deterministically.

### Scoring tests

Verify:

- Correct answers increase the score exactly once.
- Incorrect answers do not increase the score.
- Repeated submissions do not double-count.
- Final totals are correct.
- Percentage calculation is correct.
- Empty quiz results do not cause division by zero.
- Retry starts a clean quiz session when required.

### Widget tests

Verify, where practical:

- Practice landing screen renders.
- Category selection works.
- Questions and options display correctly.
- Answer selection and submission work.
- Feedback is shown.
- Next-question navigation works.
- Final results are correct.
- Retry and return navigation work.
- RTL/LTR behavior remains correct.

### Regression tests

Preserve all existing tests and existing learning functionality.

Do not delete, disable, or weaken tests to make the suite pass.

---

## 11. Existing Flutter test failures

Previous handoffs report failures in `mobile/test/learning_flow_test.dart` involving Home navigation, vocabulary content, search, and completion. The reported failures were not resolved in Phases 9–10.

Before changing tests:

1. Run the relevant tests and capture the actual failure output.
2. Determine whether the failures are caused by the test harness, asynchronous content loading, layout assumptions, or a production regression.
3. Check whether Phase 11 changes affect those tests.
4. Make only minimal, justified fixes.
5. Keep unrelated failures visible and documented.

Do not assume the failures are harmless or claim they are pre-existing without evidence.

Do not remove tests or weaken assertions merely to obtain a passing suite.

---

## 12. Validation commands

Run:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `npm test`

Run the commands from the appropriate project directories if required by the repository structure.

Report actual results.

If the full Flutter test suite fails but individual tests pass, clearly distinguish the results.

Do not claim that the full test suite passed unless it actually did.

---

## 13. Documentation and handoff

Update:

`docs/IMPLEMENTATION_MAP.md`

Create:

`docs/PHASE_11_PRACTICE_HANDOFF.md`

The handoff must include:

### Implementation
- Files changed
- Practice categories supported
- Question formats implemented
- Question-generation approach
- Scoring rules
- Quiz navigation and results behavior
- TTS integration
- Persistence decisions

### Validation
- Commands executed
- Actual test results
- Tests added or changed
- Known failures and their status

### Limitations
- Content categories that lack sufficient source data
- Question formats not implemented
- Any remaining UI or accessibility issues

### Next step
Identify the next task specified by `PHASE_INSTRUCTIONS.md`.

Do not start the next phase.

---

## 14. Scope restrictions

Do not:

- Start Phase 12 progress dashboards.
- Implement a new analytics system.
- Implement MongoDB or backend APIs.
- Implement authentication or cloud sync.
- Implement the AI dictionary.
- Add subscriptions or videos.
- Rewrite existing vocabulary, picture, sentence, or grammar modules.
- Replace the existing architecture.
- Change the official logo.
- Add paid external services.
- Claim support for question types that were not implemented and tested.

---

## Completion criteria

Phase 11 is complete when:

1. Practice categories follow the master roadmap.
2. Questions are generated from existing validated content where applicable.
3. Answer evaluation and scoring are implemented and tested.
4. Learners can complete a quiz and see results.
5. Retry and navigation work as required.
6. English/Urdu direction and existing themes are preserved.
7. Existing TTS integration is reused.
8. Phase 12 functionality is not implemented prematurely.
9. Existing features remain intact.
10. Tests and actual outcomes are documented.
11. `docs/IMPLEMENTATION_MAP.md` is updated.
12. `docs/PHASE_11_PRACTICE_HANDOFF.md` is created.

At completion, provide a concise report with:

- Categories and question types implemented
- Number of questions supported or generated per quiz
- Scoring behavior
- Files changed
- Actual test results
- Known issues
- Regression status
- Recommended next roadmap task

**Stop after Phase 11. Do not begin Phase 12.**

# English Udaan — Phase 12: Progress Tracking & Learning Analytics

## Objective

Implement **Phase 12 — Progress** in the existing English Udaan Flutter application.

Create a unified progress experience that helps learners understand what they have learned, which lessons they have completed, how they perform in quizzes, and how consistently they study.

The progress system should combine existing local learning data from:

- Alphabet learning
- 2-letter vocabulary
- 3-letter vocabulary
- 4-letter vocabulary
- 5-letter vocabulary
- Picture learning
- Sentences and paragraphs
- Grammar
- Practice quizzes

**This task covers Phase 12 only.** Do not implement cloud synchronization, MongoDB integration, authentication, or other later-phase features.

---

## 1. Read project documentation first

Before coding, read:

- `PHASE_INSTRUCTIONS.md` — master roadmap and Phase 12 requirements
- `PROJECT_CONTEXT.md` — project architecture and product decisions
- `docs/IMPLEMENTATION_MAP.md` — current implementation status
- `docs/PHASE_7_HANDOFF.md`
- `docs/PHASE_7_THREE_LETTER_HANDOFF.md`
- `docs/PHASE_7_FOUR_LETTER_HANDOFF.md`
- `docs/PHASE_7_FIVE_LETTER_HANDOFF.md`
- `docs/PHASE_8_PICTURE_LEARNING_HANDOFF.md`
- `docs/PHASE_9_SENTENCES_PARAGRAPHS_HANDOFF.md`
- `docs/PHASE_10_GRAMMAR_HANDOFF.md`
- `docs/PHASE_11_PRACTICE_HANDOFF.md`

Inspect the existing completion keys, SharedPreferences usage, repository interfaces, quiz score persistence, navigation, and current Progress screen.

Follow the master roadmap if it specifies requirements not covered by this prompt.

**Do not rewrite working learning features or replace existing persistence keys.**

---

## 2. Audit existing progress data first

Before implementing the dashboard, create a clear inventory of existing progress data.

Inspect the actual implementation and identify:

- Alphabet completion key and stored value
- Separate completion keys for 2-, 3-, 4-, and 5-letter vocabulary
- Picture-learning completion keys by category
- Sentence/paragraph progress, if any
- Grammar progress, if any
- Practice quiz score, total, and completion timestamp keys
- Any existing progress models or calculations

Document what is available, what is missing, and what can be calculated reliably.

Do not assume that a completion key means every item in a section has been learned unless the implementation confirms this.

Do not fabricate historical learning records or backfill progress with invented data.

---

## 3. Unified progress architecture

Implement a reusable progress repository or service using the existing project architecture.

It should aggregate the existing local progress data into a consistent model suitable for the Progress screen.

Support the requirements in `PHASE_INSTRUCTIONS.md`, including:

- Lessons completed
- Words learned
- Learning completion by category
- Practice quiz results
- Accuracy calculations
- Learning streaks
- Overall progress summary

Use existing data as the source of truth wherever possible.

Separate data collection and calculations from the UI so the logic can be tested independently.

Avoid duplicate storage of values that can be derived reliably from existing records.

If a metric cannot be calculated accurately from current data, identify the missing data and implement only the reliable portion. Document the limitation instead of inventing a value.

---

## 4. Lessons completed

Calculate completed lessons from the actual persistence mechanisms used by each learning module.

Requirements:

- Count completion only when supported by the existing data.
- Preserve independent completion keys.
- Avoid counting the same lesson more than once.
- Distinguish a completed section from individually completed items where necessary.
- Handle missing or unset completion values safely.
- Show a useful empty state for new learners.

If the current implementation records only one completion flag per vocabulary section or picture category, report section/category completion rather than claiming that every individual word or picture was learned.

Do not change the meaning of existing completion flags without a documented migration plan.

---

## 5. Words learned

Implement the words-learned metric according to the master roadmap and the data that the app actually records.

First inspect how vocabulary completion currently works.

If the app tracks only whole-section completion, do not count every word in a section as individually learned unless that interpretation is explicitly intended by the existing product requirements.

If individual word-level tracking is required but does not exist, implement the smallest compatible extension that supports it without breaking existing completion records.

If word-level tracking is deferred or outside the specified scope, report the available section-level metric honestly and document the limitation.

Do not count sentence tokens, grammar terms, or picture labels as vocabulary words unless the roadmap explicitly defines them that way.

---

## 6. Practice quiz statistics

Integrate the independent score records introduced in Phase 11.

Inspect the actual stored format and calculate only supported metrics, such as:

- Latest score by practice category
- Quiz completion count, if the necessary records exist
- Total questions answered, if recorded
- Correct answers, if recorded
- Accuracy percentage, if sufficient data exists
- Most recent quiz completion time

Important: if Phase 11 stores only the latest score and total per category, do not pretend that it contains a complete quiz history.

Add the minimum additional local tracking required by Phase 12, where specified by the roadmap.

Preserve the existing Phase 11 keys:

- `practice.quiz.<category>.last_score`
- `practice.quiz.<category>.total`
- `practice.quiz.<category>.completed_at`

Do not silently overwrite or reinterpret these values.

---

## 7. Accuracy calculations

Use consistent, documented calculation rules.

For example, when the underlying data is available:

- Accuracy = correct answers ÷ total answered questions × 100.
- Avoid division by zero.
- Do not include unanswered questions in the answered-question denominator.
- Do not average category percentages without accounting for their underlying question counts, unless the product requirement explicitly calls for an unweighted average.
- Round displayed percentages consistently.

Use actual answer-level or quiz-level data where available.

If the current records do not support an accurate overall accuracy calculation, display the available quiz score information and document the limitation.

Add unit tests for the calculation logic.

---

## 8. Learning streaks

Implement learning streaks according to the master roadmap.

First establish what activity timestamps are currently stored.

If daily activity history does not exist, add a small local activity-recording mechanism appropriate for this phase.

Requirements:

- Record a study activity only when a meaningful learning action occurs.
- Avoid creating multiple daily activity records for every screen render.
- Use the device's local calendar date consistently.
- Define how today's activity, consecutive study days, and missed days affect the streak.
- Calculate the current streak and, if required by the roadmap, the longest streak.
- Handle first-time learners and missing history safely.
- Avoid counting future-dated activity as current progress.
- Test consecutive days, missed days, repeated same-day activity, and date-boundary behavior.

Keep the implementation local and lightweight.

Do not add notifications, reminders, cloud services, or background tracking unless explicitly required by the master roadmap.

---

## 9. Progress screen UI

Build the Progress screen using the existing English Udaan design system.

Reuse existing:

- Theme system
- Typography
- Cards and spacing
- Navigation patterns
- Localization and RTL/LTR behavior

Display the metrics required by the roadmap, using only values supported by the data.

Potential sections include:

- Overall learning summary
- Lessons or sections completed
- Words learned, with a clear definition
- Category-specific progress
- Practice quiz performance
- Accuracy percentage, where calculable
- Current learning streak
- Longest streak, if required

Use clear labels and meaningful empty states.

Do not introduce misleading charts, fabricated percentages, or arbitrary completion estimates.

Avoid adding a charting dependency unless the roadmap requires it and the existing UI cannot reasonably meet that requirement.

Ensure the screen works in light, dark, and system themes, and that Urdu and English directions render correctly.

---

## 10. Live updates and persistence

The Progress screen should reflect changes after learners complete lessons or quizzes.

Use the existing state-management architecture, including Riverpod where appropriate.

Requirements:

- Refresh or invalidate progress state when relevant learning activity changes.
- Avoid unnecessary repeated reads or rebuild loops.
- Persist only the data that must survive an app restart.
- Keep existing lesson-completion and quiz-score keys intact.
- Handle malformed or missing persisted data gracefully.

Do not introduce a second state-management system.

Do not implement cloud synchronization in this phase.

---

## 11. Testing

Add tests using the project's existing conventions.

### Repository and calculation tests

Verify:

- Existing completion keys are read correctly.
- Missing progress values are handled safely.
- Section/category completion is counted correctly.
- Duplicate lessons are not double-counted.
- Words-learned calculations follow the actual tracking model.
- Quiz scores and totals are interpreted correctly.
- Accuracy calculations are correct.
- Empty data does not cause division-by-zero errors.
- Streak calculations handle consecutive and missed days.
- Repeated activity on one day does not inflate the streak.
- Progress data remains consistent after reload.

### Widget tests

Verify:

- Progress screen renders for a new learner.
- Existing progress is displayed correctly.
- Empty states are helpful.
- Quiz statistics display only supported values.
- RTL/LTR layout remains correct.
- Light and dark theme behavior is preserved where testable.
- Progress updates after relevant learning activity.

### Regression tests

Preserve existing tests and ensure that Phase 6–11 functionality remains intact.

Do not remove tests or weaken assertions to make the suite pass.

---

## 12. Existing Flutter test failures

Previous handoffs report three remaining failures in `mobile/test/learning_flow_test.dart` involving asynchronous vocabulary loading, search, and completion.

Before changing the tests:

1. Run the current full test suite and capture the actual output.
2. Determine whether the failures are related to Phase 12 changes.
3. Check the current test harness, asset loading, and asynchronous behavior.
4. Make minimal, justified fixes if appropriate.
5. Keep unrelated failures visible and documented.

Do not assume these failures are harmless merely because they were reported in previous handoffs.

Do not remove or disable failing tests, or weaken assertions simply to obtain a passing result.

---

## 13. Validation commands

Run:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `npm test`

Run commands from the correct project directories.

Report the actual outcome of each command.

If targeted tests pass but the full Flutter suite fails, clearly distinguish the results.

Do not claim complete regression coverage or a clean test suite unless verified.

---

## 14. Documentation and handoff

Update:

`docs/IMPLEMENTATION_MAP.md`

Create:

`docs/PHASE_12_PROGRESS_HANDOFF.md`

The handoff must include:

### Implementation
- Files changed
- Existing progress keys inspected
- Progress data model and repository/service
- Metrics implemented
- Streak rules
- Persistence strategy
- UI and state-refresh behavior

### Metric definitions
Document precisely how each displayed metric is calculated and which source records support it.

### Validation
- Commands executed
- Actual test results
- Tests added or changed
- Known failures and their status

### Limitations
- Metrics that cannot yet be calculated reliably
- Any missing historical data
- Any content-level tracking that remains deferred
- Any unresolved UI or localization issues

### Next steps
Identify the next task specified by `PHASE_INSTRUCTIONS.md`.

Keep the master roadmap as the source of truth and update phase status accurately.

---

## 15. Scope restrictions

Do not:

- Implement MongoDB integration.
- Implement authentication or cloud synchronization.
- Add a backend analytics service.
- Add notifications or reminders.
- Implement the AI dictionary.
- Add subscriptions or video lessons.
- Rewrite Phase 6–11 features.
- Replace existing persistence keys.
- Fabricate learning history or progress values.
- Claim word-level tracking when only section-level completion is recorded.
- Claim complete quiz history when only latest-score records exist.
- Introduce unnecessary dependencies.
- Start Phase 13.

---

## Completion criteria

Phase 12 is complete when:

1. Existing progress mechanisms have been audited.
2. A reusable progress repository/service aggregates supported data.
3. Lesson and section completion metrics are accurate.
4. Words-learned reporting matches the actual tracking granularity.
5. Practice score and accuracy metrics use valid source data.
6. Learning streaks follow documented, tested rules.
7. The Progress screen presents accurate information and useful empty states.
8. Updates are reflected without requiring an app reinstall.
9. Existing persistence keys and Phase 6–11 features remain intact.
10. Tests and actual outcomes are documented.
11. `docs/IMPLEMENTATION_MAP.md` is updated.
12. `docs/PHASE_12_PROGRESS_HANDOFF.md` is created.

At completion, provide a concise report covering:

- Metrics implemented
- Metric definitions
- Files changed
- Tests and actual results
- Known limitations
- Regression status
- Recommended next roadmap task

**Stop after Phase 12. Do not begin Phase 13.**

# English Udaan — Phase 13: Profile & Settings

## Objective

Implement **Phase 13 — Profile & Settings** in the existing English Udaan Flutter application.

Create a clean settings and profile experience where learners can manage language, appearance, audio preferences, and app information.

The implementation must reflect the app's actual authentication state. Do not simulate a real account, logout, or session expiry when authentication is not yet implemented.

**This task covers Phase 13 only.** Do not start backend integration, authentication implementation, cloud sync, or other future roadmap phases.

---

## 1. Read the project documentation first

Before making changes, read:

- `PHASE_INSTRUCTIONS.md` — master roadmap and Phase 13 requirements
- `PROJECT_CONTEXT.md` — architecture and project decisions
- `docs/IMPLEMENTATION_MAP.md` — current implementation status
- `docs/PHASE_8_PICTURE_LEARNING_HANDOFF.md`
- `docs/PHASE_9_SENTENCES_PARAGRAPHS_HANDOFF.md`
- `docs/PHASE_10_GRAMMAR_HANDOFF.md`
- `docs/PHASE_11_PRACTICE_HANDOFF.md`
- `docs/PHASE_12_PROGRESS_HANDOFF.md`

Inspect the existing Profile screen, settings/preferences repository, Riverpod providers, GoRouter routes, localization/direction handling, theme system, TTS service, and persistence mechanisms.

Follow the master roadmap if it defines additional requirements.

Do not rewrite working features or create duplicate settings infrastructure.

---

## 2. Profile screen

Implement a dedicated Profile screen using the existing English Udaan design system.

The screen should include the items required by the master roadmap, such as:

- App logo or appropriate existing branding
- Profile heading
- Current language preference
- Current appearance/theme preference
- Audio settings entry
- Help and About entries
- Account/authentication state, represented accurately

Do not invent a user's name, email address, avatar, account ID, or other personal information.

If real user accounts do not exist yet, display an honest guest/local-user state or the appropriate placeholder defined by the roadmap.

Keep the screen responsive, accessible, and suitable for Urdu-speaking learners of different ages.

Do not change the official logo.

---

## 3. Language settings

Integrate with the existing language preference mechanism.

Requirements:

- Preserve the existing Urdu and English language choices.
- Preserve Urdu as the default language where required by the existing project decisions.
- Update the app's language/direction state through the existing architecture.
- Render Urdu content RTL and English content LTR.
- Persist the chosen language across app restarts.
- Ensure the selected language is reflected in the UI immediately where the app already supports dynamic updates.
- Avoid creating a second, conflicting language preference key.

If the app does not yet translate every screen fully, do not claim complete localization. Document any remaining untranslated content.

Do not change the existing language-preference format without a justified migration.

---

## 4. Appearance and theme settings

Integrate with the existing System, Light, and Dark theme support.

Requirements:

- Show the current appearance selection.
- Allow users to select System, Light, or Dark.
- Apply changes immediately using the existing Riverpod/theme architecture.
- Persist the choice across app restarts.
- Keep all existing learning screens compatible with the theme.
- Avoid creating a second theme state or preference key.

Do not redesign the app's visual identity or alter the established teal design system.

---

## 5. Audio settings

Inspect the existing `SpeechService` / `DeviceSpeechService` implementation and the current TTS package capabilities before deciding what settings can genuinely be supported.

Implement the audio controls required by the master roadmap.

Potential settings, only where supported, include:

- Speech enabled/disabled
- Speech rate
- Other supported speech preferences

Requirements:

- Persist supported preferences locally.
- Apply changes through the existing speech service.
- Keep defaults safe and suitable for English learners.
- Validate numeric values against the TTS package's supported range.
- Handle unsupported settings and unavailable voices gracefully.
- Do not add a second TTS implementation.
- Do not claim a setting works if it is only decorative.

If speech rate or other preferences cannot currently be controlled through the existing service, make the smallest justified extension and test it.

Do not introduce audio recording, microphone permissions, or new audio services.

---

## 6. Help and About

Implement the Help and About sections required by the master roadmap.

### Help

Provide concise, useful guidance for the existing app features, such as:

- Alphabet learning
- Vocabulary learning
- Picture learning
- Sentences and paragraphs
- Grammar
- Practice quizzes
- Progress tracking
- Language and theme settings
- Text-to-speech troubleshooting

Only describe features that actually exist.

Use clear, learner-friendly language and the existing localization conventions.

### About

Show accurate project information, such as:

- English Udaan app name
- Existing logo
- A concise description of the app
- Version/build information if available from the project
- Website `englishudaan.com`, where appropriate

Do not invent a company address, legal entity, contact email, copyright claim, release version, or other unverified information.

If privacy policy, terms, or support URLs are not yet defined, do not invent links. Document what requires owner input.

---

## 7. Account state, logout, and session expiry

Inspect the current authentication implementation and follow the master roadmap.

Authentication is not yet implemented according to the existing project status.

Therefore:

- Do not simulate a successful login or logout.
- Do not fabricate account data.
- Do not create fake authentication tokens.
- Do not add a mock account system that appears production-ready.
- Do not clear all local learning progress when a user exits a profile screen.
- Do not introduce session-expiry behavior that has no real session to monitor.

If the roadmap requires an account-state placeholder, display the current local/guest state honestly.

If logout is listed as a required entry, either provide a clearly explained unavailable/deferred state or implement only the behavior explicitly supported by the current architecture.

Keep local learning data intact.

Document the authentication-dependent behavior that must be completed during the relevant future roadmap phase.

---

## 8. Navigation and integration

Use the existing GoRouter and application shell.

Requirements:

- Keep the Profile route working.
- Add dedicated settings/help/about routes only if justified by the current architecture and roadmap.
- Ensure navigation works from the existing Profile screen.
- Preserve Home, Learn, Practice, Progress, and all existing lesson routes.
- Avoid duplicate routes or unnecessary navigation abstractions.
- Ensure back navigation behaves correctly.

Do not redesign the overall app shell.

---

## 9. Persistence and state management

Use the existing Riverpod and local-preference architecture.

Requirements:

- Reuse existing language and theme preference storage.
- Store new supported audio preferences using the project's conventions.
- Update settings state immediately when a preference changes.
- Restore preferences correctly after app restart.
- Handle missing or malformed preference values safely.
- Avoid unnecessary repeated writes.
- Avoid duplicate or conflicting keys.

Do not add a new database or backend service.

Do not implement cloud sync in this phase.

---

## 10. Testing

Add tests using the project's existing test conventions.

### Settings and persistence tests

Verify:

- Language selection updates the existing preference.
- Theme selection updates the existing theme state.
- Supported audio preferences are validated and persisted.
- Preferences restore correctly.
- Missing or invalid stored values fall back safely.
- Existing preference keys remain compatible.

### Widget tests

Verify:

- Profile screen renders.
- Current settings are displayed correctly.
- Language controls work.
- Theme controls work.
- Audio settings are usable.
- Help and About screens display accurate information.
- Account state is represented honestly.
- Navigation and back behavior work.
- RTL/LTR and light/dark themes remain correct.

### Regression tests

Preserve existing learning, quiz, progress, and navigation functionality.

Do not remove or weaken tests merely to make the suite pass.

---

## 11. Existing Flutter test failures

Previous handoffs report failures in `mobile/test/learning_flow_test.dart` involving Home navigation and asynchronous vocabulary loading, search, and completion.

Before changing these tests:

1. Run the current full Flutter test suite and capture actual output.
2. Determine whether Phase 13 changes cause or affect any failure.
3. Keep unrelated failures visible and documented.
4. Make minimal, justified fixes if appropriate.
5. Do not assume the failures are harmless simply because they were reported previously.

Do not delete, disable, or weaken failing tests to obtain a passing result.

---

## 12. Validation commands

Run the appropriate commands from the project directories:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `npm test`

Report the actual outcome of each command.

Distinguish targeted test success from a failing full test suite.

Do not claim device verification, complete localization, or a clean regression suite unless verified.

---

## 13. Documentation and handoff

Update:

`docs/IMPLEMENTATION_MAP.md`

Create:

`docs/PHASE_13_PROFILE_SETTINGS_HANDOFF.md`

The handoff must include:

### Implementation
- Files changed
- Profile features implemented
- Language and theme integration
- Audio settings and actual capabilities
- Help/About implementation
- Account-state behavior
- Navigation changes
- Preference persistence

### Validation
- Commands executed
- Actual test results
- Tests added or modified
- Known failures and their status

### Limitations
- Untranslated content, if any
- Audio capabilities not supported
- Authentication-dependent behavior deferred
- Privacy policy/support information requiring owner input
- Any other unresolved issues

### Next step
Identify the next task according to `PHASE_INSTRUCTIONS.md`.

Keep the master roadmap as the source of truth and update phase status accurately.

---

## 14. Scope restrictions

Do not:

- Implement authentication or account registration.
- Implement MongoDB or backend APIs.
- Implement cloud sync.
- Implement the AI dictionary.
- Add subscriptions or video lessons.
- Rewrite the existing language or theme architecture.
- Replace the existing TTS service.
- Change the official logo.
- Delete local progress when navigating away or logging out of a placeholder account.
- Invent account data or external links.
- Introduce unnecessary dependencies.
- Start Phase 14 or any subsequent phase.

---

## Completion criteria

Phase 13 is complete when:

1. The Profile screen meets the master roadmap requirements.
2. Language settings use the existing preference mechanism.
3. Theme settings use the existing System/Light/Dark architecture.
4. Supported audio settings work and persist.
5. Help and About accurately describe existing features.
6. Account/authentication state is represented honestly.
7. Navigation and RTL/LTR behavior are correct.
8. Existing learning and progress data remain intact.
9. Tests and actual outcomes are documented.
10. `docs/IMPLEMENTATION_MAP.md` is updated.
11. `docs/PHASE_13_PROFILE_SETTINGS_HANDOFF.md` is created.

At completion, provide a concise report containing:

- Features implemented
- Files changed
- Settings that persist
- Tests and actual results
- Known issues
- Authentication-dependent items deferred
- Regression status
- Recommended next roadmap task

**Stop after Phase 13. Do not begin Phase 14.**

# English Udaan — Phase 14: Backend and MongoDB

We are starting **Phase 14 only** of the English Udaan project.

## 1. Read the project documentation first

Before modifying code, read and follow:

- `PHASE_INSTRUCTIONS.md` — master roadmap
- `docs/IMPLEMENTATION_MAP.md`
- The project context and architecture documentation
- `docs/PHASE_13_PROFILE_SETTINGS_HANDOFF.md`
- Any existing backend README, environment examples, tests, and configuration files

Inspect the actual repository and current Git changes. Do not assume that the documentation perfectly matches the current implementation. Preserve unrelated user changes and working functionality.

## 2. Phase 14 objective

Establish a secure, testable MongoDB connection for the existing Node.js/Express backend, preferably using MongoDB Atlas for development and the repository’s existing conventions.

Inspect the current dependencies first. Use Mongoose if appropriate and compatible with the existing backend; do not add duplicate libraries or replace existing architecture without a clear reason.

## 3. Required implementation

1. Add or complete centralized MongoDB connection management.
2. Validate required environment variables and provide clear, actionable configuration errors without exposing secrets.
3. Add or update `.env.example` with placeholder values only.
4. Ensure local environment files are ignored by Git. Verify the relevant `.gitignore` rules.
5. Implement appropriate connection lifecycle handling, including startup failure behavior and graceful shutdown.
6. Integrate database status with the existing health endpoint. Distinguish basic server health from database readiness where appropriate. Do not report the database as connected unless the connection is actually confirmed.
7. Define only the database models, schemas, indexes, and metadata needed for the agreed Phase 14 scope. Review the existing content structures first. Store image references and metadata, not image binaries.
8. Keep configuration and database access maintainable and testable.
9. Add tests for connection configuration, error handling, health/readiness behavior, and relevant schemas. Use mocks or an appropriate test database when real Atlas credentials are unavailable.
10. Update the backend documentation with setup instructions and troubleshooting steps.

## 4. Strict phase boundaries

Do not implement:

- Authentication, registration, login, logout, or token/session APIs — Phase 15.
- Flutter-to-backend integration — Phase 16.
- AI dictionary/provider integration — Phase 17.
- Unapproved hosting, payment, subscription, or production deployment changes.

Do not decide the AI provider/model, authentication provider/method, hosting platform, token/session strategy, or synchronization conflict rules without my approval.

## 5. Manual setup and approvals

I am willing to create the MongoDB Atlas project, deployment, database user, network access rule, and connection string manually.

First determine which configuration and code changes can be completed without real credentials. Implement those safely and tell me exactly when manual setup is required.

Provide step-by-step Atlas instructions. Tell me the exact environment variable names the project uses and the exact backend environment-file location based on the repository. Never ask me to commit secrets or paste real credentials into chat.

If a real connection cannot be verified, clearly label it as unverified. Do not fabricate a successful connection test.

Do not block offline unit tests just because MongoDB credentials are missing. Follow the existing backend startup conventions and make configuration errors understandable.

## 6. Verification

Run the relevant backend tests and any available lint/type checks. Verify:

- Missing or invalid configuration produces a useful error.
- Secrets are not included in logs or error responses.
- Database connection success and failure are handled correctly.
- Health/readiness responses reflect the real database state.
- Shutdown closes the database connection safely.
- Existing backend tests and functionality remain intact.

Report commands executed and their actual results. Do not claim tests passed if they were not run.

## 7. Handoff

Update `docs/IMPLEMENTATION_MAP.md` and create `docs/PHASE_14_BACKEND_MONGODB_HANDOFF.md`.

The handoff must include completed changes, important files, environment variable names, manual setup still required, exact test results, known issues, whether a real Atlas connection was verified, and the next recommended phase.

Stop after Phase 14. Present the handoff and wait for my review before proceeding to Phase 15.

# English Udaan — Phase 15: Firebase Authentication and Cloud Progress APIs

Proceed with Phase 15. Phase 14 is accepted; MongoDB Atlas is connected and both health and readiness checks have succeeded. Do not repeat Phase 14 setup or tests unless a Phase 15 change requires regression testing.

## Approved decisions
- Authentication provider: Firebase Authentication.
- Enabled methods: Email/password and Google Sign-In.
- Backend: existing Node.js/Express API.
- Database: existing MongoDB Atlas.
- Flutter client authentication UI and Firebase package integration belong to Phase 16.
- Guest lesson access and existing local learning progress must remain available.

## First: inspect, then implement
Read `PHASE_INSTRUCTIONS.md`, `docs/IMPLEMENTATION_MAP.md`, and the Phase 14 handoff. Inspect the existing backend structure, environment validation, error handling, database connection, `UserProgress` schema, tests, and current Android Firebase configuration. Preserve existing working functionality and unrelated changes.

## Required implementation
1. Add the maintained `firebase-admin` Node.js SDK and initialize it using the existing backend conventions.
2. Support safe local development credentials and production application-default credentials. Never commit service-account private keys, expose them in API responses, or log secrets. Do not require a private key to be embedded in source code.
3. Implement reusable Express authentication middleware that accepts `Authorization: Bearer <Firebase ID token>`, verifies it using Firebase Admin, and attaches the verified UID to the request. Reject missing, malformed, expired, or invalid tokens with consistent 401 responses.
4. Add an authenticated profile/me endpoint returning only appropriate verified account details.
5. Implement protected cloud-progress read and write endpoints using the verified Firebase UID as the ownership key. Never trust a UID supplied by the request body or URL for authorization.
6. Review the existing `UserProgress` schema and design a documented, validated progress contract. Prevent one account from reading or overwriting another account's progress. Avoid blind overwrites and document conflict/merge behavior; do not implement an unsafe local/cloud merge.
7. Add input validation, sensible request limits, consistent errors, and rate limits where appropriate.
8. Handle user lifecycle and missing/deleted Firebase accounts appropriately without introducing a second password or token system.
9. Add automated tests for token middleware, unauthorized access, ownership isolation, validation, progress operations, and error handling. Use mocks for Firebase where suitable; do not claim a real Firebase verification test without actually performing one.
10. Update `docs/IMPLEMENTATION_MAP.md` and create `docs/PHASE_15_AUTH_CLOUD_PROGRESS_HANDOFF.md`.

## Strict boundaries
- Do not store passwords in MongoDB or implement custom password hashing, login, registration, Google OAuth, or competing JWT issuance.
- Do not install Flutter Firebase packages, change the app's login UI, or integrate Flutter with the API; those are Phase 16.
- Do not implement AI dictionary, subscriptions, video features, or deployment.
- Do not redo successful MongoDB configuration.
- Do not expose credentials or ask me to paste secrets into chat.

## Manual Firebase setup
Before requiring credentials, identify the Firebase project ID from the existing configuration or ask me for the non-secret project ID if needed. Explain exactly how to configure Firebase Admin credentials locally, preferably with Application Default Credentials, and provide a safe `.env.example` if a project ID variable is required. Do not print credentials or assume that `google-services.json` is a server credential.

Implement everything that can be safely tested without live Firebase credentials. Clearly distinguish automated tests from real Firebase integration verification.

## Final handoff
Report files changed, endpoints and request contracts, environment variables, manual setup still required, actual test results, security considerations, known issues, and the next phase. Stop after Phase 15 and wait for review.

# English Udaan — Phase 16: Flutter Authentication and Backend Integration

Proceed directly to Phase 16. Phase 15 is accepted based on its handoff and reported 53 passing backend tests. Do not repeat Phase 15 implementation or redo successful MongoDB setup.

## Read first
Read `PHASE_INSTRUCTIONS.md`, `docs/IMPLEMENTATION_MAP.md`, `docs/PHASE_15_AUTH_CLOUD_PROGRESS_HANDOFF.md`, and the current Flutter architecture and preferences documentation. Inspect the actual repository before changing anything.

## Approved architecture
- Firebase Authentication for email/password and Google Sign-In.
- Existing Node.js/Express backend verifies Firebase ID tokens.
- Existing MongoDB Atlas stores cloud progress by verified Firebase UID.
- Flutter guest learning and existing local progress must remain available.

## Implement Phase 16
1. Add and configure compatible Flutter packages, including `firebase_core`, `firebase_auth`, and the official Google Sign-In integration required by the selected package versions.
2. Initialize Firebase correctly for Android using the existing project configuration and the official FlutterFire setup conventions.
3. Implement registration, email/password login, Google Sign-In, logout, authentication-state handling, and user-friendly error messages.
4. Add login/register screens consistent with the existing English Udaan design system, supporting Urdu RTL and English LTR.
5. Keep learning content accessible to guests. Do not force authentication merely to open lessons.
6. Implement a maintainable API client that obtains the current Firebase ID token and sends it as `Authorization: Bearer <token>` to the existing protected Express API.
7. Integrate `GET /api/me`, `GET /api/progress`, and `PUT /api/progress` using the actual response and request contracts in the Phase 15 handoff.
8. Handle loading, network failure, expired sessions, retries, offline mode, logout, and account changes without leaking one user's progress to another.
9. Review existing local progress before implementing synchronization. Do not blindly overwrite local or cloud data. Implement a documented, tested merge/conflict strategy using an explicit version or timestamp comparison where suitable. Preserve local progress if the user cancels or sync fails.
10. Configure the Firebase Android app's debug signing fingerprints as needed. Never put Firebase Admin credentials in Flutter.
11. Add targeted tests for auth state, API token attachment, errors, guest access, and progress sync. Run Flutter analysis and relevant regression tests; report actual results.
12. Update `docs/IMPLEMENTATION_MAP.md` and create `docs/PHASE_16_FLUTTER_BACKEND_INTEGRATION_HANDOFF.md`.

## Boundaries
Do not implement the AI dictionary, subscriptions, videos, or deployment. Preserve existing functionality and unrelated user changes. Do not claim live Firebase verification unless tested with a real authenticated client and the running backend.

Before any manual setup that requires my action, give me exact step-by-step instructions. Do not ask me to share credentials in chat. Stop after Phase 16 and present the handoff for review.

### Phase 16 — Fix authentication verification issues

Fix only the two authentication issues below. Inspect the existing implementation before editing; preserve working features and avoid unrelated refactoring.

**Issue 1: Google sign-in missing on registration**
- Add a “Sign in with Google” button to the Create Account screen.
- Reuse the existing Google sign-in handler/service from the Login screen.
- Keep loading states, error handling, localization, theme styling, and navigation consistent.
- Do not duplicate authentication logic.

**Issue 2: Firebase not initialized on the web**
- The browser registration screen displays: `Bad state: Firebase is not initialized on this platform`.
- Inspect Firebase initialization in `mobile/lib/main.dart`, `auth_service.dart`, and the auth providers/screens.
- Identify why the app attempts authentication without an initialized Firebase instance.
- Check whether `Firebase.initializeApp()` is configured for web and whether web-specific Firebase options exist. Inspect `google-services.json` only as Android configuration; do not treat it as web configuration.
- Ensure initialization completes before authentication providers or screens invoke Firebase Auth.
- If web support is intended, configure Firebase web initialization using the project's actual Firebase web app configuration. Do not invent API keys or placeholder values.
- If web authentication is intentionally unsupported, show a clear user-facing explanation and prevent registration from invoking an uninitialized Firebase instance. However, prefer proper web support if the project already intends browser testing.
- Preserve Android initialization and guest learning.
- Do not expose Firebase credentials or secrets in logs or source-control changes.

**Validation**
1. Run `flutter analyze`.
2. Run existing authentication-related tests and add focused tests for initialization/error handling and Google button availability on both screens.
3. Test registration screen rendering in the browser without the initialization error.
4. Test email/password registration and Google sign-in on each platform that is actually configured.
5. Report changed files, actual test results, any required Firebase Console setup, and anything still unverified.

Do not claim live authentication works unless it was actually tested.

### English Udaan — Complete Phase 16 Cloud Progress Sync

Inspect the existing implementation and complete cloud progress synchronization. Preserve working authentication, learning features, local-first guest mode, and existing data models. Avoid unrelated refactoring.

**1. Upload triggers**
- Integrate `CloudProgressService.syncToCloud()` with the existing progress-saving flow.
- Upload after relevant progress changes, including completed vocabulary/picture sections and saved quiz results.
- Upload after sign-in once local progress is available.
- Avoid duplicate requests, upload loops, and unnecessary uploads.
- Do not block learning if the network is unavailable.

**2. Download and restore**
- Fix `syncFromCloud()` so downloaded progress is actually persisted and reflected in the app.
- Inspect the existing `ProgressRepository`, local storage keys, and `ProgressSummary` before implementing.
- Define and implement a safe merge policy for local and cloud data. Do not blindly overwrite newer local progress or lose existing progress.
- Keep progress isolated by Firebase UID. Logging out or switching accounts must never expose another user's cloud progress.
- Preserve guest learning and handle offline login/download failures safely.

**3. Sync status**
- Expose clear states such as `local_only`, `syncing`, `synced`, and `failed`.
- Display the status on the existing Progress or Profile screen using current design conventions.
- Do not claim data is synced until the server confirms success.

**4. Reliability and security**
- Reuse the existing authenticated `ApiClient` and Firebase ID-token flow.
- Preserve backend ownership checks and existing API contracts unless a necessary, documented change is required.
- Do not log tokens, passwords, UIDs, or connection strings.
- Prevent concurrent or repeated requests from causing data loss.

**5. Tests and handoff**
- Add targeted tests for upload triggers, successful and failed uploads, cloud download persistence, merge behavior, account switching, and offline fallback.
- Run `flutter analyze`, relevant Flutter tests, and backend `npm test`.
- Report exact changed files, test results, remaining limitations, and a manual end-to-end verification procedure.
- Clearly distinguish tests that passed from live Firebase/MongoDB integration that has not actually been tested.

Do not mark cloud syncing complete solely because the service methods exist. Keep the changes focused on finishing Phase 16.

### Urgent: Diagnose and fix cloud sync on a physical Android phone

**Observed problem**
- Firebase authentication works.
- Learning progress stays on the device.
- Switching accounts or logging out does not isolate or restore progress.
- MongoDB Atlas `english-udaan-dev` → database `test` → collection `user_progress` contains zero documents.
- The latest app build was tested on a physical Android phone.

**Do not assume syncing works because service methods or tests exist. Diagnose the live request path first.**

1. Inspect `mobile/lib/core/services/api_client.dart` and the production/build configuration. Determine the exact API base URL used by the installed phone build. Check whether it incorrectly uses `http://10.0.2.2:3000`, which is intended for the Android emulator.
2. Inspect `cloud_progress_service.dart` and every upload trigger. Confirm that completing vocabulary, pictures, or quizzes actually invokes `syncToCloud()` and that exceptions are surfaced in the sync status.
3. Add safe, useful diagnostic logging for request URL, endpoint, HTTP status, and sanitized error category. Never log tokens, passwords, UIDs, or connection strings.
4. Verify that the physical phone can reach the configured backend. Use a reachable development-server LAN address for local testing, or the correct HTTPS API URL if a deployed backend exists. Do not hardcode a guessed IP or expose the backend publicly without appropriate security.
5. Verify that the backend is connected to the intended Atlas deployment and database. Compare the configured database name with the Atlas Data Explorer location.
6. Check the authenticated `PUT /api/progress` request end to end. Confirm the Firebase ID token is present, backend verification succeeds, the route returns success, and the expected `user_progress` document is upserted.
7. Check `GET /api/progress` and cloud-to-local restoration on login. Ensure progress is scoped to the authenticated Firebase UID and does not leak across account changes. Guest progress should remain usable locally.
8. Fix only the confirmed causes. Preserve existing learning features and the local-first/offline behavior.

**Validation**
- Rebuild and install the updated app on the physical phone.
- Sign in, complete one quiz or vocabulary section, and verify a successful authenticated upload.
- Confirm a document appears in the correct Atlas `user_progress` collection.
- Sign out, sign in with a different test account, and verify its progress is separate.
- Sign back into the original account and verify restoration.
- Run `flutter analyze`, relevant Flutter tests, and backend `npm test`.
- Report the exact root cause, changed files, actual HTTP results, and what was verified live. Do not claim success without observing the upload and restoration.

### Phase 16 — Diagnose live cloud sync failure on physical Android phone

The latest app build still shows:
- `Progress sync: Sync failed`
- `Saved on device: This device only`

Previous code changes added `API_BASE_URL`, fixed Firebase Admin initialization, and added sanitized diagnostics. The physical-device upload has still not been verified.

**Do not make speculative changes. Find the first failing step in the real sync request.**

1. Inspect the current `API_BASE_URL` configuration and determine exactly how the installed build receives it.
2. Confirm whether the phone is running a newly rebuilt APK with the correct LAN API URL. Check that the URL is not `10.0.2.2`, `localhost`, or `127.0.0.1`.
3. Check whether completing a quiz or vocabulary section actually triggers `syncToCloud()`.
4. Capture the sanitized client diagnostic and matching backend log for the same upload attempt. Report the HTTP status and error category; never expose tokens, passwords, UIDs, or connection strings.
5. Identify which stage fails:
   - phone cannot reach backend;
   - Firebase ID token unavailable;
   - Firebase Admin token verification fails;
   - MongoDB write fails;
   - request succeeds but the app incorrectly records `failed`.
6. Verify the backend is connected to the intended Atlas cluster and the `test` database.
7. If no useful diagnostic exists, add only the minimum safe logging needed to expose the failure category and request outcome.
8. Give me the exact next action based on the observed failure. Do not claim syncing works unless an authenticated upload creates or updates a document in Atlas.

Do not refactor unrelated features or rerun the full test suite unless the identified fix requires it.

# The latest debug build is installed on the physical phone, but Progress still shows “Sync failed”.

I have now signed in and completed a learning activity on the phone.

Inspect the actual client and backend logs from that attempt. Do not rebuild or change code before identifying the failure.

Report:
- Whether `[sync] upload started` appeared.
- Whether `[api] auth_header=present` appeared.
- Whether a `PUT /api/progress` request reached the backend.
- The HTTP status or sanitized network/authentication/database error.
- Whether the backend attempted a MongoDB upsert.
- The single confirmed root cause and smallest fix.

Do not print tokens, passwords, Firebase UIDs, or connection strings. If the logs are not currently available, tell me exactly how to capture them from the connected Android phone using Flutter or `adb logcat`.

### Phase 16 — Fix cloud progress restoration after login

**Confirmed current behavior**
- Firebase authentication works.
- MongoDB Atlas contains two `user_progress` documents with different Firebase UIDs.
- Quiz results and learning sections are being uploaded.
- After logout and login, the Progress screen resets instead of restoring the signed-in account's saved progress.

**Task: diagnose and fix restoration only. Do not rewrite the working upload path.**

1. Trace the complete login restoration flow:
   - Firebase auth-state change / successful login
   - `CloudProgressService.syncFromCloud()`
   - authenticated `GET /api/progress`
   - cloud/local merge
   - persistence to local storage
   - `ProgressRepository` reload and Progress screen refresh

2. Identify the exact cause of the reset. Check whether:
   - the cloud GET response is successful and correctly parsed;
   - downloaded section IDs are mapped to local IDs;
   - downloaded progress is persisted using the exact keys consumed by `ProgressRepository`;
   - quiz results and activity dates are restored;
   - the Progress screen refreshes after restoration;
   - asynchronous local initialization or account-switch clearing overwrites restored data.

3. Implement the smallest safe fix:
   - Restore the authenticated account's cloud data before declaring restoration complete.
   - Merge cloud and local data without losing newer progress.
   - Keep data isolated by Firebase UID.
   - Do not clear restored data during a later initialization step.
   - Preserve guest learning and offline behavior.
   - Show `synced` only after the intended restore/sync operation succeeds; expose failures clearly.

4. Add targeted tests covering:
   - restoring completed vocabulary sections after a new login;
   - restoring quiz scores and activity dates;
   - switching between two accounts without leaking progress;
   - refreshing the Progress screen after restoration;
   - failed/offline download without destructive data loss.

5. Run `flutter analyze`, relevant Flutter tests, and backend `npm test`. Report the exact root cause, changed files, and test results.

**Manual acceptance test**
- Sign in to Account A and record its completed sections and quiz score.
- Log out, then sign back into Account A. The same progress must return.
- Sign in to Account B. Account A's progress must not appear; Account B must show its own saved progress.
- Sign back into Account A and confirm its progress is restored again.

Do not change the database schema or rewrite the upload service unless the diagnosed cause requires it. Do not claim restoration works until it is tested.

### English Udaan Phase 16 — Critical Fix: Isolate Progress by Firebase Account

**Confirmed live bug**
1. Account A completes learning tasks and reaches 15% progress.
2. Logging out and back into Account A correctly restores that progress.
3. Logging into Account B incorrectly shows Account A's 15% progress.
4. Account B completes a quiz and logs out.
5. Logging back into Account A shows Account B's quiz result.

**This is a data-isolation bug. Fix it before any further feature work. Do not change the working authentication or upload implementation unnecessarily.**

#### 1. Trace every progress data source
Inspect:
- `cloud_progress_service.dart`
- `progress_repository.dart`
- `ProgressRepository` local persistence and all SharedPreferences keys
- vocabulary, picture, quiz, and activity-date completion storage
- login, logout, auth-state changes, and account-switch handling
- progress screen/provider initialization and refresh
- backend `GET /api/progress` and `PUT /api/progress`

Identify exactly how Account A's local progress enters Account B's merged state, and how Account B's quiz result later enters Account A's state.

#### 2. Implement account-scoped local storage
- Namespace authenticated progress storage by the verified Firebase UID, or implement an equivalent strictly isolated storage layer.
- Ensure Account A reads and writes only Account A's progress keys, and Account B only Account B's.
- Do not rely solely on clearing shared keys during logout; asynchronous callbacks and late requests must not repopulate the wrong account's data.
- Ensure every async restore/upload operation captures the initiating UID and checks that the current authenticated UID still matches before applying results.
- Keep guest progress separate from authenticated-account progress.
- Preserve each account's cloud data and never upload one account's progress under another account's token.

#### 3. Correct merge and lifecycle behavior
- Merge cloud data only with local data belonging to the same account.
- On account switch, invalidate or reload all progress repositories/providers so stale UI state cannot remain visible.
- Prevent pending quiz saves, completion writes, or downloads from a previous session from mutating the newly active account.
- Preserve local-first/offline learning within the correct guest/account scope.
- Do not delete or reset existing MongoDB records as a workaround.

#### 4. Add regression tests
Test at minimum:
- Account A completes vocabulary; Account B starts with only B's own progress.
- Account B completes a quiz; Account A never sees that quiz result.
- A → B → A restores the correct independent progress for each account.
- A delayed Account A download finishing after B signs in cannot overwrite B.
- Logout and guest learning do not expose the previous account's progress.
- Uploads use the intended account's Firebase token and progress payload.
- Progress screen/providers refresh correctly after account changes.

Run `flutter analyze`, the relevant Flutter tests, and backend `npm test`. Fix relevant failing tests rather than dismissing them without investigation.

#### 5. Live acceptance test
Use two test accounts and verify the sequence on the physical phone:
1. A completes a distinctive section and records a quiz score.
2. B signs in and sees only B's saved progress.
3. B completes a different quiz.
4. A signs back in and sees A's section and quiz, not B's.
5. B signs back in and sees B's quiz, not A's.
6. Verify the two MongoDB documents remain distinct.

Report the confirmed root cause, changed files, test results, and live acceptance results. Do not claim account isolation is fixed until the physical-device A/B/A test passes.

**Security priority:** Prevent cross-account data leakage first. Keep Phase 17 on hold until this is resolved.

# English Udaan — Rebuild Progress Synchronization Around Account-Based Cloud Storage

## Objective

Replace the unreliable local-first/shared-progress synchronization behaviour with a strict Firebase-account-based cloud progress system.

MongoDB Atlas must be the authoritative persistent source of learner progress.

Every authenticated Firebase account must have completely independent progress. Progress must never be shared between accounts or retained as guest progress.

Do not simply patch the current merge logic. Inspect the entire progress lifecycle first, identify all existing progress storage and triggers, and implement this target architecture with minimal disruption to working learning modules.

## 1. Guest / unauthenticated behaviour

When no Firebase account is signed in:

- Allow access to learning lessons and practice quizzes.
- Do not persist completed sections, quiz results, activity dates, streaks or progress metrics.
- Do not write progress to SharedPreferences, secure storage, files, or MongoDB.
- Progress shown during a guest session may be temporary in-memory information only.
- Clear this temporary information when the app restarts or the guest session ends.
- Do not upload guest progress automatically after registration or login.
- Do not merge guest progress into an authenticated account.

## 2. Authenticated account behaviour

When Account A signs in:

1. Obtain the currently authenticated Firebase UID.
2. Clear previous account and guest progress from active memory.
3. Fetch Account A's progress using the authenticated `GET /api/progress` endpoint.
4. Validate the response and verify that it belongs to the currently active UID.
5. Populate the existing ProgressRepository and Progress screen from the cloud response.
6. Show a loading state while restoring.
7. Only after successful restoration allow cloud progress updates.

When Account A completes a vocabulary section, picture lesson or quiz:

1. Capture the active Firebase UID.
2. Obtain a valid Firebase ID token.
3. Submit the progress update to the backend.
4. Backend verifies the token and obtains the UID from the verified token.
5. Backend saves the update in MongoDB under that UID.
6. Only after the server confirms success should the application show the progress as cloud-saved.

Use the existing learning modules and progress models. Do not recreate the learning screens.

## 3. Account-specific backend storage

Inspect the existing UserProgress schema and API routes.

Enforce these rules:

- Each Firebase UID has exactly one corresponding progress document.
- Enforce a unique MongoDB index on `firebaseUid`.
- All database lookups and updates use `req.uid` from verified Firebase authentication middleware.
- Never trust a UID supplied in the request body.
- `GET /api/progress` returns only the authenticated user's document.
- Progress updates can create or update only the authenticated user's document.
- Do not use shared device IDs to identify authenticated progress.
- Preserve existing MongoDB records and schema compatibility where possible.
- Use safe, atomic, idempotent updates so repeated requests do not create duplicate quiz results or overwrite unrelated progress fields.

Do not blindly replace the entire MongoDB progress document with a potentially incomplete client snapshot.

## 4. Logout and account switching

On logout:

- Immediately clear the active UID.
- Clear all in-memory progress and progress-provider state.
- Cancel or invalidate outstanding progress requests.
- Clear temporary guest/session progress.
- Prevent delayed callbacks from the previous account from changing the next session.
- Do not leave the previous account's progress visible on Home, Progress, Practice or Profile.

On account switching:

- Treat it as a completely new progress session.
- Fetch the new account's progress from MongoDB before displaying its saved progress.
- Never merge Account A's progress with Account B's progress.

Every asynchronous upload and download must verify that the initiating UID still matches the active Firebase UID before applying results.

## 5. Critical restoration and failure handling

Do not display zero progress as though restoration succeeded when the cloud request has failed.

Implement explicit states:

- `unauthenticated`
- `loading`
- `synced`
- `syncing`
- `failed`

Rules:

- Do not upload an empty progress snapshot automatically during login.
- Do not upload or merge anything if the initial cloud download fails.
- Provide a retry action for failed cloud restoration.
- Preserve the distinction between a genuinely new account with no cloud document and a failed download.
- Do not report `synced` before the backend confirms success.
- If an upload fails, show an error and allow retry while the account remains signed in.
- Do not persist unsynced progress locally after logout.

## 6. Flutter implementation inspection

Inspect all of the following and update every relevant progress read/write path:

- `ProgressRepository`
- `CloudProgressService`
- `AuthService`
- authentication providers and auth-state listeners
- Progress screen and progress providers
- vocabulary completion handlers
- picture completion handlers
- quiz result persistence
- activity-date and streak calculation
- logout and account-switch logic
- all SharedPreferences progress keys

Remove old shared and account-scoped persistent progress writes if they violate the new requirement.

Do not leave a hidden code path that continues writing progress while unauthenticated.

Keep preferences such as theme, language and audio settings persistent; only learning progress persistence is changing.

## 7. Required automated regression tests

Add or update tests for:

1. Guest learning does not persist progress.
2. Guest progress is never uploaded after login.
3. A new Account A restores its own progress.
4. Account A completion updates only Account A's MongoDB record.
5. Account B restores only its own progress.
6. Account B quiz results never appear in Account A.
7. Account A → Account B → Account A restores the correct independent records.
8. Logout immediately clears displayed progress.
9. Delayed Account A downloads cannot overwrite Account B.
10. Delayed Account A uploads cannot be submitted under Account B's token.
11. Failed GET never triggers an empty PUT.
12. Failed upload never displays `synced`.
13. A genuinely new account with no document starts with empty progress.
14. Repeated quiz updates do not create duplicate results.

Run:
- `flutter analyze`
- Relevant Flutter unit and widget tests
- Backend `npm test`
- Backend integration tests for authenticated account isolation

Fix relevant regressions rather than dismissing failures without investigation.

## 8. Physical-device acceptance test

Use two newly created Firebase test accounts.

Account A:
- Sign in.
- Complete one distinctive vocabulary section.
- Submit one quiz.
- Confirm the correct document appears in MongoDB Atlas.

Account B:
- Sign out.
- Sign in.
- Confirm only Account B's cloud progress appears.
- Complete a different quiz.
- Confirm a separate MongoDB document is created or updated under B's verified UID.

Return to Account A:
- Sign out and sign back into A.
- Confirm A's vocabulary completion and quiz result are restored.
- Confirm B's quiz is absent.

Return to Account B:
- Confirm B's independent quiz is restored.
- Confirm A's completion is absent.

Guest test:
- Sign out.
- Complete a lesson and quiz.
- Confirm no progress document is created or updated and no persistent local progress is written.

## 9. Handoff requirements

Report:
- Exact root cause of the previous cross-account and restoration failures.
- All changed files.
- Which local progress keys and write paths were removed.
- Final API request/response structure.
- MongoDB schema and unique-index behaviour.
- Automated test results.
- Actual physical-device Account A/B/A results.
- Actual guest-mode result.

Do not claim this system is complete based only on unit tests or the existence of service methods.

**Highest priority: strict account isolation and cloud-authoritative progress. Do not begin Phase 17 until the physical-device acceptance tests pass.**

### Final Architecture Audit — English Udaan Cloud-Only Progress

The previous implementation report still states that authenticated progress is stored in UID-scoped SharedPreferences keys.

This does not meet my explicit requirement.

**MongoDB Atlas must be the only persistent storage for learning progress.**

Please perform another focused audit and make the following corrections:

1. Remove persistent SharedPreferences or other device-storage writes for all learning progress, including account-scoped keys:
   - Vocabulary completion
   - Picture completion
   - Quiz results
   - Activity dates and streaks
   - Progress sync state

2. Keep the active learner's progress in memory only while authenticated. Populate it using `GET /api/progress`.

3. When a lesson or quiz is completed:
   - Update the in-memory state.
   - Send the authenticated progress update to Express.
   - Wait for the server's successful response before reporting that progress is saved to cloud.
   - If the request fails, clearly show that the result was not saved. Do not silently retain it as persistent local progress.

4. On logout:
   - Clear all in-memory learning progress and progress providers.
   - Invalidate pending operations.
   - Do not leave account-specific progress stored on the device.

5. On account switching:
   - Fetch only the newly authenticated account's MongoDB record.
   - Never merge data from a previous account.
   - Prevent delayed requests from applying data to a different session.

6. Guest mode:
   - Lessons and quizzes remain usable.
   - Progress may be calculated temporarily in memory.
   - Do not write guest progress to persistent device storage or MongoDB.
   - Clear guest progress when the session ends.

7. Inspect the backend PUT implementation. Ensure that a progress update cannot overwrite unrelated or newer progress fields with a stale client snapshot. Preserve Firebase UID ownership enforcement and implement safe atomic updates if necessary.

8. Add tests proving:
   - No progress-related persistent storage writes for guests.
   - No progress-related persistent storage writes for authenticated users.
   - Successful cloud restoration populates memory correctly.
   - A/B/A switching never mixes progress.
   - Failed GET does not trigger an empty PUT.
   - Failed PUT never reports cloud-saved.
   - Logout clears progress completely.

9. Run Flutter analysis, targeted Flutter tests and backend tests.

Do not change learning content or redesign screens. Preserve preferences such as language, theme and audio settings.

Report the actual persistent storage operations remaining in the code. Do not claim cloud-only architecture until the audit confirms that no learning progress is persisted locally.

### English Udaan — Final Cloud-Only Progress Validation

Continue from the existing cloud-only implementation. Do not redesign or rewrite working modules.

**1. Migrate the Flutter tests**
- Remove old test fixtures that seed or inspect SharedPreferences progress keys.
- Test ProgressRepository using in-memory session fixtures.
- Test CloudProgressService using mocked authenticated API responses.
- Test guest sessions, account switching, restoration, logout and upload failure.
- Ensure no progress-related SharedPreferences writes are expected by tests.
- Fix relevant failing tests rather than marking them as expected failures.

**2. Verify upload success semantics**
- Inspect vocabulary, picture and quiz completion handlers.
- Confirm an authenticated completion triggers the appropriate cloud update.
- Confirm the Firebase ID token belongs to the initiating UID.
- Do not display `Saved to cloud` or `synced` until the backend confirms success.
- On HTTP/network failure, show `Sync failed` and provide a retry mechanism.
- Prevent duplicate submissions and stale account requests.

**3. Verify guest behaviour**
- Guest lessons and quizzes remain usable.
- Guest progress is memory-only.
- No guest progress is stored persistently or uploaded after login.
- Restarting or ending the guest session clears its progress.

**4. Audit the final code**
Search the entire mobile project for progress persistence through:
- SharedPreferences
- secure storage
- files or local databases
- cached repositories

Report every remaining use and confirm that none stores learning progress. App preferences such as language and theme may remain persistent.

**5. Backend safeguards**
- Confirm all progress reads and writes are scoped to the Firebase-verified `req.uid`.
- Confirm the MongoDB unique index on `firebaseUid` exists.
- Verify account updates preserve unrelated progress fields.
- Add regression tests for Account A/B separation and repeated updates.

**6. Validation**
Run:
- `flutter analyze`
- All relevant migrated progress, practice, authentication and navigation tests
- Backend `npm test`

Do not claim completion while relevant Flutter tests are failing.

Report the exact test counts, remaining storage operations and the manual physical-device test procedure. Do not change learning content or UI unnecessarily.

# CRITICAL TASK: Permanently Fix English Udaan Cloud Progress Sync (End-to-End)

This is a critical production-readiness issue. Do not make another superficial fix, add another workaround, or simply report that the code looks correct. Investigate the complete Flutter → Firebase Authentication → Express API → MongoDB progress-saving pipeline, identify the actual root cause, implement the necessary fixes across the entire pipeline, and validate the result.

**The goal is to solve this issue end-to-end in this task, not to produce another audit that requires multiple rounds of fixes.**

## 1. Required product behavior — these rules are mandatory

English Udaan must have strictly cloud-only persistent learning progress.

**Guest users (not logged in):**
- Can use all learning modules, lessons, practice activities, and quizzes.
- Progress exists only temporarily in memory during the active guest session.
- Do not save guest progress to SharedPreferences, local files, SQLite, secure storage, or any other persistent device storage.
- Never create a MongoDB progress document for a guest.
- Never upload guest progress.
- When the guest session ends, guest progress must be cleared.

**Authenticated users:**
- Each user's progress belongs exclusively to their Firebase UID.
- On successful login, fetch that user's progress from MongoDB through the authenticated API.
- All learning events must update the active in-memory progress and successfully synchronize the corresponding changes to MongoDB.
- On successful restoration, display the user's actual saved progress.
- On logout, clear all account-specific in-memory progress.
- When another account logs in, fetch only that account's progress.
- Account A must never see, overwrite, upload, or receive Account B's progress, and vice versa.
- Do not use local persistent progress as a fallback or as an upload queue. MongoDB remains the only persistent source of learning progress.

These requirements must remain intact throughout the fix.

## 2. Evidence from actual MongoDB testing

I have already tested the app on a physical Android device.

In MongoDB Atlas, database `test`, collection `user_progress`, I can see two documents with different `firebaseUid` values.

However:
- Both documents have `sections: []`.
- Both documents have `quizResults: []`.
- One document also has `currentStreak: 0` and `longestStreak: 0`.
- The other document has `currentStreak: 1`, `longestStreak: 1`, and a populated `lastActivityDate`.
- Their `updatedAt` timestamps change, but actual lesson-completion and quiz-result data is missing.

This is the key evidence.

Authentication and at least some backend progress-document operations appear to work. However, the important learning progress is not getting saved correctly.

**Do not assume this is only a network problem. Investigate the separate lesson-completion, section-completion, quiz-result, and activity-update pipelines.**

## 3. Perform a complete root-cause investigation before editing

Trace every relevant operation from the actual Flutter UI event to the final MongoDB document.

Inspect the entire relevant codebase, including:

### Flutter frontend
- `ProgressRepository`
- `CloudProgressService`
- Authentication/session management
- Firebase ID-token retrieval and API client
- API request/response serialization
- Vocabulary completion handlers
- Picture-learning completion handlers
- Alphabet completion, where applicable
- Sentence and paragraph completion
- Grammar lesson completion
- Practice and quiz submission handlers
- Progress screen
- Logout and account-switching logic
- Any other code that modifies completed sections, quiz results, streaks, or activity dates.

Do not inspect only the repository methods. Trace the actual UI event handlers to confirm that they call the correct repository method and that the repository triggers cloud synchronization.

### Backend
Inspect:
- Firebase Admin initialization.
- Firebase token-verification middleware.
- `req.uid` ownership handling.
- `GET /api/progress`.
- `PUT /api/progress`.
- Progress route controllers and services.
- Mongoose `UserProgress` schema.
- Schema field names, types, defaults, validation and strict-mode behavior.
- MongoDB connection and database selection.
- Update and upsert operations.
- Backend response serialization.

### Specifically investigate these possible failure points

1. Flutter updates in-memory progress, but never invokes the cloud-upload method.
2. A completion handler modifies one data structure while the cloud service reads a different data structure.
3. The frontend sends `completedSections` while the backend expects `sections`, or any other payload-field mismatch.
4. Quiz results are calculated but not included in the PUT request.
5. The backend receives the payload but Mongoose drops fields because of schema mismatch, incorrect types, strict mode, or nested-field validation.
6. The merge operation overwrites valid arrays with empty arrays from an incomplete request.
7. A request is sent using an outdated Firebase UID or an expired/missing ID token.
8. A user session is marked active before the cloud service is ready, causing synchronization to be skipped.
9. An asynchronous account-switching or restoration response overwrites the current account's progress.
10. API calls report success without confirming that MongoDB actually persisted the intended changes.
11. The backend connects to a different database or collection from the one being inspected in Atlas.
12. The upload method is triggered only for activity dates/streaks but not for lesson completion or quiz submission.

Do not assume any one of these is the cause. Prove the actual cause from the code and runtime/test evidence.

## 4. Implement one consistent progress data contract

Establish one consistent, documented data contract between Flutter and the backend.

It must correctly support the existing learning-progress model, including:

- Completed learning sections and categories.
- Completed lessons/items, wherever currently supported by the app.
- Quiz results, including quiz type, score, total questions, and attempt date, according to the existing model.
- Activity dates.
- Current streak.
- Longest streak.
- Updated timestamp.

Inspect the existing implementation and preserve its established data structure where appropriate. Do not introduce duplicate fields or incompatible formats.

For every field, confirm:
- The Flutter model uses the intended field name and type.
- JSON serialization produces the correct structure.
- The API receives that structure.
- The backend validates and processes it.
- Mongoose persists it.
- The GET endpoint returns the same data in the format Flutter expects.

Do not silently discard fields.

## 5. Fix the actual synchronization architecture

Implement a reliable, centralized cloud-progress flow.

### On authenticated login
1. Wait until Firebase authentication is established.
2. Obtain the authenticated user's current Firebase ID token.
3. Activate a fresh in-memory session for that exact UID.
4. Fetch progress from `GET /api/progress`.
5. Restore all saved sections, lessons, quiz results, activity dates, and streak values.
6. Update the Progress UI only with the response belonging to the active UID.
7. Do not send an empty PUT request merely because a new account has no existing progress document.

### On each learning event
When an authenticated user completes a lesson, section, learning category, or quiz:

1. Update the active user's in-memory progress.
2. Construct the correct complete API payload or a safely defined partial update.
3. Send the update using the authenticated Firebase token.
4. Persist the update under the authenticated `req.uid`.
5. Verify the successful backend response.
6. Update the UI's sync status only after successful persistence is confirmed.

This must work for every relevant learning module, not just quizzes or streak updates.

### On synchronization failure
- Do not display a false "Synced" status.
- Show a clear failed/not-synced state.
- Preserve the current session's in-memory progress while the app remains active.
- Provide a working retry mechanism.
- Do not persist a retry queue to device storage.
- Do not automatically submit an empty snapshot after a failed GET request.
- Ensure a failed or delayed request cannot overwrite progress belonging to a different account.

### On logout and account switching
- Clear all account-specific in-memory progress.
- Invalidate or disregard outstanding requests from the previous UID.
- Never upload the previous account's data using the next account's token.
- Fetch the newly authenticated account's data before displaying its progress.

## 6. Correct backend persistence and merge behavior

The backend must use the verified Firebase identity as the sole account owner.

Requirements:
- All GET and PUT operations must use `req.uid` from verified Firebase authentication.
- Never accept a client-provided UID as the authority for document ownership.
- Maintain a unique index on `firebaseUid`.
- Use safe, atomic MongoDB updates.
- Do not replace valid existing sections or quiz results with empty arrays just because a partial request omitted those fields.
- Make repeated requests safe and idempotent where appropriate.
- Ensure concurrent updates do not accidentally erase unrelated progress.
- Validate the payload and return meaningful HTTP errors for invalid updates.
- Return the persisted document or a reliable confirmation of the committed update, not merely a generic success message.

Also inspect the current streak logic. Do not preserve a maximum-ever streak as the current streak. Current streaks must be calculated from activity dates correctly, while longest streak remains a historical maximum.

For quiz results, follow the intended Progress screen semantics: verify whether it displays the latest attempt or best attempt, and make both backend merge and frontend display consistent with that choice.

## 7. Add comprehensive regression and integration tests

Do not merely update old tests to match the implementation. Tests must prove that the required behavior actually works.

### Flutter tests
Cover:
1. Guest lesson completion remains in memory only.
2. Guest quiz results remain in memory only.
3. No guest cloud upload occurs.
4. Guest session termination clears progress.
5. Authenticated login fetches existing cloud progress.
6. Lesson completion triggers a correct authenticated upload.
7. Section/category completion triggers a correct authenticated upload.
8. Quiz submission uploads the correct quiz result.
9. Successful responses update sync status.
10. Failed uploads never report successful synchronization.
11. Failed GET restoration does not trigger an empty PUT.
12. Retry works without persistent local progress storage.
13. Logout clears the in-memory account session.
14. Account A → Account B switching does not leak data.
15. A delayed Account A response cannot overwrite Account B's state.
16. Account B logout → Account A login restores only A's cloud data.
17. An update with omitted fields does not erase unrelated saved progress.

### Backend tests
Cover:
1. Unauthenticated requests are rejected.
2. A verified Firebase UID can read only its own progress.
3. A verified Firebase UID can update only its own progress.
4. Client-supplied UID cannot override `req.uid`.
5. Sections are correctly persisted.
6. Quiz results are correctly persisted.
7. Activity dates and streaks are correctly persisted.
8. Partial updates do not erase unrelated data.
9. Repeated updates do not create duplicate progress documents.
10. Account A and Account B remain completely isolated.
11. Invalid payloads return appropriate errors.
12. GET returns data in the exact format expected by Flutter.

Add an integration test that simulates the complete journey:

**Firebase-authenticated user → lesson completion → API request → Express backend → MongoDB persistence → GET restoration → Flutter progress state.**

Use an appropriate test database or controlled fixtures. Never make tests depend on production user data.

## 8. Verify the actual physical-device/API configuration

Inspect the current Android API configuration and ensure the app uses the correct reachable backend address.

- `10.0.2.2` is for the Android emulator, not a physical phone.
- For a physical Android phone, the configured API base URL must be the development computer's reachable LAN address or an explicitly configured deployed backend URL.
- Ensure Express listens on an address reachable from the phone.
- Verify network security/Cleartext HTTP configuration for the debug build, if HTTP is being used.
- Verify the backend port and firewall requirements.
- Confirm the API URL is not accidentally hardcoded differently in one part of the app.

Add safe diagnostic logging for:
- Active Firebase UID (never log tokens).
- Request endpoint and method.
- Progress event type.
- Sanitized payload field names and item counts.
- HTTP status.
- Backend error message.
- Whether MongoDB persistence succeeded.

Never log passwords, Firebase ID tokens, private keys, or sensitive personal information.

## 9. Required validation before declaring completion

Run:
- `flutter analyze`
- All relevant Flutter tests, not just one passing test file.
- Full backend test suite using `npm test`.
- Any new integration tests.
- A search/audit confirming there are no remaining persistent local learning-progress reads or writes.
- A search/audit confirming all learning completion and quiz handlers reach the central cloud-progress flow.

Do not stop when tests pass if the code still contains an unconnected event handler or a mismatched API field.

If a physical Android device and real Firebase test accounts are available in the development environment, run the actual device test too. Otherwise, clearly report that hardware testing could not be performed; never claim it passed.

## 10. Mandatory acceptance scenario

The implementation is not complete until this behavior is demonstrated:

**Guest**
- Open app without login.
- Complete a lesson and quiz.
- Verify no MongoDB progress document is created or updated for the guest.
- End the guest session and verify progress disappears.

**Account A**
- Sign in with Firebase Account A.
- Restore A's cloud progress.
- Complete a lesson and submit a quiz.
- Verify MongoDB document for A has the correct populated `sections` and `quizResults`, along with appropriate activity data.
- Log out.

**Account B**
- Sign in with Firebase Account B.
- Verify only B's progress is shown.
- Complete a different lesson and submit a different quiz.
- Verify B's MongoDB document contains B's progress, independently of A.
- Log out.

**A/B/A isolation**
- Sign in again with Account A.
- Verify A's earlier lesson and quiz are restored.
- Verify none of B's data appears.
- Sign in with B again and verify only B's progress returns.

The two Firebase UIDs must have separate MongoDB documents and independently restorable progress.

## 11. Scope restrictions

- Do not redesign the UI.
- Do not change learning content.
- Do not weaken Firebase authentication or backend security.
- Do not introduce local persistent progress storage.
- Do not delete existing MongoDB progress documents or Firebase users.
- Do not hide synchronization failures.
- Do not mark the task complete based only on `flutter analyze` or unit tests.
- Do not start Phase 17 or implement new features until this issue is resolved.

## 12. Final report required

At the end, give me a concise but evidence-based report containing:

1. The exact root cause(s) discovered.
2. The exact files changed and why.
3. The exact frontend-to-backend progress flow after the fix.
4. The final API payload structure and MongoDB document structure.
5. Flutter analysis and test results.
6. Backend and integration test results.
7. Confirmation that guest progress is not persisted or uploaded.
8. Confirmation that authenticated lesson and quiz progress is actually written to MongoDB.
9. Whether physical-device A/B/A testing was performed and its actual result.
10. Any remaining blocker, with its precise cause.

**Success means actual authenticated lesson and quiz progress is saved to MongoDB and correctly restored for the same user, while guest progress remains temporary and Account A and Account B remain isolated. A newly created MongoDB document with empty arrays is not proof of success.**

# URGENT: Find and Fix the Actual English Udaan Progress-Sync Failure

The latest physical-device test still fails.

MongoDB Atlas shows two separate `user_progress` documents with different Firebase UIDs. Their `updatedAt` timestamps change after I use the app, but BOTH documents still contain:

- `sections: []`
- `quizResults: []`

The Progress tab also continues to show 0%.

This means the current implementation is not successfully saving actual learning progress. Do not make another speculative fix.

**I need you to identify exactly where the progress data disappears and fix that specific failure.**

## 1. Stop investigating already-established areas

Do not redesign Firebase authentication, MongoDB connection configuration, account isolation, or the UI unless the diagnostic evidence specifically proves one of these is responsible.

Do not introduce local persistent progress storage.

Preserve these requirements:
- Guest progress stays in memory only and is never uploaded.
- Authenticated progress is saved only to MongoDB.
- Account A and B remain isolated.
- Logout clears account-specific in-memory progress.

## 2. Trace the complete data pipeline

Follow this exact sequence for one vocabulary completion and one quiz submission:

Flutter UI event
→ event handler
→ ProgressRepository
→ in-memory progress snapshot
→ CloudProgressService
→ JSON serialization
→ authenticated PUT /api/progress
→ Express route
→ Firebase authentication middleware
→ backend merge/update logic
→ Mongoose UserProgress document
→ MongoDB persistence
→ GET /api/progress
→ Flutter deserialization
→ ProgressRepository restoration
→ Progress tab calculation.

Do not assume that a method is connected just because it exists.

Confirm that actual UI interactions invoke it.

## 3. Add temporary diagnostic logging at every critical boundary

Add safe development-only logs with a request/correlation ID so we can follow one event across Flutter and the backend.

### Flutter logs

After a user completes a lesson, log:
- Event name.
- Whether the user is authenticated.
- Active UID suffix, never the Firebase token.
- ProgressRepository state before and after the event.
- Number of completed sections and lessons.
- Number of quiz results.
- The exact serialized PUT JSON payload.
- HTTP response status and response data.
- Whether the returned persisted values match the submitted values.

Do the same for quiz submission.

### Backend logs

At the PUT endpoint, log:
- Request/correlation ID.
- Verified UID suffix from `req.uid`.
- Top-level request body field names.
- Whether `sections` exists and its array length.
- Whether `quizResults` exists and its array length.
- Any schema validation or merge errors.
- Whether MongoDB update succeeded.
- The saved document's sections and quizResults counts AFTER persistence.

Also log the GET response counts.

Never log passwords, Firebase tokens, private keys, or other secrets.

## 4. Identify which of these four failure points is occurring

You must explicitly determine which condition is true:

A. The learning event never updates ProgressRepository.

B. ProgressRepository updates correctly, but CloudProgressService sends an empty or incorrect payload.

C. The correct payload reaches Express, but backend validation, mapping, merging, or Mongoose persistence discards the fields.

D. MongoDB actually contains progress, but GET deserialization or Progress screen calculations incorrectly show zero.

Do not guess. Use the logs, request payload, backend response, and persisted document to identify the exact failure.

There may be more than one issue, so check the entire path.

## 5. Fix the root cause

After identifying the issue:
- Fix the actual event handler, repository, serializer, API client, backend mapping, schema, or progress calculation responsible.
- Ensure lesson and quiz completion data are included in the outgoing payload.
- Ensure backend updates do not replace populated arrays with empty arrays.
- Ensure MongoDB returns the saved data.
- Ensure the Progress screen reads the restored data correctly.
- Ensure failed updates never show a false synced status.

Do not add hardcoded progress, fake scores, or dummy MongoDB records.

## 6. Add only the tests needed to prove this fix

Create focused tests that:
1. Complete a vocabulary item and verify it appears in the actual outgoing HTTP JSON.
2. Submit a quiz and verify its result appears in the actual outgoing HTTP JSON.
3. Submit both payloads to the backend and verify populated arrays in the saved document.
4. Fetch the progress and verify the same data is restored into Flutter.
5. Verify Progress screen calculations are no longer zero when saved progress exists.
6. Verify guest users still do not upload progress.
7. Verify Account A and B remain isolated.

Do not spend time fixing unrelated existing UI tests for this task.

## 7. Final requirement

Run the app with the physical-device API configuration and leave the diagnostic logs enabled for this development test.

After fixing, give me:
- The exact root cause.
- The exact files changed.
- One real example of the outgoing PUT payload.
- The backend-received payload counts.
- The MongoDB saved-document counts.
- The GET restoration counts.
- The Flutter test results.

Do not report the issue fixed merely because `updatedAt` changes or a MongoDB document is created.

**The fix is successful only when a real authenticated lesson completion populates `sections`, a real quiz submission populates `quizResults`, and the Progress tab displays the restored progress.**

# URGENT: Finish English Udaan Learn Hub and AI Dictionary for Presentation

The cloud-progress functionality has now been successfully tested on a physical Android device:
- Guest progress is temporary.
- Account A and Account B save progress independently.
- Logout/login correctly restores each account's progress.

Do not modify, refactor or risk breaking this completed functionality.

We now need to complete two remaining features.

## TASK 1: Replace the empty Learn tab

In `mobile/lib/main.dart`, the `/learn` route currently renders `PlaceholderScreen(destination: AppDestination.learn)`.

Replace this with a proper `LearningHubScreen`.

Reuse the existing routes and learning screens. Create a professional bilingual hub with cards for:

1. English Alphabet → `/learn/alphabet`
2. Vocabulary → `/learn/vocabulary`
3. Picture Learning → `/learn/pictures`
4. Sentences & Paragraphs → `/learn/sentences`
5. English Grammar → `/learn/grammar`
6. Urdu-to-English Dictionary → `/learn/dictionary`

Requirements:
- Follow English Udaan's existing teal design system.
- Support Urdu and English.
- Preserve RTL/LTR behavior.
- Support light, dark and system themes.
- Use existing reusable widgets.
- Ensure every card navigates to a real screen.
- Do not leave empty placeholders.
- Add a short introductory section and suitable icons.

## TASK 2: Implement the AI dictionary

Create a dedicated Flutter dictionary feature with proper separation of:
- Presentation
- Domain models
- Repository
- API service

### User functionality

- Search an Urdu word or English word.
- Clear the search.
- Submit by button or keyboard.
- Display loading, empty, offline, error and retry states.
- Display the returned English word or translation.
- Display Urdu meaning.
- Display a simple English explanation.
- Display part of speech.
- Display two example sentences with Urdu translations.
- Add a pronunciation button using the existing SpeechService.
- Clearly label database results and AI-generated results.

### Backend architecture

Add a protected-from-abuse, validated endpoint:

`POST /api/dictionary/lookup`

Request:
- query
- sourceLanguage
- targetLanguage

Response:
- query
- source
- englishWord
- urduMeaning
- simpleDefinition
- partOfSpeech
- examples
- optional pronunciationText

Implement:
1. Search the dictionary database first.
2. Return a database result without invoking AI when a suitable entry exists.
3. For missing words or contextual questions, invoke a configured server-side AI provider.
4. Validate the provider response before returning it.
5. Add a strict request-length limit, rate limiting, request timeout and safe error responses.
6. Never expose AI keys in Flutter, logs or Git.
7. Do not invent successful AI responses when the provider is unavailable.

Use a provider-neutral interface so the provider can be changed without changing Flutter. Read the provider API key and model from environment variables. If no key is configured, database search must still work and the UI must clearly report that live AI lookup is currently unavailable.

Do not silently introduce paid API usage or embed a secret. Document exactly which API key and environment variables must be configured.

If the backend needs starter dictionary records, create a small, curated seed dataset and a repeatable seed script.

### Navigation

Register the dictionary route under `/learn/dictionary` and link to it from both Learn Hub and, where appropriate, Home.

### Tests

Add focused tests for:
- Learn hub navigation.
- Urdu and English labels.
- Database dictionary lookup.
- AI fallback when configured.
- Provider-unavailable error handling.
- Invalid and oversized search requests.
- Pronunciation button.
- No API keys exposed to the client.

### Restrictions

- Do not alter authentication or progress synchronization.
- Do not change MongoDB user-progress schemas.
- Do not redesign other screens.
- Do not add fake AI data.
- Do not add subscription or payment features.

### Final report

Report changed files, commands run, test results, dictionary endpoint, required environment variables and whether real AI lookup was verified with a working API key.

Prioritize a buildable implementation and finish the Learn Hub first, followed by the dictionary.

# URGENT: Fix Gemini AI configuration. Do not modify Flutter or dictionary UI.

Evidence:
- `node -e "require('dotenv').config(); console.log({provider:process.env.AI_PROVIDER, keyLoaded:Boolean(process.env.AI_API_KEY)})"` returns `{provider:'google', keyLoaded:true}`.
- Backend starts and connects to MongoDB.
- Flutter calls POST `/api/dictionary/lookup`.
- An unseeded search returns HTTP 503: `DictionaryAiUnavailableException: AI key not configured`.

Investigate the complete environment configuration path:

`backend/.env` → dotenv → environment.js → validated configuration → ai-provider.js → Google Gemini client.

IMPORTANT: Inspect whether the Zod environment schema declares `AI_PROVIDER`, `AI_API_KEY`, and `AI_MODEL`. Zod object parsing can strip undeclared properties. If the provider service receives the parsed configuration rather than `process.env`, this could explain why the key is loaded but the AI service considers it missing.

Required actions:

1. Inspect the current `environment.js`, `server.js`, `ai-provider.js`, dictionary route and app initialization.
2. Identify exactly where AI_PROVIDER and AI_API_KEY become unavailable.
3. Fix the configuration schema and ensure the same validated configuration is passed to the AI provider.
4. Ensure dotenv loads before configuration is read.
5. Add safe startup diagnostics showing:
   - provider name;
   - whether the API key is configured;
   - selected model name.
   Never print the actual key.
6. Add a test proving that AI_PROVIDER=google and a non-empty AI_API_KEY survive environment validation and reach the provider factory.
7. Distinguish missing-key errors from invalid-key, permission, quota, unsupported-model and network errors. Do not convert every error into `AI key not configured`.
8. Test a real unseeded dictionary query using the configured Gemini provider.
9. Preserve database-first lookup, rate limiting, response validation and all existing authentication/progress code.

Do not stop after unit tests. Report the exact root cause and whether a real Gemini API request succeeded.

Do not modify the Flutter app unless evidence proves a frontend issue.