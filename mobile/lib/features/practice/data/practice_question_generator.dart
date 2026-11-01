import 'dart:math';

import '../../learning/data/learning_repository.dart';
import '../../learning/domain/learning_models.dart';
import '../domain/practice_models.dart';

class PracticeQuestionGenerator {
  const PracticeQuestionGenerator({
    required this.repository,
    this.random,
  });

  final LearningRepository repository;
  final Random? random;

  Random get _rng => random ?? Random();

  Future<List<PracticeQuestion>> generateQuestions({
    required PracticeCategory category,
    int count = 10,
  }) async {
    return switch (category) {
      PracticeCategory.vocabulary => _generateVocabularyQuestions(count),
      PracticeCategory.pictures => _generatePictureQuestions(count),
      PracticeCategory.sentences => _generateSentenceQuestions(count),
      PracticeCategory.grammar => _generateGrammarQuestions(count),
      PracticeCategory.mixed => _generateMixedQuestions(count),
    };
  }

  Future<List<PracticeQuestion>> _generateVocabularyQuestions(int count) async {
    // Load words from 2, 3, 4, 5-letter sections
    final vocab2 = await repository.loadVocabulary(wordLength: 2);
    final vocab3 = await repository.loadVocabulary(wordLength: 3);
    final vocab4 = await repository.loadVocabulary(wordLength: 4);
    final vocab5 = await repository.loadVocabulary(wordLength: 5);

    final allVocab = [...vocab2, ...vocab3, ...vocab4, ...vocab5];
    if (allVocab.length < 4) return const [];

    final shuffledVocab = List<VocabularyItem>.from(allVocab)..shuffle(_rng);
    final selectedTargets = shuffledVocab.take(min(count, allVocab.length)).toList();

    final questions = <PracticeQuestion>[];

    for (var i = 0; i < selectedTargets.length; i++) {
      final target = selectedTargets[i];
      // Alternate between Urdu -> English word and English -> Urdu meaning
      final isUrduToEnglish = i % 2 == 0;

      if (isUrduToEnglish) {
        final distractorCandidates = allVocab
            .where((w) => w.id != target.id && w.word != target.word)
            .toList()
          ..shuffle(_rng);

        final distractors = distractorCandidates
            .map((w) => w.word)
            .toSet()
            .take(3)
            .toList();

        if (distractors.length < 3) continue;

        final options = [target.word, ...distractors]..shuffle(_rng);
        final correctIndex = options.indexOf(target.word);

        questions.add(PracticeQuestion(
          id: 'practice-vocab-u2e-${target.id}',
          category: PracticeCategory.vocabulary,
          type: PracticeQuestionType.urduToEnglishWord,
          instructionUrdu: 'اس اردو معنی کا درست انگریزی لفظ منتخب کریں:',
          instructionEnglish: 'Select the correct English word for this Urdu meaning:',
          prompt: target.urduMeaning,
          isPromptUrdu: true,
          promptSecondary: 'مثال: ${target.example}',
          options: options,
          correctIndex: correctIndex,
          areOptionsUrdu: false,
          explanationUrdu: 'درست لفظ "${target.word}" ہے۔ مثال: ${target.example}',
          explanationEnglish: 'The correct word is "${target.word}". Example: ${target.example}',
          ttsText: target.word,
          sourceId: target.id,
        ));
      } else {
        final distractorCandidates = allVocab
            .where((w) => w.id != target.id && w.urduMeaning != target.urduMeaning)
            .toList()
          ..shuffle(_rng);

        final distractors = distractorCandidates
            .map((w) => w.urduMeaning)
            .toSet()
            .take(3)
            .toList();

        if (distractors.length < 3) continue;

        final options = [target.urduMeaning, ...distractors]..shuffle(_rng);
        final correctIndex = options.indexOf(target.urduMeaning);

        questions.add(PracticeQuestion(
          id: 'practice-vocab-e2u-${target.id}',
          category: PracticeCategory.vocabulary,
          type: PracticeQuestionType.englishToUrduWord,
          instructionUrdu: 'اس انگریزی لفظ کا درست اردو معنی منتخب کریں:',
          instructionEnglish: 'Select the correct Urdu meaning for this English word:',
          prompt: target.word,
          isPromptUrdu: false,
          promptSecondary: 'Example: ${target.example}',
          options: options,
          correctIndex: correctIndex,
          areOptionsUrdu: true,
          explanationUrdu: '"${target.word}" کا اردو معنی "${target.urduMeaning}" ہے۔',
          explanationEnglish: '"${target.word}" means "${target.urduMeaning}".',
          ttsText: target.word,
          sourceId: target.id,
        ));
      }
    }

    return questions;
  }

