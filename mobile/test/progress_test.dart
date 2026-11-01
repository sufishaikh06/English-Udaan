import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:english_udaan/features/learning/data/learning_repository.dart';
import 'package:english_udaan/features/progress/data/progress_repository.dart';
import 'package:english_udaan/features/progress/domain/progress_models.dart';
import 'package:english_udaan/features/practice/domain/practice_models.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ProgressRepository().clearMemory();
  });

  group('ProgressRepository loads summary', () {
    test('guest progress is not persisted or displayed', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = ProgressRepository(_fakeRepo());
      await repo.recordStudyActivity(DateTime(2026, 10, 13));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(ProgressRepository.activityDatesKey), isNull);
      expect((await repo.loadSummary()).quizResults, isEmpty);
    });
    test('returns empty summary when no progress exists', () async {
      final repo = ProgressRepository(_fakeRepo());
      final summary = await repo.loadSummary();
      expect(summary.sections, isNotEmpty);
      expect(summary.sections.where((section) => section.completed), isEmpty);
      expect(summary.quizResults, isEmpty);
      expect(summary.activityDates, isEmpty);
      expect(summary.studiedToday, isFalse);
    });

    test('reports completed vocabulary sections', () async {
      final repo = ProgressRepository(_fakeRepo());
      await repo.activateAccount('test-account');
      await repo.markSectionCompleted('vocabulary-two');
      await repo.markSectionCompleted('vocabulary-three');
      final summary = await repo.loadSummary();
      final vocab = summary.sections
          .where((s) => s.id.startsWith('vocabulary'))
          .toList();
      expect(vocab.where((s) => s.completed).length, 2);
    });

    test('reports completed picture sections', () async {
      final repo = ProgressRepository(_fakeRepo());
      await repo.activateAccount('test-account');
      await repo.markSectionCompleted('pictures-fruits');
      final summary = await repo.loadSummary();
      final pics = summary.sections
          .where((s) => s.id.startsWith('pictures'))
          .toList();
      expect(pics.any((s) => s.completed && s.id == 'pictures-fruits'), isTrue);
    });

    test('reads quiz results', () async {
      final repo = ProgressRepository(_fakeRepo());
      await repo.activateAccount('test-account');
      await repo.saveQuizResult(PracticeCategory.vocabulary, 8, 10);
      final summary = await repo.loadSummary();
      expect(summary.quizResults.length, 1);
      expect(summary.quizResults.first.category, 'vocabulary');
      expect(summary.quizResults.first.score, 8);
      expect(summary.quizResults.first.total, 10);
      expect(summary.quizResults.first.accuracyPercent, 80);
    });

    test('calculates weighted accuracy', () async {
      final repo = ProgressRepository(_fakeRepo());
      await repo.activateAccount('test-account');
      await repo.saveQuizResult(PracticeCategory.vocabulary, 8, 10);
      await repo.saveQuizResult(PracticeCategory.pictures, 3, 5);
      final summary = await repo.loadSummary();
      expect(summary.quizQuestionsAnswered, 15);
      expect(summary.quizCorrectAnswers, 11);
      expect(summary.accuracyPercent, 73);
    });
  });

  group('recordStudyActivity', () {
    test('saves today when called', () async {
      final repo = ProgressRepository(_fakeRepo(), () => DateTime(2026, 10, 13, 14, 0));
      await repo.activateAccount('test-account');
      await repo.recordStudyActivity();
      expect((await repo.loadSummary()).activityDates, isNotEmpty);
    });

    test('does not duplicate same day', () async {
      final repo = ProgressRepository(_fakeRepo(), () => DateTime(2026, 10, 13, 14, 0));
      await repo.activateAccount('test-account');
      await repo.recordStudyActivity();
      await repo.recordStudyActivity();
      expect((await repo.loadSummary()).activityDates.length, 1);
    });

    test('rejects future dates', () async {
      final repo = ProgressRepository(_fakeRepo(), () => DateTime(2026, 10, 13));
      await repo.activateAccount('test-account');
      await repo.recordStudyActivity(DateTime(2026, 10, 20));
      expect((await repo.loadSummary()).activityDates, isEmpty);
    });
  });

  group('mergeCloudSummary', () {
    test('keeps authenticated account progress isolated by UID', () async {
      final repo = ProgressRepository(_fakeRepo());
      await repo.activateAccount('account-a');
      await repo.markSectionCompleted('vocabulary-two');

      expect(
        (await repo.loadSummary()).sections
            .firstWhere((section) => section.id == 'vocabulary-two')
            .completed,
        isTrue,
      );

      await repo.activateAccount('account-b');
      expect(
        (await repo.loadSummary()).sections
            .firstWhere((section) => section.id == 'vocabulary-two')
            .completed,
        isFalse,
      );
    });

    test('activating the already active UID does not erase its session', () async {
      final repo = ProgressRepository(_fakeRepo());
      await repo.activateAccount('account-a');
      await repo.markSectionCompleted('vocabulary-two');
      await repo.activateAccount('account-a');

      final summary = await repo.loadSummary();
      expect(
        summary.sections.firstWhere((section) => section.id == 'vocabulary-two').completed,
        isTrue,
      );
    });

    test('restores sections, quiz results, and cloud activity date', () async {
      final repo = ProgressRepository(
        _fakeRepo(),
        () => DateTime(2026, 10, 13, 14, 0),
      );
      await repo.activateAccount('test-account');

      await repo.mergeCloudSummary(
        ProgressSummary(
          sections: const [
            LessonSectionStatus(
              id: 'vocabulary-five',
              labelEnglish: '5-letter words',
              labelUrdu: 'پانچ حرفی الفاظ',
              completed: true,
              wordCount: 161,
            ),
          ],
          quizResults: [
            QuizCategoryResult(
              category: 'vocabulary',
              score: 9,
              total: 10,
              completedAt: DateTime(2026, 10, 12, 10),
            ),
          ],
          activityDates: [DateTime(2026, 10, 12)],
          today: DateTime(2026, 10, 13),
          syncState: SyncState.synced,
        ),
      );

      final summary = await repo.loadSummary();
      expect(summary.sections.firstWhere((s) => s.id == 'vocabulary-five').completed, isTrue);
      expect(summary.quizResults.single.score, 9);
      expect(summary.activityDates, contains(DateTime(2026, 10, 12)));
      expect(summary.syncState, SyncState.synced);
    });

    test('cloud restoration replaces the in-memory session snapshot', () async {
      final repo = ProgressRepository(_fakeRepo());
      await repo.activateAccount('test-account');
      await repo.mergeCloudSummary(
        ProgressSummary(
          sections: const [],
          quizResults: const [
            QuizCategoryResult(category: 'vocabulary', score: 7, total: 10),
          ],
          activityDates: const [],
          today: DateTime(2026, 10, 13),
        ),
      );

      final summary = await repo.loadSummary();
      expect(summary.quizResults.single.score, 7);
    });

    test('empty cloud restoration retains catalogue and first lesson can complete', () async {
      final repo = ProgressRepository(_fakeRepo());
      await repo.activateAccount('new-account');
      await repo.mergeCloudSummary(
        ProgressSummary(
          sections: const [],
          quizResults: const [],
          activityDates: const [],
          today: DateTime(2026, 10, 13),
          syncState: SyncState.synced,
        ),
        expectedUid: 'new-account',
      );

      final before = await repo.loadSummary();
      expect(before.sections, isNotEmpty);
      expect(before.sections.length, greaterThanOrEqualTo(5));
      expect(before.sectionsCompleted, 0);

      await repo.markSectionCompleted('vocabulary-two');
      await repo.saveQuizResult(PracticeCategory.vocabulary, 8, 10);
      final after = await repo.loadSummary();
      expect(
        after.sections.firstWhere((section) => section.id == 'vocabulary-two').completed,
        isTrue,
      );
      expect(after.sectionsCompleted, 1);
      expect(after.quizResults, hasLength(1));
      expect(after.quizResults.single.score, 8);
    });
  });

  group('streak calculation', () {
    test('calculates current streak', () {
      final today = DateTime(2026, 10, 13);
      expect(streakLength([], today), 0);
      expect(streakLength([DateTime(2026, 10, 13)], today), 1);
      expect(streakLength([DateTime(2026, 10, 12), DateTime(2026, 10, 13)], today), 2);
      expect(streakLength([DateTime(2026, 10, 11), DateTime(2026, 10, 13)], today), 1);
    });

    test('calculates longest streak', () {
      expect(longestStreakLength([]), 0);
      expect(longestStreakLength([DateTime(2026, 10, 10)]), 1);
      expect(
        longestStreakLength([
          DateTime(2026, 10, 10),
          DateTime(2026, 10, 11),
          DateTime(2026, 10, 13),
          DateTime(2026, 10, 14),
          DateTime(2026, 10, 15),
        ]),
        3,
      );
    });
  });

  group('ProgressSummary calculations', () {
    test('wordsInCompletedSections counts word counts', () {
      final summary = ProgressSummary(
        sections: [
          const LessonSectionStatus(
            id: 'v1',
            labelEnglish: 'Two-letter',
            labelUrdu: 'دو حرفی',
            completed: true,
            wordCount: 75,
          ),
          const LessonSectionStatus(
            id: 'v2',
            labelEnglish: 'Three-letter',
            labelUrdu: 'تین حرفی',
            completed: false,
            wordCount: 110,
          ),
          const LessonSectionStatus(
            id: 'pics',
            labelEnglish: 'Fruits',
            labelUrdu: 'پھل',
            completed: true,
          ),
        ],
        quizResults: const [],
        activityDates: const [],
        today: DateTime(2026, 10, 13),
      );
      expect(summary.wordsInCompletedSections, 75);
      expect(summary.sectionsCompleted, 2);
      expect(summary.overallPercent, 67);
    });

    test('overallPercent divides completed by total', () {
      final summary = ProgressSummary(
        sections: const [
          LessonSectionStatus(
            id: 'a',
            labelEnglish: 'A',
            labelUrdu: 'اے',
            completed: true,
          ),
          LessonSectionStatus(
            id: 'b',
            labelEnglish: 'B',
            labelUrdu: 'بی',
            completed: false,
          ),
        ],
        quizResults: const [],
        activityDates: const [],
        today: DateTime(2026, 10, 13),
      );
      expect(summary.overallPercent, 50);
    });
  });
}

