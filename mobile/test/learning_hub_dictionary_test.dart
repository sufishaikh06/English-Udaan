// Tests for LearningHubScreen and dictionary domain models.

import 'package:english_udaan/features/dictionary/domain/dictionary_models.dart';
import 'package:english_udaan/features/learning/presentation/learning_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ── Minimal wrapper that satisfies GoRouter context ────────────────────────────

Widget _wrap(Widget child) {
  final router = GoRouter(
    initialLocation: '/learn',
    routes: [
      GoRoute(
        path: '/learn',
        builder: (_, _) => child,
        routes: [
          GoRoute(
            path: 'alphabet',
            builder: (_, _) => const Scaffold(body: Text('Alphabet')),
          ),
          GoRoute(
            path: 'vocabulary',
            builder: (_, _) => const Scaffold(body: Text('Vocabulary')),
          ),
          GoRoute(
            path: 'pictures',
            builder: (_, _) => const Scaffold(body: Text('Pictures')),
          ),
          GoRoute(
            path: 'sentences',
            builder: (_, _) => const Scaffold(body: Text('Sentences')),
          ),
          GoRoute(
            path: 'grammar',
            builder: (_, _) => const Scaffold(body: Text('Grammar')),
          ),
          GoRoute(
            path: 'dictionary',
            builder: (_, _) => const Scaffold(body: Text('Dictionary')),
          ),
        ],
      ),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── LearningHubScreen widget tests ──────────────────────────────────────────

  group('LearningHubScreen', () {
    testWidgets('renders all six learning section cards', (tester) async {
      await tester.pumpWidget(_wrap(const LearningHubScreen()));
      await tester.pumpAndSettle();

      // All 6 card titles must be visible (in the default Urdu language).
      expect(find.text('انگریزی حروف تہجی'), findsOneWidget);
      expect(find.text('الفاظ کا ذخیرہ'), findsOneWidget);
      expect(find.text('تصویری سیکھنا'), findsOneWidget);
      expect(find.text('جملے اور پیراگراف'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('انگریزی گرامر'), 300);
      expect(find.text('انگریزی گرامر'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('اردو-انگریزی لغت'), 300);
      expect(find.text('اردو-انگریزی لغت'), findsOneWidget);
    });

    testWidgets('renders intro banner', (tester) async {
      await tester.pumpWidget(_wrap(const LearningHubScreen()));
      await tester.pumpAndSettle();

      expect(find.text('انگریزی سیکھنے کا آسان راستہ'), findsOneWidget);
    });

    testWidgets('tapping Alphabet card navigates to /learn/alphabet', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const LearningHubScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('انگریزی حروف تہجی'));
      await tester.pumpAndSettle();

      expect(find.text('Alphabet'), findsOneWidget);
    });

    testWidgets('tapping Dictionary card navigates to /learn/dictionary', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const LearningHubScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('اردو-انگریزی لغت'), 300);
      await tester.tap(find.text('اردو-انگریزی لغت'));
      await tester.pumpAndSettle();

      expect(find.text('Dictionary'), findsOneWidget);
    });

    testWidgets('tapping Vocabulary card navigates to /learn/vocabulary', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const LearningHubScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('الفاظ کا ذخیرہ'));
      await tester.pumpAndSettle();

      expect(find.text('Vocabulary'), findsOneWidget);
    });

    testWidgets('tapping Grammar card navigates to /learn/grammar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const LearningHubScreen()));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('انگریزی گرامر'), 300);
      await tester.tap(find.text('انگریزی گرامر'));
      await tester.pumpAndSettle();

      expect(find.text('Grammar'), findsOneWidget);
    });
  });

  // ── DictionaryModels unit tests ─────────────────────────────────────────────

  group('DictionaryResult.fromJson', () {
    test('parses a complete database result correctly', () {
      final json = {
        'query': 'apple',
        'source': 'database',
        'englishWord': 'apple',
        'urduMeaning': 'سیب',
        'simpleDefinition': 'A round fruit.',
        'partOfSpeech': 'noun',
        'examples': [
          {'english': 'I ate an apple.', 'urdu': 'میں نے سیب کھایا۔'},
          {'english': 'She likes apples.', 'urdu': 'اسے سیب پسند ہیں۔'},
        ],
        'pronunciationText': 'apple',
      };

      final result = DictionaryResult.fromJson(json);

      expect(result.source, DictionaryResultSource.database);
      expect(result.englishWord, 'apple');
      expect(result.urduMeaning, 'سیب');
      expect(result.partOfSpeech, 'noun');
      expect(result.examples.length, 2);
      expect(result.examples.first.english, 'I ate an apple.');
      expect(result.ttsText, 'apple');
    });

    test('parses an AI result and maps source correctly', () {
      final json = {
        'query': 'موبائل',
        'source': 'ai',
        'englishWord': 'mobile',
        'urduMeaning': 'موبائل فون',
        'simpleDefinition': 'A handheld phone.',
        'partOfSpeech': 'noun',
        'examples': [
          {'english': 'My mobile is new.', 'urdu': 'میرا موبائل نیا ہے۔'},
        ],
      };

      final result = DictionaryResult.fromJson(json);

      expect(result.source, DictionaryResultSource.ai);
      expect(result.englishWord, 'mobile');
      // When pronunciationText is absent, ttsText falls back to englishWord.
      expect(result.ttsText, 'mobile');
    });

    test('handles missing optional fields gracefully', () {
      final json = {
        'query': 'test',
        'source': 'database',
        'englishWord': 'test',
        'urduMeaning': 'ٹیسٹ',
        'simpleDefinition': '',
        'partOfSpeech': '',
        'examples': <dynamic>[],
      };

      final result = DictionaryResult.fromJson(json);

      expect(result.examples, isEmpty);
      expect(result.simpleDefinition, '');
      expect(result.partOfSpeech, '');
    });

    test('unknown source string defaults to AI', () {
      final json = {
        'query': 'x',
        'source': 'unknown_future_type',
        'englishWord': 'x',
        'urduMeaning': 'ایکس',
        'simpleDefinition': '',
        'partOfSpeech': '',
        'examples': <dynamic>[],
      };

      final result = DictionaryResult.fromJson(json);
      expect(result.source, DictionaryResultSource.ai);
    });
  });

  group('DictionaryExample.fromJson', () {
    test('parses english and urdu fields', () {
      final ex = DictionaryExample.fromJson({
        'english': 'Hello world.',
        'urdu': 'ہیلو دنیا۔',
      });
      expect(ex.english, 'Hello world.');
      expect(ex.urdu, 'ہیلو دنیا۔');
    });

    test('defaults to empty string for missing fields', () {
      final ex = DictionaryExample.fromJson({});
      expect(ex.english, '');
      expect(ex.urdu, '');
    });
  });

  group('DictionaryLookupState sealed classes', () {
    test('DictionaryIdle is idle', () {
      const state = DictionaryIdle();
      expect(state, isA<DictionaryLookupState>());
      expect(state, isA<DictionaryIdle>());
    });

    test('DictionaryLoading is loading', () {
      const state = DictionaryLoading();
      expect(state, isA<DictionaryLoading>());
    });

    test('DictionaryError carries offline flag', () {
      const state = DictionaryError('offline', isOffline: true);
      expect(state.isOffline, isTrue);
      expect(state.aiUnavailable, isFalse);
    });

    test('DictionaryError carries aiUnavailable flag', () {
      const state = DictionaryError('no AI', aiUnavailable: true);
      expect(state.aiUnavailable, isTrue);
      expect(state.isOffline, isFalse);
    });
  });
}
