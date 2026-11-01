# Learn Hub and AI Dictionary Handoff

## Implementation

Completed the presentation-focused Learn Hub and dictionary feature requested in `prompts.md`.

### Learn Hub

- Replaced `/learn` `PlaceholderScreen` with `LearningHubScreen`.
- Added bilingual cards linking to:
  - `/learn/alphabet`
  - `/learn/vocabulary`
  - `/learn/pictures`
  - `/learn/sentences`
  - `/learn/grammar`
  - `/learn/dictionary`
- Reused `LearningCard`, `AppSectionHeader`, theme tokens, settings navigation, and existing teal design system.
- Urdu remains the default RTL presentation; English remains LTR through existing app preferences.
- Existing light, dark, and system theme support is unchanged.

### Dictionary

Flutter files:

- `mobile/lib/features/dictionary/domain/dictionary_models.dart`
- `mobile/lib/features/dictionary/data/dictionary_api_service.dart`
- `mobile/lib/features/dictionary/data/dictionary_repository.dart`
- `mobile/lib/features/dictionary/presentation/dictionary_screen.dart`
- `mobile/lib/features/learning/presentation/learning_hub_screen.dart`
- `mobile/lib/main.dart`

The dictionary UI supports:

- Urdu or English query selection.
- Search submission by button or keyboard.
- Clear search.
- Loading, empty, offline, retry, API error, and AI-unavailable states.
- English word, Urdu meaning, simple definition, part of speech, and examples.
- Database vs AI-generated result labels.
- Existing `DeviceSpeechService` pronunciation button.
- No AI credentials in the Flutter client.

Backend files:

- `backend/src/models/dictionary-entry.js`
- `backend/src/routes/dictionary.js`
- `backend/src/services/ai-provider.js`
- `backend/src/config/environment.js`
- `backend/src/app.js`
- `backend/seed-dictionary.js`
- `backend/.env.example`

Endpoint:

```text
POST /api/dictionary/lookup
```

Request body:

```json
{
  "query": "سیب",
  "sourceLanguage": "ur",
  "targetLanguage": "en"
}
```

Response data contains `query`, `source`, `englishWord`, `urduMeaning`, `simpleDefinition`, `partOfSpeech`, `examples`, and `pronunciationText`.

The endpoint validates request length and language codes, searches MongoDB first, applies a public dictionary rate limiter, and only calls AI for database misses when configured. AI responses are validated before returning. Provider keys are server-only.

### Seed data

`backend/seed-dictionary.js` contains a repeatable upsert seed with 15 curated bilingual entries. Run it after configuring `MONGODB_URI`:

```text
node backend/seed-dictionary.js
```

## Environment variables

Configure in `backend/.env` only; never commit secrets:

- `AI_PROVIDER=openai` or `google`
- `AI_API_KEY=<provider secret>`
- `AI_MODEL=<optional model override>`
- `MONGODB_URI=<MongoDB connection string>`
- `MONGODB_DATABASE=<database name>`

Without `AI_API_KEY`, database dictionary results remain available and missing words return a safe not-found response. No fake AI result is generated.

## Validation

- `flutter pub get`: passed.
- `flutter analyze`: completed with 5 pre-existing `info` lints in untouched files; zero errors and zero warnings from the new implementation.
- `flutter test test/learning_hub_dictionary_test.dart`: passed, 16 tests.
- `npm test`: passed, 63 tests.
- Full `flutter test`: existing suite still has unrelated/pre-existing failures in `learning_flow_test.dart`, `progress_screen_test.dart`, `widget_test.dart`, and one earlier test-harness/provider issue in `practice_screens_test.dart`. The new focused Learn Hub/dictionary tests pass after scrolling to off-screen cards.
- Physical-device TTS was not retested during this implementation.
- Real AI lookup with a working provider key was not verified; tests use a stub provider and confirm database-first behavior, fallback, unavailable-provider handling, validation, rate limiting, and key non-disclosure.

## Regression and scope

- Authentication and cloud progress code was not modified.
- MongoDB user-progress schemas were not modified.
- Existing learning screens, TTS service, themes, and navigation architecture were preserved.
- No subscriptions, payments, or unrelated roadmap work was added.

## Next step

Configure a deployment MongoDB URI, run the repeatable dictionary seed, then verify the endpoint and optional AI provider in a controlled environment. Resolve the previously documented full Flutter test-harness failures separately; they are not hidden or deleted by this feature.
