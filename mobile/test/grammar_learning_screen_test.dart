import 'dart:convert';

import 'package:english_udaan/core/services/speech_service.dart';
import 'package:english_udaan/features/learning/data/learning_repository.dart';
import 'package:english_udaan/features/learning/presentation/grammar_learning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSpeechService implements SpeechService {
  String? spokenText;

  @override
  Future<void> speak(String text) async {
    spokenText = text;
  }
}

void main() {
  testWidgets('grammar list filters by level and opens lesson details', (tester) async {
    final repository = _grammarRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: GrammarLessonsScreen(repository: repository),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('انگریزی گرامر'), findsOneWidget);
    expect(find.text('اجزائے کلام'), findsWidgets);
    expect(find.text('ابتدائی'), findsWidgets);

    await tester.tap(find.text('اعلیٰ'));
    await tester.pump();

    expect(find.text('عام گرامر غلطیاں'), findsOneWidget);
    expect(find.text('اجزائے کلام'), findsNothing);
  });

  testWidgets('grammar detail renders LTR English, RTL Urdu, and speech action', (tester) async {
    final speech = FakeSpeechService();
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: GrammarLessonDetailScreen(
            id: 'grammar-001-parts-of-speech',
            repository: _grammarRepository(),
            speechService: speech,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Parts of Speech'), findsOneWidget);
    expect(find.text('اجزائے کلام'), findsWidgets);
    expect(find.text('Ali reads a book.'), findsOneWidget);
    expect(find.text('علی ایک کتاب پڑھتا ہے۔'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.volume_up_outlined).first);
    await tester.pump();

    expect(speech.spokenText, 'Parts of speech help us understand how words work in a sentence.');
    expect(tester.takeException(), isNull);
  });
}

LearningRepository _grammarRepository() => LearningRepository((path) async => jsonEncode({
      'version': LearningRepository.contentVersion,
      'section': 'grammar',
      'items': [
        _lesson('grammar-001-parts-of-speech', 'beginner', 'partsOfSpeech', 'beginner', 1, 'Parts of Speech', 'اجزائے کلام'),
        _lesson('grammar-002-nouns', 'beginner', 'nouns', 'beginner', 2, 'Nouns', 'اسم'),
        _lesson('grammar-003-pronouns', 'beginner', 'pronouns', 'beginner', 3, 'Pronouns', 'ضمیر'),
        _lesson('grammar-004-verbs', 'beginner', 'verbs', 'beginner', 4, 'Verbs', 'فعل'),
        _lesson('grammar-005-adjectives', 'beginner', 'adjectives', 'beginner', 5, 'Adjectives', 'صفت'),
        _lesson('grammar-006-articles', 'beginner', 'articles', 'beginner', 6, 'Articles', 'آرٹیکلز'),
        _lesson('grammar-007-sentence-structure', 'beginner', 'sentenceStructure', 'beginner', 7, 'Sentence Structure', 'جملے کی ساخت'),
        _lesson('grammar-008-adverbs', 'elementary', 'adverbs', 'developing', 8, 'Adverbs', 'متعلق فعل'),
        _lesson('grammar-009-prepositions', 'elementary', 'prepositions', 'developing', 9, 'Prepositions', 'حروف جار'),
        _lesson('grammar-010-conjunctions', 'elementary', 'conjunctions', 'developing', 10, 'Conjunctions', 'حروف عطف'),
        _lesson('grammar-011-tenses', 'elementary', 'tenses', 'developing', 11, 'Tenses', 'زمانے'),
        _lesson('grammar-012-modals', 'intermediate', 'modals', 'intermediate', 12, 'Modals', 'Modal افعال'),
        _lesson('grammar-013-agreement', 'intermediate', 'agreement', 'intermediate', 13, 'Agreement', 'مطابقت'),
        _lesson('grammar-014-degrees', 'intermediate', 'degrees', 'intermediate', 14, 'Degrees', 'درجات صفت'),
        _lesson('grammar-015-active-passive', 'advanced', 'activePassive', 'advanced', 15, 'Active and Passive Voice', 'Active اور Passive Voice'),
        _lesson('grammar-016-direct-indirect', 'advanced', 'directIndirect', 'advanced', 16, 'Direct and Indirect Speech', 'Direct اور Indirect Speech'),
        _lesson('grammar-017-common-errors', 'advanced', 'commonErrors', 'advanced', 17, 'Common Grammar Errors', 'عام گرامر غلطیاں'),
      ],
    }));

Map<String, Object> _lesson(
  String id,
  String level,
  String category,
  String difficulty,
  int order,
  String titleEnglish,
  String titleUrdu,
) => {
      'id': id,
      'level': level,
      'category': category,
      'difficulty': difficulty,
      'order': order,
      'titleEnglish': titleEnglish,
      'titleUrdu': titleUrdu,
      'explanationEnglish': 'Parts of speech help us understand how words work in a sentence.',
      'explanationUrdu': 'اجزائے کلام ہمیں جملے میں الفاظ کا کام سمجھنے میں مدد دیتے ہیں۔',
      'examples': [
        {
          'english': 'Ali reads a book.',
          'urdu': 'علی ایک کتاب پڑھتا ہے۔',
          'note': 'Ali is a noun and reads is a verb.',
          'ttsText': 'Ali reads a book.',
        }
      ],
      'corrections': [
        {
          'incorrect': 'Ali read a book yesterday now.',
          'correct': 'Ali reads a book.',
          'urdu': 'علی ایک کتاب پڑھتا ہے۔',
        }
      ],
      'ttsText': 'Parts of speech help us understand how words work in a sentence.',
    };