LearningRepository _fakeRepo() {
  return LearningRepository((path) async {
    if (path.contains('vocabulary')) {
      final counts = <int, int>{2: 75, 3: 110, 4: 130, 5: 161};
      final items = <Map<String, dynamic>>[];
      for (final entry in counts.entries) {
        for (var i = 0; i < entry.value; i++) {
          var value = i;
          final chars = List<String>.filled(entry.key, 'a');
          for (var position = entry.key - 1; position >= 0; position--) {
            chars[position] = String.fromCharCode(97 + (value % 26));
            value ~/= 26;
          }
          final word = chars.join();
          items.add({
            'id': 'v${entry.key}-$i',
            'word': word,
            'length': entry.key,
            'category': '${entry.key}-letter',
            'difficulty': 'beginner',
            'urduMeaning': 'معنی',
            'example': word,
            'version': '0.1.0-sample',
            'ttsText': word,
          });
        }
      }
      return jsonEncode({'version': '0.1.0-sample', 'section': 'vocabulary', 'items': items});
    }
    if (path.contains('picture')) {
      return '''
{
  "version": "0.1.0-sample",
  "section": "picture_learning",
  "categories": [
    {"id": "fruits", "titleEnglish": "Fruits", "titleUrdu": "پھل", "iconName": "apple", "itemCount": 10}
  ],
  "items": []
}
''';
    }
    throw Exception('Unknown path: $path');
  });
}
