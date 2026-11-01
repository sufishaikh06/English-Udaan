import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../progress/domain/progress_models.dart';
import '../../progress/data/progress_repository.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';

class CloudProgressService {
  CloudProgressService({
    required this.apiClient,
    required this.authService,
    required this.localRepo,
    this._clock,
  });

  final ApiClient apiClient;
  final AuthService authService;
  final ProgressRepository localRepo;
  final DateTime Function()? _clock;

  DateTime _now() => _clock?.call() ?? DateTime.now();
  static int _sequence = 0;

  Future<void> syncToCloud() async {
    final uid = authService.currentUser?.uid;
    if (uid == null) return;
    // Firebase may still have a signed-in user while the in-memory progress
    // session has not been initialized (for example, after app relaunch or an
    // older registration flow). Never upload an empty guest snapshot.
    if (!localRepo.isActiveFor(uid)) {
      debugPrint('[sync] skipped: authenticated progress session is not active');
      return;
    }
    final requestId = 'progress-upload-${++_sequence}';
    await localRepo.setSyncState(SyncState.pending);
    try {
      final localSummary = await localRepo.loadSummary();
      if (authService.currentUser?.uid != uid) return;
      final cloudPayload = _buildCloudPayload(localSummary);
      debugPrint('[sync][$requestId] uid_suffix=${uid.substring(uid.length > 6 ? uid.length - 6 : 0)} sections=${(cloudPayload['sections'] as List).length} quizzes=${(cloudPayload['quizResults'] as List).length} payload=${jsonEncode(cloudPayload)}');
      final putResponse = await apiClient.put('/api/progress', cloudPayload, requestId: requestId);
      debugPrint('[sync][$requestId] response=${jsonEncode(putResponse)}');
      if (authService.currentUser?.uid != uid || !localRepo.isActiveFor(uid)) return;
      final confirmed = await apiClient.get('/api/progress', requestId: requestId);
      final confirmedData = confirmed['data'];
      if (confirmedData is! Map<String, dynamic>) {
        throw const FormatException('Cloud progress confirmation is invalid.');
      }
      final persistedSections = (confirmedData['sections'] as List?) ?? const [];
      final persistedQuizzes = (confirmedData['quizResults'] as List?) ?? const [];
      debugPrint('[sync][$requestId] persisted_sections=${persistedSections.length} persisted_quizzes=${persistedQuizzes.length}');

      // A 200 response alone is insufficient: the server must return every
      // section and quiz category this client just submitted.
      final submittedSections = cloudPayload['sections'] as List;
      final submittedQuizzes = cloudPayload['quizResults'] as List;
      final missingSection = submittedSections.any((submitted) {
        if (submitted is! Map) return true;
        return !persistedSections.any(
          (saved) => saved is Map &&
              saved['section'] == submitted['section'] &&
              saved['completed'] == true,
        );
      });
      final missingQuiz = submittedQuizzes.any((submitted) {
        if (submitted is! Map) return true;
        return !persistedQuizzes.any(
          (saved) => saved is Map && saved['category'] == submitted['category'],
        );
      });
      if (missingSection || missingQuiz) {
        throw const FormatException(
          'Cloud confirmation did not contain all submitted progress.',
        );
      }
      if (authService.currentUser?.uid != uid || !localRepo.isActiveFor(uid)) return;
      await localRepo.setSyncState(SyncState.synced);
      debugPrint('[sync] upload completed');
    } catch (e) {
      if (authService.currentUser?.uid == uid && localRepo.isActiveFor(uid)) {
        await localRepo.setSyncState(SyncState.failed);
      }
      debugPrint('[sync] upload failed: ${_errorCategory(e)}');
      rethrow;
    }
  }

