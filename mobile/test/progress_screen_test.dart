import 'package:english_udaan/features/progress/domain/progress_models.dart';
import 'package:english_udaan/features/progress/presentation/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:english_udaan/features/learning/data/learning_repository.dart';
import 'package:english_udaan/features/progress/data/progress_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProgressScreen widget tests', () {
    testWidgets('shows empty message when no progress', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final summary = ProgressSummary(
        sections: const [],
        quizResults: const [],
        activityDates: const [],
        today: DateTime(2026, 10, 13),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            progressRepositoryProvider.overrideWithValue(
              _FakeProgressRepo(summary),
            ),
          ],
          child: const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.ltr,
              child: ProgressScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Progress'), findsOneWidget);
    });

    testWidgets('displays completed sections', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final summary = ProgressSummary(
        sections: const [
          LessonSectionStatus(
            id: 'vocabulary-two',
            labelEnglish: '2-letter words',
            labelUrdu: 'دو حرفی الفاظ',
            completed: true,
            wordCount: 75,
          ),
        ],
        quizResults: const [],
        activityDates: const [],
        today: DateTime(2026, 10, 13),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            progressRepositoryProvider.overrideWithValue(
              _FakeProgressRepo(summary),
            ),
          ],
          child: const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.ltr,
              child: ProgressScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2-letter words'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('displays quiz results', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final summary = ProgressSummary(
        sections: const [],
        quizResults: [
          QuizCategoryResult(
            category: 'vocabulary',
            score: 8,
            total: 10,
            completedAt: DateTime(2026, 10, 13),
          ),
        ],
        activityDates: const [],
        today: DateTime(2026, 10, 13),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            progressRepositoryProvider.overrideWithValue(
              _FakeProgressRepo(summary),
            ),
          ],
          child: const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.ltr,
              child: ProgressScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vocabulary Practice'), findsOneWidget);
      expect(find.text('8/10 · 80%'), findsOneWidget);
    });
  });
}

class _FakeProgressRepo extends ProgressRepository {
  final ProgressSummary _summary;

  _FakeProgressRepo(this._summary) : super(_fakeRepo());

  @override
  Future<ProgressSummary> loadSummary() async => _summary;
}

LearningRepository _fakeRepo() {
  return LearningRepository((path) async {
    if (path.contains('vocabulary')) {
      return '''
{
  "version": "0.1.0-sample",
  "section": "vocabulary",
  "items": [
    {"id": "v1", "word": "ab", "length": 2, "meaningUrdu": "اے بی", "exampleEnglish": "ab", "exampleUrdu": "اے بی", "ttsText": "ab"}
  ]
}
''';
    }
    if (path.contains('picture')) {
      return '''
{
  "version": "0.1.0-sample",
  "section": "picture_learning",
  "categories": [],
  "items": []
}
''';
    }
    throw Exception('Unknown path: $path');
  });
}
