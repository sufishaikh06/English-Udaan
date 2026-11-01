ENGLISH UDAAN — TARGETED CLOUD PROGRESS FIX

This patch contains complete replacement files. Extract this ZIP into the
root of your existing English Udaan codebase and allow the listed files to be
overwritten. It does not contain Firebase credentials, MongoDB credentials,
or environment files.

ROOT CAUSES FOUND IN THE UPLOADED SOURCE

1) Email/password registration did not initialize the in-memory progress
   account. Firebase creates and signs in the user, but RegisterScreen moved
   directly to /profile without calling prepareForAccount() and syncFromCloud().
   ProgressRepository's markSectionCompleted(), saveQuizResult(), and
   recordStudyActivity() all return immediately when there is no active account.
   CloudProgressService.syncToCloud() previously checked only Firebase currentUser,
   so it could still send empty arrays and create/update an empty MongoDB document.

2) On a normal login, GET /api/progress for a new account returns sections: [] and
   quizResults: []. The old _parseCloudProgress() built a summary with no sections,
   and mergeCloudSummary() replaced in-memory state with that empty summary.
   loadSummary() returned that stored empty list, while markSectionCompleted()
   only mapped over existing sections and did not add a missing one. Therefore the
   first vocabulary/picture lesson could never appear in the outgoing sections array.
   The Progress screen also received no section catalogue and showed zero/empty.

3) Firebase can restore a previously signed-in user when the app starts again.
   Before this patch the app used authStateProvider for routing but did not activate
   the in-memory progress session on that initial restored-auth event. The app could
   therefore be authenticated while ProgressRepository was still in guest mode.

WHAT THIS PATCH CHANGES

- ProgressRepository seeds each authenticated in-memory session with the complete
  vocabulary/picture section catalogue before cloud restoration.
- Empty cloud data is merged onto that catalogue; saved progress cannot erase the
  list of sections the app needs to record future completion.
- Repeated activation of the same UID does not clear already-loaded in-memory data.
- Email/password registration now activates the authenticated progress session and
  fetches cloud progress, just like login and Google registration.
- The app activates/restores the progress session when Firebase restores an
  existing login after an app restart.
- Cloud upload is skipped unless the repository's active UID matches Firebase UID.
  This prevents empty uploads from an authenticated but uninitialized session.
- After PUT, GET confirmation must contain the submitted section IDs and quiz
  categories before the app marks the operation as synced.
- Quiz sync is awaited by the quiz completion handler.
- A regression test covers the exact empty-cloud-response → first lesson + first
  quiz scenario.

FILES INCLUDED

mobile/lib/main.dart
mobile/lib/features/auth/presentation/auth_screens.dart
mobile/lib/features/auth/data/cloud_progress_service.dart
mobile/lib/features/progress/data/progress_repository.dart
mobile/lib/features/practice/presentation/practice_screens.dart
mobile/test/progress_test.dart

VALIDATION LIMITATION

The inspection environment used for this patch did not have Flutter or Dart SDK
installed, and the uploaded ZIP did not include mobile/assets/content JSON files.
Therefore I could not run flutter analyze, flutter test, or build the Android app
against this patch. The changes are source-reviewed but still need local Flutter
validation before being used in the presentation build.

AFTER APPLYING

From the mobile directory run:
  flutter analyze
  flutter test test/progress_test.dart test/practice_test.dart
  flutter run --dart-define=API_BASE_URL=http://<YOUR-COMPUTER-LAN-IP>:3000

Then use one authenticated account: complete a vocabulary section and submit a
quiz. Confirm the account's MongoDB user_progress document has non-empty sections
and quizResults. Only after that, check the second account's isolation.
