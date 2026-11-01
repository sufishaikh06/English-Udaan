import 'package:english_udaan/core/services/speech_service.dart';
import 'package:english_udaan/features/practice/domain/practice_models.dart';
import 'package:english_udaan/features/practice/presentation/practice_screens.dart';
import 'package:english_udaan/main.dart';
import 'package:english_udaan/shared/widgets/app_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSpeechService implements SpeechService {
  String? lastSpoken;

  @override
  Future<void> speak(String text) async {
    lastSpoken = text;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PracticeHomeScreen widget tests', () {
    testWidgets('renders all 5 practice categories with titles in Urdu RTL', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: PracticeHomeScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('پریکٹس اور کوئز'), findsOneWidget);
      expect(find.text('الفاظ کی مشق'), findsOneWidget);
      expect(find.text('تصاویر کی مشق'), findsOneWidget);
      expect(find.text('جملوں کی مشق'), findsOneWidget);
      expect(find.text('گرامر کی مشق'), findsOneWidget);
      expect(find.text('مخلوط مشق'), findsOneWidget);
      expect(find.text('شروع کریں'), findsNWidgets(5));
    });

    testWidgets('renders categories with English titles when language is English', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      container.read(preferencesProvider.notifier).setLanguage(AppLanguage.english);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Directionality(
              textDirection: TextDirection.ltr,
              child: PracticeHomeScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Practice & Quizzes'), findsOneWidget);
      expect(find.text('Vocabulary Practice'), findsOneWidget);
      expect(find.text('Picture Practice'), findsOneWidget);
      expect(find.text('Sentence Practice'), findsOneWidget);
      expect(find.text('Grammar Practice'), findsOneWidget);
      expect(find.text('Mixed Quiz'), findsOneWidget);
      expect(find.text('Start'), findsNWidgets(5));
    });
  });

  group('PracticeQuizScreen flow and interaction', () {
    final sampleQuestions = [
      const PracticeQuestion(
        id: 'q1',
        category: PracticeCategory.vocabulary,
        type: PracticeQuestionType.urduToEnglishWord,
        instructionUrdu: 'اس اردو معنی کا درست انگریزی لفظ منتخب کریں:',
        instructionEnglish: 'Select the correct English word:',
        prompt: 'کتاب',
        isPromptUrdu: true,
        options: ['Book', 'Pen', 'Car', 'Tree'],
        correctIndex: 0,
        areOptionsUrdu: false,
        ttsText: 'Book',
        explanationUrdu: 'درست لفظ Book ہے۔',
        explanationEnglish: 'The correct word is Book.',
      ),
      const PracticeQuestion(
        id: 'q2',
        category: PracticeCategory.vocabulary,
        type: PracticeQuestionType.englishToUrduWord,
        instructionUrdu: 'اس انگریزی لفظ کا درست اردو معنی منتخب کریں:',
        instructionEnglish: 'Select the correct Urdu meaning:',
        prompt: 'Water',
        isPromptUrdu: false,
        options: ['روٹی', 'پانی', 'ہوا', 'آگ'],
        correctIndex: 1,
        areOptionsUrdu: true,
        ttsText: 'Water',
        explanationUrdu: 'Water کا مطلب پانی ہے۔',
        explanationEnglish: 'Water means water in Urdu.',
      ),
    ];

    testWidgets('complete quiz flow: select, submit, feedback, next question, results and retry', (tester) async {
      final fakeSpeech = FakeSpeechService();

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: PracticeQuizScreen(
              category: PracticeCategory.vocabulary,
              speechService: fakeSpeech,
              initialQuestions: sampleQuestions,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify question 1 is presented
      expect(find.text('سوال 1 از 2'), findsOneWidget);
      expect(find.text('کتاب'), findsOneWidget);
      expect(find.text('Book'), findsOneWidget);
      expect(find.text('Pen'), findsOneWidget);

      // Verify audio button works
      await tester.tap(find.byType(AudioButton));
      await tester.pump();
      expect(fakeSpeech.lastSpoken, 'Book');

      // Select option 'Book' (index 0)
      await tester.tap(find.text('Book'));
      await tester.pump();

      // Submit answer
      await tester.tap(find.text('جواب جمع کریں'));
      await tester.pump();

      // Feedback should appear
      expect(find.text('درست جواب! شاباش۔'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsWidgets);

      // Advance to question 2
      await tester.tap(find.text('اگلا سوال'));
      await tester.pump();

      // Question 2
      expect(find.text('سوال 2 از 2'), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);

      // Select wrong option 'روٹی' (index 0)
      await tester.tap(find.text('روٹی'));
      await tester.pump();

      // Submit answer
      await tester.tap(find.text('جواب جمع کریں'));
      await tester.pump();

      // Incorrect feedback should appear
      expect(find.text('غلط جواب!'), findsOneWidget);
      expect(find.text('درست جواب: "پانی"'), findsOneWidget);

      // Final question submit button should say 'نتائج دیکھیں'
      expect(find.text('نتائج دیکھیں'), findsOneWidget);
      await tester.tap(find.text('نتائج دیکھیں'));
      await tester.pump();

      // Results view should be rendered
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('درستگی کا تناسب'), findsOneWidget);
      expect(find.text('کل سوالات'), findsOneWidget);
      expect(find.text('دوبارہ کوئز کھیلیں'), findsOneWidget);
      expect(find.text('پریکٹس پر واپس جائیں'), findsOneWidget);

      // Retry quiz
      await tester.tap(find.text('دوبارہ کوئز کھیلیں'));
      await tester.pump();

      // Should be back to question 1
      expect(find.text('سوال 1 از 2'), findsOneWidget);
      expect(find.text('کتاب'), findsOneWidget);
    });
  });
}