  Future<List<PracticeQuestion>> _generatePictureQuestions(int count) async {
    final pictureItems = await repository.loadPictureItems();
    if (pictureItems.length < 4) return const [];

    final shuffled = List<PictureItem>.from(pictureItems)..shuffle(_rng);
    final targets = shuffled.take(min(count, pictureItems.length)).toList();

    final questions = <PracticeQuestion>[];

    for (final target in targets) {
      final distractorCandidates = pictureItems
          .where((p) => p.id != target.id && p.english != target.english)
          .toList()
        ..shuffle(_rng);

      final distractors = distractorCandidates
          .map((p) => p.english)
          .toSet()
          .take(3)
          .toList();

      if (distractors.length < 3) continue;

      final options = [target.english, ...distractors]..shuffle(_rng);
      final correctIndex = options.indexOf(target.english);

      questions.add(PracticeQuestion(
        id: 'practice-pic-${target.id}',
        category: PracticeCategory.pictures,
        type: PracticeQuestionType.pictureMatch,
        instructionUrdu: 'تصویر دیکھیں اور درست انگریزی لفظ منتخب کریں:',
        instructionEnglish: 'Look at the picture and select the correct English word:',
        prompt: target.urdu,
        isPromptUrdu: true,
        imageAssetPath: target.localAssetPath,
        options: options,
        correctIndex: correctIndex,
        areOptionsUrdu: false,
        explanationUrdu: 'تصویر میں موجود چیز کا انگریزی نام "${target.english}" ہے۔',
        explanationEnglish: 'The item in the picture is "${target.english}".',
        ttsText: target.english,
        sourceId: target.id,
      ));
    }

    return questions;
  }

  Future<List<PracticeQuestion>> _generateSentenceQuestions(int count) async {
    final sentenceItems = await repository.loadSentenceLearningItems();
    if (sentenceItems.length < 3) return const [];

    final shuffled = List<SentenceLearningItem>.from(sentenceItems)..shuffle(_rng);
    final targets = shuffled.take(min(count, sentenceItems.length)).toList();

    final questions = <PracticeQuestion>[];

    for (final target in targets) {
      final distractorCandidates = sentenceItems
          .where((s) => s.id != target.id && s.urdu != target.urdu)
          .toList()
        ..shuffle(_rng);

      final distractors = distractorCandidates
          .map((s) => s.urdu)
          .toSet()
          .take(3)
          .toList();

      if (distractors.length < 2) continue;

      final options = [target.urdu, ...distractors]..shuffle(_rng);
      final correctIndex = options.indexOf(target.urdu);

      questions.add(PracticeQuestion(
        id: 'practice-sentence-${target.id}',
        category: PracticeCategory.sentences,
        type: PracticeQuestionType.sentenceTranslation,
        instructionUrdu: 'اس انگریزی جملے کا درست اردو ترجمہ منتخب کریں:',
        instructionEnglish: 'Select the correct Urdu translation for this sentence:',
        prompt: target.english,
        isPromptUrdu: false,
        options: options,
        correctIndex: correctIndex,
        areOptionsUrdu: true,
        explanationUrdu: 'درست ترجمہ: "${target.urdu}"',
        explanationEnglish: 'Correct translation: "${target.urdu}"',
        ttsText: target.ttsText,
        sourceId: target.id,
      ));
    }

    return questions;
  }

