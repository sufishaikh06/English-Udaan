import 'dart:convert';

import 'package:english_udaan/features/learning/data/learning_repository.dart';
import 'package:english_udaan/features/learning/domain/learning_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses and validates the complete A-Z sample dataset', () async {
    final repository = LearningRepository(
      (path) async => jsonEncode({
        'version': LearningRepository.contentVersion,
        'items': List.generate(
          26,
          (index) => {
            'id': 'alphabet-$index',
            'letter': String.fromCharCode(65 + index),
            'lowercase': String.fromCharCode(97 + index),
            'englishExample': 'Example',
            'urduMeaning': 'مثال',
            'ttsText': 'Example',
          },
        ),
      }),
    );

    final alphabet = await repository.loadAlphabet();
    expect(alphabet, hasLength(26));
    expect(alphabet.first.id, 'alphabet-0');
  });

  testWidgets(
    'loadVocabulary returns at least 75 two-letter words from bundled content',
    (tester) async {
      await tester.runAsync(() async {
        final repository = LearningRepository.bundled();
        final vocabulary = await repository.loadVocabulary(wordLength: 2);
        expect(vocabulary.length, greaterThanOrEqualTo(75));
        expect(vocabulary.every((item) => item.length == 2), isTrue);
        expect(vocabulary.every((item) => item.word.length == 2), isTrue);
      });
    },
  );

  testWidgets(
    'loadVocabulary returns between 100 and 125 three-letter words from bundled content',
    (tester) async {
      await tester.runAsync(() async {
        final repository = LearningRepository.bundled();
        final vocabulary = await repository.loadVocabulary(wordLength: 3);
        expect(vocabulary.length, greaterThanOrEqualTo(100));
        expect(vocabulary.length, lessThanOrEqualTo(125));
        expect(vocabulary.every((item) => item.length == 3), isTrue);
        expect(vocabulary.every((item) => item.word.length == 3), isTrue);
        expect(vocabulary.every((item) => item.urduMeaning.isNotEmpty), isTrue);
        expect(vocabulary.every((item) => item.example.isNotEmpty), isTrue);
      });
    },
  );

  testWidgets(
    'loadVocabulary returns between 125 and 150 four-letter words from bundled content',
    (tester) async {
      await tester.runAsync(() async {
        final repository = LearningRepository.bundled();
        final vocabulary = await repository.loadVocabulary(wordLength: 4);
        expect(vocabulary.length, greaterThanOrEqualTo(125));
        expect(vocabulary.length, lessThanOrEqualTo(150));
        expect(vocabulary.every((item) => item.length == 4), isTrue);
        expect(vocabulary.every((item) => item.word.length == 4), isTrue);
        expect(vocabulary.every((item) => item.urduMeaning.isNotEmpty), isTrue);
        expect(vocabulary.every((item) => item.example.isNotEmpty), isTrue);
      });
    },
  );

  testWidgets(
    'loadVocabulary returns between 150 and 175 five-letter words from bundled content',
    (tester) async {
      await tester.runAsync(() async {
        final repository = LearningRepository.bundled();
        final vocabulary = await repository.loadVocabulary(wordLength: 5);
        expect(vocabulary.length, greaterThanOrEqualTo(150));
        expect(vocabulary.length, lessThanOrEqualTo(175));
        expect(vocabulary.every((item) => item.length == 5), isTrue);
        expect(vocabulary.every((item) => item.word.length == 5), isTrue);
        expect(vocabulary.every((item) => item.urduMeaning.isNotEmpty), isTrue);
        expect(vocabulary.every((item) => item.example.isNotEmpty), isTrue);
      });
    },
  );

  testWidgets(
    'loadPictureCategories and loadPictureItems return valid items from bundled content',
    (tester) async {
      await tester.runAsync(() async {
        final repository = LearningRepository.bundled();
        final categories = await repository.loadPictureCategories();
        expect(categories, isNotEmpty);
        expect(categories.any((c) => c.id == 'fruits'), isTrue);

        final fruitItems = await repository.loadPictureItems(categoryId: 'fruits');
        expect(fruitItems, isNotEmpty);
        expect(fruitItems.every((item) => item.categoryId == 'fruits'), isTrue);
        expect(fruitItems.every((item) => item.english.isNotEmpty), isTrue);
        expect(fruitItems.every((item) => item.urdu.isNotEmpty), isTrue);
      });
    },
  );

  test('loads validated sentence and paragraph content from bundled data', () async {
    final items = await LearningRepository.bundled().loadSentenceLearningItems();
    expect(items, hasLength(19));
    expect(items.map((item) => item.id).toSet(), hasLength(items.length));
    expect(items.map((item) => item.order).toSet(), hasLength(items.length));
    expect(items.every((item) => item.english.isNotEmpty && item.urdu.isNotEmpty), isTrue);
    expect(items.map((item) => item.type).toSet(), containsAll(LearningContentType.values));
    expect(items, orderedEquals(items.toList()..sort((a, b) => a.order.compareTo(b.order))));
  });

  test('loads validated grammar content from bundled data', () async {
    final lessons = await LearningRepository.bundled().loadGrammarLessons();
    expect(lessons, hasLength(17));
    expect(lessons.map((lesson) => lesson.id).toSet(), hasLength(lessons.length));
    expect(lessons.map((lesson) => lesson.order).toSet(), hasLength(lessons.length));
    expect(lessons.map((lesson) => lesson.level).toSet(), containsAll(['beginner', 'elementary', 'intermediate', 'advanced']));
    expect(lessons.map((lesson) => lesson.category).toSet(), containsAll(['partsOfSpeech', 'nouns', 'pronouns', 'verbs', 'adjectives', 'adverbs', 'prepositions', 'conjunctions', 'articles', 'tenses', 'modals', 'agreement', 'activePassive', 'directIndirect', 'degrees', 'sentenceStructure', 'commonErrors']));
    expect(lessons.every((lesson) => lesson.explanationEnglish.isNotEmpty && lesson.explanationUrdu.isNotEmpty), isTrue);
    expect(lessons.every((lesson) => lesson.examples.isNotEmpty), isTrue);
    expect(lessons.expand((lesson) => lesson.examples).every((example) => example.english.isNotEmpty && example.urdu.isNotEmpty), isTrue);
    expect(lessons, orderedEquals(lessons.toList()..sort((a, b) => a.order.compareTo(b.order))));
  });

  test('rejects grammar content with missing examples', () async {
    final repository = LearningRepository((path) async => jsonEncode({
      'version': LearningRepository.contentVersion,
      'section': 'grammar',
      'items': [
        {
          'id': 'grammar-invalid',
          'level': 'beginner',
          'category': 'partsOfSpeech',
          'difficulty': 'beginner',
          'order': 1,
          'titleEnglish': 'Parts of Speech',
          'titleUrdu': 'اجزائے کلام',
          'explanationEnglish': 'Words have jobs.',
          'explanationUrdu': 'الفاظ کے کام ہوتے ہیں۔',
          'examples': [],
          'corrections': [],
          'ttsText': 'Words have jobs.'
        }
      ],
    }));
    expect(repository.loadGrammarLessons(), throwsFormatException);
  });

  test('rejects sentence learning content with missing required type', () async {
    final repository = LearningRepository((path) async => jsonEncode({
      'version': LearningRepository.contentVersion,
      'section': 'sentences_paragraphs',
      'items': [
        {'id':'item-1','type':'unknown','difficulty':'beginner','order':1,'english':'Hello.','urdu':'سلام۔','ttsText':'Hello.'}
      ],
    }));
    expect(repository.loadSentenceLearningItems(), throwsFormatException);
  });

  test('rejects vocabulary dataset with duplicate words', () async {
    final repository = LearningRepository(
      (path) async => jsonEncode({
        'version': LearningRepository.contentVersion,
        'items': [
          {
            'id': 'vocab-2-go-1',
            'word': 'go',
            'length': 2,
            'category': 'function',
            'difficulty': 'beginner',
            'urduMeaning': 'جانا',
            'example': 'Go home.',
            'ttsText': 'go',
            'version': LearningRepository.contentVersion,
          },
          {
            'id': 'vocab-2-go-2',
            'word': 'go',
            'length': 2,
            'category': 'function',
            'difficulty': 'beginner',
            'urduMeaning': 'جانا',
            'example': 'Go home.',
            'ttsText': 'go',
            'version': LearningRepository.contentVersion,
          },
        ],
      }),
    );

    expect(repository.loadVocabulary(wordLength: 2), throwsFormatException);
  });

  test(
    'rejects three-letter vocabulary dataset if count is less than 100',
    () async {
      final repository = LearningRepository(
        (path) async => jsonEncode({
          'version': LearningRepository.contentVersion,
          'items': [
            {
              'id': 'vocab-3-cat',
              'word': 'cat',
              'length': 3,
              'category': 'noun',
              'difficulty': 'beginner',
              'urduMeaning': 'بلی',
              'example': 'Cat sleeps.',
              'ttsText': 'cat',
              'version': LearningRepository.contentVersion,
            },
          ],
        }),
      );

      expect(repository.loadVocabulary(wordLength: 3), throwsFormatException);
    },
  );
}
