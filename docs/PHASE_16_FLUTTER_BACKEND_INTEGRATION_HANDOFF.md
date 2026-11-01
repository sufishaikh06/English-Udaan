# English Udaan — Phase 16 Flutter/Backend Integration Handoff

## Phase 16 cloud sync completion update

Cloud progress synchronization is now wired into the existing local progress changes without changing the backend API contract. This update also makes the API endpoint build-configurable and isolates local progress when switching authenticated Firebase accounts.

### Upload triggers

- Vocabulary completion calls `syncToCloud()` after the local completion key and study activity are saved.
- Picture completion calls `syncToCloud()` after local completion and study activity are saved.
- Quiz result persistence calls `syncToCloud()` after the result is saved.
- Email/password and Google sign-in clear progress from a different previously active UID before calling `syncFromCloud()`.
- Upload failures are intentionally non-blocking for learning and are recorded as `failed`.
- API requests log only sanitized method, host/port/path, status, and error category; tokens and identifiers are never logged.
- `API_BASE_URL` is supplied with `--dart-define`; `10.0.2.2` remains only the emulator default and must not be used for a physical phone.
- The effective client endpoint and whether an auth header is present are logged without exposing the URL query, token, UID, or credentials.

### Download and merge

- `syncFromCloud()` now merges downloaded progress into local SharedPreferences.
- Completed sections are merged without clearing local completion state.
- Quiz results use a conservative score/total comparison and do not replace a stronger local result with a weaker cloud result.
- Activity dates are merged into the local activity date set.
- Backend section identifiers are translated to the local identifiers (`vocabulary-two-letter` ↔ `vocabulary-two`, `picture-fruits` ↔ `pictures-fruits`).
- No tokens, passwords, UIDs, or connection strings are logged.

### Sync status

- Existing states are used: `localOnly`, `pending`, `synced`, and `failed`.
- Upload sets `pending` before the request and `synced` only after a successful HTTP response.
- Download failures set `failed` and preserve local progress.
- The existing Progress screen displays the current sync state in a status card.

## Files changed for this completion

- `mobile/lib/features/progress/data/progress_repository.dart`
- `mobile/lib/features/auth/data/cloud_progress_service.dart`
- `mobile/lib/features/auth/presentation/auth_screens.dart`
- `mobile/lib/features/learning/presentation/learning_screens.dart`
- `mobile/lib/features/learning/presentation/picture_learning_screens.dart`
- `mobile/lib/features/practice/presentation/practice_screens.dart`
- `mobile/lib/features/progress/presentation/progress_screen.dart`
- `docs/PHASE_16_FLUTTER_BACKEND_INTEGRATION_HANDOFF.md`
- `mobile/lib/core/services/api_client.dart`
- `mobile/android/app/src/main/AndroidManifest.xml`
- `backend/src/config/firebase.js`
- `backend/src/config/database.js`
- `backend/src/config/environment.js`
- `backend/src/routes/progress.js`
- `backend/src/server.js`

## Validation

- `flutter analyze` — completed with no errors; 9 informational diagnostics remain.
- `flutter test` — failed: existing unrelated widget/harness failures in `learning_flow_test.dart`, `practice_screens_test.dart`, `progress_screen_test.dart`, and `widget_test.dart`; no cloud-specific test failure was observed.
- `flutter test test/progress_test.dart test/auth_screens_test.dart` — passed, 15 tests.
- `npm test` from `backend/` — passed, 53/53 tests.
- `npm test` from `mobile/` — not applicable; failed because the Flutter directory has no `package.json`.

Live Firebase authentication, real ID-token verification, live Flutter-to-Express upload, physical-phone installation, and live MongoDB Atlas restoration were not performed in this environment. The backend startup smoke check previously exposed a Firebase Admin initialization bug (`admin.auth is not a function`), which was fixed by using the supported `getAuth()` API; it must still be verified with real Admin credentials.

## Manual end-to-end verification

1. Configure Firebase Auth providers and Android/web client configuration as documented by the project setup.
2. Start the backend with Firebase Admin credentials configured outside the repository and MongoDB Atlas available.
3. Configure the Flutter API base URL for the target emulator/device.
4. Sign in with a dedicated test account.
5. Complete a vocabulary or picture section and finish a quiz.
6. Open Progress and confirm the sync status transitions to `Syncing` and then `Synced`.
7. Confirm the matching `user_progress` document in Atlas using the account's Firebase UID, without exposing that UID or credentials.
8. Log out and sign back into the same account.
9. Confirm the app calls cloud download and that completed sections/results remain visible after the merge.
10. Test offline completion: confirm learning remains usable and the status becomes `Sync failed` rather than losing local data.
11. Test switching accounts: confirm the second account does not display the first account's cloud progress.

The backend continues to authorize records by the verified Firebase UID and `PUT /api/progress` remains a full overwrite endpoint. The client merge protects local records during download, but production conflict behavior should still be reviewed before release.
