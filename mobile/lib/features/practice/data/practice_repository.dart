import 'dart:math';

import '../../learning/data/learning_repository.dart';
import '../../progress/data/progress_repository.dart';
import '../domain/practice_models.dart';
import 'practice_question_generator.dart';

class PracticeRepository {
  PracticeRepository({
    required LearningRepository learningRepository,
    Random? random,
  }) : _generator = PracticeQuestionGenerator(
         repository: learningRepository,
         random: random,
       );

  final PracticeQuestionGenerator _generator;

  Future<List<PracticeQuestion>> getQuizQuestions({
    required PracticeCategory category,
    int count = 10,
  }) async {
    return _generator.generateQuestions(category: category, count: count);
  }

  Future<void> saveQuizResult({
    required PracticeCategory category,
    required int score,
    required int total,
  }) async {
    final repository = ProgressRepository();
    await repository.saveQuizResult(category, score, total);
    await repository.recordStudyActivity();
  }

  Future<({int score, int total})?> getLastQuizResult(
    PracticeCategory category,
  ) async {
    final result = (await ProgressRepository().loadSummary()).quizResults.where(
      (item) => item.category == category.name,
    );
    if (result.isEmpty) return null;
    return (score: result.first.score, total: result.first.total);
  }
}
