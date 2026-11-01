import 'dart:convert';
import 'dart:math';

import 'package:english_udaan/features/learning/data/learning_repository.dart';
import 'package:english_udaan/features/practice/data/practice_question_generator.dart';
import 'package:english_udaan/features/practice/data/practice_repository.dart';
import 'package:english_udaan/features/practice/domain/practice_models.dart';
import 'package:english_udaan/features/progress/data/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
    });
    ProgressRepository().clearMemory();
  });

  group('Practice domain models and QuizSession scoring', () {
    test('QuizSession calculates scores, prevents double-submission and handles empty', () {
      final questions = [
        const PracticeQuestion(
          id: 'q1',
          category: PracticeCategory.vocabulary,
          type: PracticeQuestionType.urduToEnglishWord,
          instructionUrdu: 'درست لفظ منتخب کریں:',
          instructionEnglish: 'Select correct word:',
          prompt: 'سیب',
          isPromptUrdu: true,
          options: ['Apple', 'Banana', 'Cat', 'Dog'],
          correctIndex: 0,
          areOptionsUrdu: false,
        ),
        const PracticeQuestion(
          id: 'q2',
          category: PracticeCategory.vocabulary,
          type: PracticeQuestionType.englishToUrduWord,
          instructionUrdu: 'درست معنی منتخب کریں:',
          instructionEnglish: 'Select correct meaning:',
          prompt: 'Book',
          isPromptUrdu: false,
          options: ['قلم', 'کتاب', 'میز', 'کرسی'],
          correctIndex: 1,
          areOptionsUrdu: true,
        ),
      ];

      final session = QuizSession(
        category: PracticeCategory.vocabulary,
        questions: questions,
      );

      expect(session.totalQuestions, 2);
      expect(session.score, 0);
      expect(session.percentage, 0.0);
      expect(session.isCompleted, isFalse);
      expect(session.isAnswerSubmitted, isFalse);
      expect(session.currentQuestion?.id, 'q1');

      // Attempt submit without selection -> should return false
      expect(session.submitAnswer(), isFalse);
      expect(session.score, 0);

      // Select option 0 (correct for q1: 'Apple')
      session.selectOption(0);
      expect(session.selectedOptionIndex, 0);

      // Submit answer
      final isCorrect1 = session.submitAnswer();
      expect(isCorrect1, isTrue);
      expect(session.score, 1);
      expect(session.percentage, 50.0);
      expect(session.isAnswerSubmitted, isTrue);

      // Double submission prevention: calling submitAnswer again should do nothing
      expect(session.submitAnswer(), isFalse);
      expect(session.score, 1);

      // Cannot change option after submission
      session.selectOption(2);
      expect(session.selectedOptionIndex, 0);

      // Advance to next question
      session.nextQuestion();
      expect(session.currentIndex, 1);
      expect(session.currentQuestion?.id, 'q2');
      expect(session.isAnswerSubmitted, isFalse);
      expect(session.selectedOptionIndex, isNull);

      // Select wrong option for q2: index 0 ('قلم' instead of 'کتاب')
      session.selectOption(0);
      final isCorrect2 = session.submitAnswer();
      expect(isCorrect2, isFalse);
      expect(session.score, 1);
      expect(session.percentage, 50.0);

      // Advance past last question
      session.nextQuestion();
      expect(session.isCompleted, isTrue);
      expect(session.currentQuestion, isNull);

      // Calling nextQuestion on finished session is safe
      session.nextQuestion();
      expect(session.isCompleted, isTrue);

      // Restart session
      final restarted = session.restart();
      expect(restarted.currentIndex, 0);
      expect(restarted.score, 0);
      expect(restarted.isCompleted, isFalse);
      expect(restarted.answers, isEmpty);
    });

    test('QuizSession empty questions edge case does not divide by zero', () {
      final session = QuizSession(
        category: PracticeCategory.grammar,
        questions: const [],
      );

      expect(session.totalQuestions, 0);
      expect(session.score, 0);
      expect(session.percentage, 0.0);
      expect(session.isEmpty, isTrue);
      expect(session.isCompleted, isFalse);
      expect(session.currentQuestion, isNull);
      expect(session.submitAnswer(), isFalse);
    });

    test('PracticeQuestion validation catches invalid states', () {
      // Empty ID
      expect(
        () => PracticeQuestion(
          id: '',
          category: PracticeCategory.vocabulary,
          type: PracticeQuestionType.urduToEnglishWord,
          instructionUrdu: 'instruction',
          instructionEnglish: 'instruction',
          prompt: 'prompt',
          isPromptUrdu: false,
          options: ['A', 'B'],
          correctIndex: 0,
          areOptionsUrdu: false,
        ).validate(),
        throwsFormatException,
      );

      // Duplicate options
      expect(
        () => PracticeQuestion(
          id: 'valid-id',
          category: PracticeCategory.vocabulary,
          type: PracticeQuestionType.urduToEnglishWord,
          instructionUrdu: 'instruction',
          instructionEnglish: 'instruction',
          prompt: 'prompt',
          isPromptUrdu: false,
          options: ['Apple', 'apple', 'Cat'],
          correctIndex: 0,
          areOptionsUrdu: false,
        ).validate(),
        throwsFormatException,
      );

      // Invalid correct index
      expect(
        () => PracticeQuestion(
          id: 'valid-id',
          category: PracticeCategory.vocabulary,
          type: PracticeQuestionType.urduToEnglishWord,
          instructionUrdu: 'instruction',
          instructionEnglish: 'instruction',
          prompt: 'prompt',
          isPromptUrdu: false,
          options: ['A', 'B'],
          correctIndex: 5,
          areOptionsUrdu: false,
        ).validate(),
        throwsFormatException,
      );
    });
  });

  group('PracticeQuestionGenerator and Repository', () {
    late LearningRepository mockLearningRepo;

    setUp(() {
      mockLearningRepo = LearningRepository((path) async {
        if (path.contains('vocabulary_sample.json')) {
          return jsonEncode({
            'version': LearningRepository.contentVersion,
            'section': 'vocabulary',
            'items': [
              // 2-letter items
              ...List.generate(75, (i) => {
                'id': 'v2-$i',
                'word': '${String.fromCharCode(97 + i ~/ 26)}${String.fromCharCode(97 + i % 26)}',
                'length': 2,
                'category': 'common',
                'difficulty': 'beginner',
                'urduMeaning': 'معنی ۲-$i',
                'example': 'Example 2-$i',
                'ttsText': 'word',
                'version': LearningRepository.contentVersion,
              }),
              // 3-letter items
              ...List.generate(100, (i) => {
                'id': 'v3-$i',
                'word': 'b${String.fromCharCode(97 + i ~/ 26)}${String.fromCharCode(97 + i % 26)}',
                'length': 3,
                'category': 'common',
                'difficulty': 'beginner',
                'urduMeaning': 'معنی ۳-$i',
                'example': 'Example 3-$i',
                'ttsText': 'word',
                'version': LearningRepository.contentVersion,
              }),
              // 4-letter items
              ...List.generate(125, (i) => {
                'id': 'v4-$i',
                'word': 'c${String.fromCharCode(97 + i ~/ 26)}${String.fromCharCode(97 + i % 26)}a',
                'length': 4,
                'category': 'common',
                'difficulty': 'developing',
                'urduMeaning': 'معنی ۴-$i',
                'example': 'Example 4-$i',
                'ttsText': 'word',
                'version': LearningRepository.contentVersion,
              }),
              // 5-letter items
              ...List.generate(150, (i) => {
                'id': 'v5-$i',
                'word': 'd${String.fromCharCode(97 + i ~/ 26)}${String.fromCharCode(97 + i % 26)}aa',
                'length': 5,
                'category': 'common',
                'difficulty': 'intermediate',
                'urduMeaning': 'معنی ۵-$i',
                'example': 'Example 5-$i',
                'ttsText': 'word',
                'version': LearningRepository.contentVersion,
              }),
            ],
          });
        }
        if (path.contains('picture_learning_sample.json')) {
          return jsonEncode({
            'version': LearningRepository.contentVersion,
            'categories': [
              {
                'id': 'fruits',
                'titleEnglish': 'Fruits',
                'titleUrdu': 'پھل',
                'iconName': 'apple',
                'itemCount': 5,
              },
            ],
            'items': List.generate(10, (i) => {
              'id': 'pic-$i',
              'categoryId': 'fruits',
              'english': 'Fruit $i',
              'urdu': 'پھل $i',
              'imageSourceType': 'localAsset',
              'localAssetPath': 'assets/images/pictures/fruits/fruit_$i.png',
              'ttsText': 'Fruit $i',
              'version': LearningRepository.contentVersion,
            }),
          });
        }
        if (path.contains('sentences_paragraphs_sample.json')) {
          return jsonEncode({
            'version': LearningRepository.contentVersion,
            'section': 'sentences_paragraphs',
            'items': [
              {
                'id': 'sent-1',
                'type': 'smallSentence',
                'difficulty': 'beginner',
                'order': 1,
                'english': 'This is a pen.',
                'urdu': 'یہ ایک قلم ہے۔',
                'ttsText': 'This is a pen.',
              },
              {
                'id': 'sent-2',
                'type': 'mediumSentence',
                'difficulty': 'developing',
                'order': 2,
                'english': 'She is reading a book.',
                'urdu': 'وہ ایک کتاب پڑھ رہی ہے۔',
                'ttsText': 'She is reading a book.',
              },
              {
                'id': 'sent-3',
                'type': 'longSentence',
                'difficulty': 'intermediate',
                'order': 3,
                'english': 'We go to school every morning.',
                'urdu': 'ہم ہر صبح اسکول جاتے ہیں۔',
                'ttsText': 'We go to school every morning.',
              },
              {
                'id': 'sent-4',
                'type': 'paragraph',
                'difficulty': 'intermediate',
                'order': 4,
                'english': 'Books are our best friends.',
                'urdu': 'کتابیں ہماری بہترین دوست ہیں۔',
                'ttsText': 'Books are our best friends.',
              },
            ],
          });
        }
        if (path.contains('grammar_sample.json')) {
          const requiredCategories = [
            'partsOfSpeech', 'nouns', 'pronouns', 'verbs', 'adjectives',
            'adverbs', 'prepositions', 'conjunctions', 'articles', 'tenses',
            'modals', 'agreement', 'activePassive', 'directIndirect', 'degrees',
            'sentenceStructure', 'commonErrors',
          ];
          return jsonEncode({
            'version': LearningRepository.contentVersion,
            'section': 'grammar',
            'items': List.generate(requiredCategories.length, (i) {
              final cat = requiredCategories[i];
              final level = i < 7 ? 'beginner' : i < 11 ? 'elementary' : i < 14 ? 'intermediate' : 'advanced';
              return {
                'id': 'gram-$i',
                'level': level,
                'category': cat,
                'difficulty': 'beginner',
                'order': i + 1,
                'titleEnglish': 'Grammar $cat',
                'titleUrdu': 'گرامر عنوان $i',
                'explanationEnglish': 'Explanation $i',
                'explanationUrdu': 'وضاحت $i',
                'examples': [
                  {
                    'english': 'He runs fast $i.',
                    'urdu': 'وہ تیز دوڑتا ہے $i۔',
                    'note': 'Note $i',
                    'ttsText': 'He runs fast $i.',
                  },
                ],
                'corrections': [
                  {
                    'incorrect': 'He go to school $i.',
                    'correct': 'He goes to school $i.',
                    'urdu': 'تیسرے شخص کے ساتھ s لگائیں $i۔',
                  },
                ],
                'ttsText': 'Grammar $cat overview',
              };
            }),
          });
        }
        throw FormatException('Unknown asset $path');
      });
    });

    test('generates valid vocabulary questions with distinct options and correct answers', () async {
      final generator = PracticeQuestionGenerator(
        repository: mockLearningRepo,
        random: Random(42),
      );

      final questions = await generator.generateQuestions(
        category: PracticeCategory.vocabulary,
        count: 5,
      );

      expect(questions, isNotEmpty);
      expect(questions.length, lessThanOrEqualTo(5));

      for (final q in questions) {
        expect(q.category, PracticeCategory.vocabulary);
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
        // Verify distinct options
        final unique = q.options.map((o) => o.trim().toLowerCase()).toSet();
        expect(unique.length, q.options.length);
        // Verify correct answer is in options
        expect(q.correctAnswer, q.options[q.correctIndex]);
      }
    });

    test('generates valid picture questions with images and distinct options', () async {
      final generator = PracticeQuestionGenerator(
        repository: mockLearningRepo,
        random: Random(42),
      );

      final questions = await generator.generateQuestions(
        category: PracticeCategory.pictures,
        count: 5,
      );

      expect(questions, isNotEmpty);
      for (final q in questions) {
        expect(q.category, PracticeCategory.pictures);
        expect(q.type, PracticeQuestionType.pictureMatch);
        expect(q.imageAssetPath, isNotNull);
        expect(q.options.length, 4);
        expect(q.correctIndex, inInclusiveRange(0, 3));
        expect(q.correctAnswer, q.options[q.correctIndex]);
      }
    });

    test('generates valid sentence translation questions', () async {
      final generator = PracticeQuestionGenerator(
        repository: mockLearningRepo,
        random: Random(42),
      );

      final questions = await generator.generateQuestions(
        category: PracticeCategory.sentences,
        count: 4,
      );

      expect(questions, isNotEmpty);
      for (final q in questions) {
        expect(q.category, PracticeCategory.sentences);
        expect(q.type, PracticeQuestionType.sentenceTranslation);
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctAnswer, q.options[q.correctIndex]);
      }
    });

    test('generates valid grammar questions with error corrections and examples', () async {
      final generator = PracticeQuestionGenerator(
        repository: mockLearningRepo,
        random: Random(42),
      );

      final questions = await generator.generateQuestions(
        category: PracticeCategory.grammar,
        count: 6,
      );

      expect(questions, isNotEmpty);
      for (final q in questions) {
        expect(q.category, PracticeCategory.grammar);
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctAnswer, q.options[q.correctIndex]);
      }
    });

    test('generates balanced mixed questions across all categories', () async {
      final generator = PracticeQuestionGenerator(
        repository: mockLearningRepo,
        random: Random(42),
      );

      final questions = await generator.generateQuestions(
        category: PracticeCategory.mixed,
        count: 8,
      );

      expect(questions.length, 8);
      // Verify question categories are represented
      final categories = questions.map((q) => q.category).toSet();
      expect(categories.length, greaterThanOrEqualTo(2));
    });

    test('PracticeRepository saves and retrieves last quiz score without touching lesson keys', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await ProgressRepository().activateAccount('test-account');
      final repo = PracticeRepository(
        learningRepository: mockLearningRepo,
        random: Random(42),
      );

      expect(await repo.getLastQuizResult(PracticeCategory.vocabulary), isNull);

      await repo.saveQuizResult(
        category: PracticeCategory.vocabulary,
        score: 8,
        total: 10,
      );

      final result = await repo.getLastQuizResult(PracticeCategory.vocabulary);
      expect(result, isNotNull);
      expect(result!.score, 8);
      expect(result.total, 10);

      // No progress is written to device storage.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('lesson.vocabulary.two-letter.complete'), isNull);
      expect(prefs.getBool('lesson.alphabet.complete'), isNull);
    });
  });
}