  Future<List<PracticeQuestion>> _generateGrammarQuestions(int count) async {
    final lessons = await repository.loadGrammarLessons();
    if (lessons.isEmpty) return const [];

    final questions = <PracticeQuestion>[];

    // First collect all correction items
    final allCorrections = <({GrammarLesson lesson, GrammarCorrection correction})>[];
    for (final lesson in lessons) {
      for (final corr in lesson.corrections) {
        allCorrections.add((lesson: lesson, correction: corr));
      }
    }

    // Shuffle corrections
    final shuffledCorrections = List.of(allCorrections)..shuffle(_rng);

    for (final item in shuffledCorrections) {
      if (questions.length >= count) break;

      final corr = item.correction;
      // Distractors can come from other corrections' correct sentences, or variations
      final distractorCandidates = allCorrections
          .where((c) => c.correction.correct != corr.correct)
          .map((c) => c.correction.correct)
          .toSet()
          .toList()
        ..shuffle(_rng);

      // Also include the incorrect sentence as an obvious distractor option
      final distractors = <String>{};
      distractors.add(corr.incorrect);
      for (final cand in distractorCandidates) {
        if (distractors.length >= 3) break;
        distractors.add(cand);
      }

      if (distractors.length < 2) continue;

      final options = [corr.correct, ...distractors]..shuffle(_rng);
      final correctIndex = options.indexOf(corr.correct);

      questions.add(PracticeQuestion(
        id: 'practice-grammar-corr-${item.lesson.id}-${questions.length}',
        category: PracticeCategory.grammar,
        type: PracticeQuestionType.grammarCorrection,
        instructionUrdu: 'اس غلط جملے کی درست شکل منتخب کریں:',
        instructionEnglish: 'Select the correct form for this incorrect sentence:',
        prompt: corr.incorrect,
        isPromptUrdu: false,
        promptSecondary: 'عنوان: ${item.lesson.titleUrdu} (${item.lesson.titleEnglish})',
        options: options,
        correctIndex: correctIndex,
        areOptionsUrdu: false,
        explanationUrdu: 'درست جملہ: "${corr.correct}" — وضاحت: ${corr.urdu}',
        explanationEnglish: 'Correct: "${corr.correct}" — Explanation: ${corr.urdu}',
        ttsText: corr.correct,
        sourceId: item.lesson.id,
      ));
    }

    // If more questions needed, generate from examples
    if (questions.length < count) {
      final allExamples = <({GrammarLesson lesson, GrammarExample example})>[];
      for (final lesson in lessons) {
        for (final ex in lesson.examples) {
          allExamples.add((lesson: lesson, example: ex));
        }
      }
      allExamples.shuffle(_rng);

      for (final item in allExamples) {
        if (questions.length >= count) break;
        final ex = item.example;

        final distractorCandidates = allExamples
            .where((e) => e.example.english != ex.english)
            .map((e) => e.example.english)
            .toSet()
            .toList()
          ..shuffle(_rng);

        if (distractorCandidates.length < 3) continue;
        final distractors = distractorCandidates.take(3).toList();

        final options = [ex.english, ...distractors]..shuffle(_rng);
        final correctIndex = options.indexOf(ex.english);

        questions.add(PracticeQuestion(
          id: 'practice-grammar-ex-${item.lesson.id}-${questions.length}',
          category: PracticeCategory.grammar,
          type: PracticeQuestionType.grammarRule,
          instructionUrdu: 'اس اردو جملے کا درست انگریزی گرامر ترجمہ منتخب کریں:',
          instructionEnglish: 'Select the correct English sentence for this Urdu phrase:',
          prompt: ex.urdu,
          isPromptUrdu: true,
          promptSecondary: 'موضوع: ${item.lesson.titleUrdu} (${item.lesson.titleEnglish})',
          options: options,
          correctIndex: correctIndex,
          areOptionsUrdu: false,
          explanationUrdu: 'درست جملہ: "${ex.english}" — نوٹ: ${ex.note}',
          explanationEnglish: 'Correct: "${ex.english}" — Note: ${ex.note}',
          ttsText: ex.ttsText,
          sourceId: item.lesson.id,
        ));
      }
    }

    return questions;
  }

  Future<List<PracticeQuestion>> _generateMixedQuestions(int count) async {
    // Collect from all categories proportionally
    final vocabQuota = (count * 0.35).ceil();
    final picQuota = (count * 0.25).ceil();
    final sentQuota = (count * 0.20).ceil();
    final gramQuota = count - (vocabQuota + picQuota + sentQuota);

    final vocabQuestions = await _generateVocabularyQuestions(vocabQuota);
    final picQuestions = await _generatePictureQuestions(picQuota);
    final sentQuestions = await _generateSentenceQuestions(sentQuota);
    final gramQuestions = await _generateGrammarQuestions(max(gramQuota, 2));

    final combined = [
      ...vocabQuestions,
      ...picQuestions,
      ...sentQuestions,
      ...gramQuestions,
    ]..shuffle(_rng);

    return combined.take(count).toList();
  }
}
