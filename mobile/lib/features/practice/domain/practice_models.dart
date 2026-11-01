import 'package:flutter/material.dart';

enum PracticeCategory {
  vocabulary,
  pictures,
  sentences,
  grammar,
  mixed;

  String titleUrdu() => switch (this) {
    PracticeCategory.vocabulary => 'الفاظ کی مشق',
    PracticeCategory.pictures => 'تصاویر کی مشق',
    PracticeCategory.sentences => 'جملوں کی مشق',
    PracticeCategory.grammar => 'گرامر کی مشق',
    PracticeCategory.mixed => 'مخلوط مشق',
  };

  String titleEnglish() => switch (this) {
    PracticeCategory.vocabulary => 'Vocabulary Practice',
    PracticeCategory.pictures => 'Picture Practice',
    PracticeCategory.sentences => 'Sentence Practice',
    PracticeCategory.grammar => 'Grammar Practice',
    PracticeCategory.mixed => 'Mixed Quiz',
  };

  String subtitleUrdu() => switch (this) {
    PracticeCategory.vocabulary => '۲، ۳، ۴ اور ۵ حرفی الفاظ کے معنی اور تلفظ',
    PracticeCategory.pictures => 'اشیاء، پھل، سبزیاں اور جانور پہچانیں',
    PracticeCategory.sentences => 'چھوٹے بڑے جملوں کے اردو معانی اور تراجم',
    PracticeCategory.grammar => 'قواعد، درست استعمال اور عام غلطیوں کی تصحیح',
    PracticeCategory.mixed => 'تمام اسباق سے منتخب سوالات کا جامع کوئز',
  };

  String subtitleEnglish() => switch (this) {
    PracticeCategory.vocabulary => '2, 3, 4 & 5-letter word meanings and spelling',
    PracticeCategory.pictures => 'Identify animals, fruits, objects, and vehicles',
    PracticeCategory.sentences => 'Sentence comprehension and accurate translations',
    PracticeCategory.grammar => 'Grammar rules, correct usage, and error correction',
    PracticeCategory.mixed => 'Comprehensive quiz covering all learning modules',
  };

  IconData icon() => switch (this) {
    PracticeCategory.vocabulary => Icons.translate_outlined,
    PracticeCategory.pictures => Icons.image_outlined,
    PracticeCategory.sentences => Icons.subject_outlined,
    PracticeCategory.grammar => Icons.rule_outlined,
    PracticeCategory.mixed => Icons.auto_awesome_outlined,
  };

  Color color() => switch (this) {
    PracticeCategory.vocabulary => const Color(0xFF8A5CF6),
    PracticeCategory.pictures => const Color(0xFFF59E0B),
    PracticeCategory.sentences => const Color(0xFF159A9C),
    PracticeCategory.grammar => const Color(0xFF087B7D),
    PracticeCategory.mixed => const Color(0xFF2563EB),
  };
}

enum PracticeQuestionType {
  urduToEnglishWord,
  englishToUrduWord,
  pictureMatch,
  sentenceTranslation,
  grammarCorrection,
  grammarRule,
}

class PracticeQuestion {
  const PracticeQuestion({
    required this.id,
    required this.category,
    required this.type,
    required this.instructionUrdu,
    required this.instructionEnglish,
    required this.prompt,
    required this.isPromptUrdu,
    this.promptSecondary,
    required this.options,
    required this.correctIndex,
    required this.areOptionsUrdu,
    this.explanationUrdu,
    this.explanationEnglish,
    this.ttsText,
    this.imageAssetPath,
    this.sourceId,
  });

  final String id;
  final PracticeCategory category;
  final PracticeQuestionType type;
  final String instructionUrdu;
  final String instructionEnglish;
  final String prompt;
  final bool isPromptUrdu;
  final String? promptSecondary;
  final List<String> options;
  final int correctIndex;
  final bool areOptionsUrdu;
  final String? explanationUrdu;
  final String? explanationEnglish;
  final String? ttsText;
  final String? imageAssetPath;
  final String? sourceId;

  String get correctAnswer => options[correctIndex];

  void validate() {
    if (id.trim().isEmpty) throw const FormatException('Question ID cannot be empty.');
    if (prompt.trim().isEmpty) throw const FormatException('Question prompt cannot be empty.');
    if (options.length < 2) {
      throw const FormatException('A question must contain at least 2 options.');
    }
    if (correctIndex < 0 || correctIndex >= options.length) {
      throw const FormatException('Invalid correct option index.');
    }
    final uniqueOptions = options.map((o) => o.trim().toLowerCase()).toSet();
    if (uniqueOptions.length != options.length) {
      throw const FormatException('Question options must be distinct.');
    }
  }
}

class PracticeAnswer {
  const PracticeAnswer({
    required this.questionId,
    required this.selectedOptionIndex,
    required this.isCorrect,
  });

  final String questionId;
  final int selectedOptionIndex;
  final bool isCorrect;
}

class QuizSession {
  QuizSession({
    required this.category,
    required List<PracticeQuestion> questions,
  })  : _questions = List.unmodifiable(questions),
        _currentIndex = 0,
        _selectedOptionIndex = null,
        _isAnswerSubmitted = false,
        _answers = [] {
    for (final q in _questions) {
      q.validate();
    }
  }

  final PracticeCategory category;
  final List<PracticeQuestion> _questions;
  int _currentIndex;
  int? _selectedOptionIndex;
  bool _isAnswerSubmitted;
  final List<PracticeAnswer> _answers;

  List<PracticeQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool get isAnswerSubmitted => _isAnswerSubmitted;
  List<PracticeAnswer> get answers => List.unmodifiable(_answers);

  int get totalQuestions => _questions.length;
  bool get isEmpty => _questions.isEmpty;
  bool get isCompleted => _questions.isNotEmpty && _currentIndex >= _questions.length;

  PracticeQuestion? get currentQuestion {
    if (_currentIndex < 0 || _currentIndex >= _questions.length) return null;
    return _questions[_currentIndex];
  }

  int get score => _answers.where((a) => a.isCorrect).length;

  double get percentage {
    if (totalQuestions == 0) return 0.0;
    return (score / totalQuestions) * 100.0;
  }

  void selectOption(int index) {
    if (isCompleted || _isAnswerSubmitted) return;
    if (index < 0 || (currentQuestion != null && index >= currentQuestion!.options.length)) {
      return;
    }
    _selectedOptionIndex = index;
  }

  bool submitAnswer() {
    if (isCompleted || _isAnswerSubmitted) return false;
    final question = currentQuestion;
    if (question == null || _selectedOptionIndex == null) return false;

    // Check if this question was already answered to prevent accidental double submission
    if (_answers.any((a) => a.questionId == question.id)) {
      return false;
    }

    final isCorrect = _selectedOptionIndex == question.correctIndex;
    _answers.add(PracticeAnswer(
      questionId: question.id,
      selectedOptionIndex: _selectedOptionIndex!,
      isCorrect: isCorrect,
    ));
    _isAnswerSubmitted = true;
    return isCorrect;
  }

  void nextQuestion() {
    if (!_isAnswerSubmitted && !isCompleted && _questions.isNotEmpty) return;
    if (_currentIndex < _questions.length) {
      _currentIndex++;
    }
    _selectedOptionIndex = null;
    _isAnswerSubmitted = false;
  }

  QuizSession restart() {
    return QuizSession(category: category, questions: _questions);
  }
}