  Future<ProgressSummary?> syncFromCloud() async {
    final uid = authService.currentUser?.uid;
    if (uid == null || !localRepo.isActiveFor(uid)) return null;
    try {
      final response = await apiClient.get('/api/progress');
      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Cloud progress response is missing data.');
      }
      final summary = _parseCloudProgress(data);
      if (summary == null) {
        throw const FormatException(
          'Cloud progress response could not be parsed.',
        );
      }
      if (authService.currentUser?.uid != uid || !localRepo.isActiveFor(uid)) return null;
      await localRepo.mergeCloudSummary(summary, expectedUid: uid);
      // Do not apply a response fetched for an account that has since changed.
      if (authService.currentUser?.uid != uid || !localRepo.isActiveFor(uid)) return null;
      return summary;
    } catch (e) {
      if (authService.currentUser?.uid == uid && localRepo.isActiveFor(uid)) {
        await localRepo.setSyncState(SyncState.failed);
      }
      debugPrint('[sync] download failed: ${_errorCategory(e)}');
      return null;
    }
  }

  Future<void> prepareForAccount() async {
    final uid = authService.currentUser?.uid;
    if (uid == null) return;
    await localRepo.activateAccount(uid);
  }

  Future<void> clearActiveAccount() async {
    localRepo.clearMemory();
  }

  String _errorCategory(Object error) {
    if (error is ApiException) return 'http_${error.statusCode}';
    return error.runtimeType.toString();
  }

  Map<String, dynamic> _buildCloudPayload(ProgressSummary summary) {
    final now = _now().toIso8601String();
    return {
      'sections': summary.sections
          .where((s) => s.completed)
          .map(
            (s) => {
              'section': _backendSectionId(s.id),
              'completed': true,
              'completedAt': now,
            },
          )
          .toList(),
      'quizResults': summary.quizResults
          .map(
            (q) => {
              'category': q.category,
              'score': q.score,
              'total': q.total,
              'playedAt': q.completedAt?.toIso8601String() ?? now,
            },
          )
          .toList(),
      'currentStreak': summary.currentStreak,
      'longestStreak': summary.longestStreak,
      'lastActivityDate': summary.studiedToday ? now : null,
      'updatedAt': now,
    };
  }

  ProgressSummary? _parseCloudProgress(Map<String, dynamic> data) {
    final sectionStatuses = <LessonSectionStatus>[];
    final quizResults = <QuizCategoryResult>[];

    final sections = (data['sections'] as List?) ?? [];
    for (final s in sections) {
      if (s is Map<String, dynamic>) {
        final rawId = s['section'] as String?;
        final id = rawId == null ? null : _localSectionId(rawId);
        final completed = s['completed'] as bool? ?? false;
        if (id == null) continue;
        final wordCount = _wordCountForSection(id);
        final en = _enLabelForSection(id);
        final ur = _urduLabelForSection(id);
        if (id.startsWith('vocabulary-') || id.startsWith('pictures-')) {
          sectionStatuses.add(
            LessonSectionStatus(
              id: id,
              labelEnglish: en,
              labelUrdu: ur,
              completed: completed,
              wordCount: wordCount,
            ),
          );
        }
      }
    }

    final quizData = (data['quizResults'] as List?) ?? [];
    for (final q in quizData) {
      if (q is Map<String, dynamic>) {
        final category = q['category'] as String?;
        final score = q['score'] as int?;
        final total = q['total'] as int?;
        final playedAt = q['playedAt'] as String?;
        if (category != null && score != null && total != null && total > 0) {
          quizResults.add(
            QuizCategoryResult(
              category: category,
              score: score,
              total: total,
              completedAt: playedAt == null
                  ? null
                  : DateTime.tryParse(playedAt),
            ),
          );
        }
      }
    }

    final activityDates = <DateTime>[];
    final lastActivity = data['lastActivityDate'];
    if (lastActivity is String) {
      final parsed = DateTime.tryParse(lastActivity);
      if (parsed != null) activityDates.add(dateOnly(parsed));
    }

    return ProgressSummary(
      sections: sectionStatuses,
      quizResults: quizResults,
      activityDates: activityDates,
      today: dateOnly(_now()),
      syncState: SyncState.synced,
    );
  }

  int? _wordCountForSection(String id) {
    if (id == 'vocabulary-two') return 75;
    if (id == 'vocabulary-three') return 110;
    if (id == 'vocabulary-four') return 130;
    if (id == 'vocabulary-five') return 161;
    return null;
  }

  String _enLabelForSection(String id) {
    if (id == 'vocabulary-two') return '2-letter words';
    if (id == 'vocabulary-three') return '3-letter words';
    if (id == 'vocabulary-four') return '4-letter words';
    if (id == 'vocabulary-five') return '5-letter words';
    if (id.startsWith('pictures-')) return id.replaceFirst('pictures-', '');
    return id;
  }

  String _backendSectionId(String id) {
    const vocabulary = {
      'vocabulary-two': 'vocabulary-two-letter',
      'vocabulary-three': 'vocabulary-three-letter',
      'vocabulary-four': 'vocabulary-four-letter',
      'vocabulary-five': 'vocabulary-five-letter',
    };
    if (vocabulary.containsKey(id)) return vocabulary[id]!;
    if (id.startsWith('pictures-')) {
      return 'picture-${id.substring('pictures-'.length)}';
    }
    return id;
  }

  String _localSectionId(String id) {
    const vocabulary = {
      'vocabulary-two-letter': 'vocabulary-two',
      'vocabulary-three-letter': 'vocabulary-three',
      'vocabulary-four-letter': 'vocabulary-four',
      'vocabulary-five-letter': 'vocabulary-five',
    };
    if (vocabulary.containsKey(id)) return vocabulary[id]!;
    if (id.startsWith('picture-')) {
      return 'pictures-${id.substring('picture-'.length)}';
    }
    return id;
  }

  String _urduLabelForSection(String id) {
    if (id == 'vocabulary-two') return 'دو حرفی الفاظ';
    if (id == 'vocabulary-three') return 'تین حرفی الفاظ';
    if (id == 'vocabulary-four') return 'چار حرفی الفاظ';
    if (id == 'vocabulary-five') return 'پانچ حرفی الفاظ';
    if (id.startsWith('pictures-')) return id.replaceFirst('pictures-', '');
    return id;
  }
}
