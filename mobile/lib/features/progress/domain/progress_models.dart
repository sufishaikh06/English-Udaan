enum SyncState { localOnly, pending, synced, failed }

class LessonSectionStatus {
  const LessonSectionStatus({
    required this.id,
    required this.labelEnglish,
    required this.labelUrdu,
    required this.completed,
    this.wordCount,
  });

  final String id;
  final String labelEnglish;
  final String labelUrdu;
  final bool completed;

  /// Vocabulary words in a completed section. Null when the section is not a
  /// vocabulary word list. Section completion is not word-level mastery.
  final int? wordCount;
}

class QuizCategoryResult {
  const QuizCategoryResult({
    required this.category,
    required this.score,
    required this.total,
    this.completedAt,
  });

  final String category;
  final int score;
  final int total;
  final DateTime? completedAt;

  int? get accuracyPercent {
    if (total <= 0) return null;
    return ((score / total) * 100).round();
  }
}

class ProgressSummary {
  const ProgressSummary({
    required this.sections,
    required this.quizResults,
    required this.activityDates,
    required this.today,
    this.syncState = SyncState.localOnly,
  });

  final List<LessonSectionStatus> sections;
  final List<QuizCategoryResult> quizResults;
  final List<DateTime> activityDates;
  final DateTime? today;
  final SyncState syncState;

  int get sectionsCompleted => sections.where((section) => section.completed).length;

  int get sectionsTotal => sections.length;

  /// Words in vocabulary sections the learner marked complete.
  /// This is section-level, not proof that each word was studied.
  int get wordsInCompletedSections => sections
      .where((section) => section.completed && section.wordCount != null)
      .fold(0, (sum, section) => sum + section.wordCount!);

  int? get overallPercent {
    if (sectionsTotal == 0) return null;
    return ((sectionsCompleted / sectionsTotal) * 100).round();
  }

  int get quizzesRecorded => quizResults.length;

  int get quizQuestionsAnswered =>
      quizResults.fold(0, (sum, result) => sum + result.total);

  int get quizCorrectAnswers =>
      quizResults.fold(0, (sum, result) => sum + result.score);

  /// Weighted accuracy across latest quiz results. Null when no questions exist.
  /// Latest-score records are not a full quiz history.
  int? get accuracyPercent {
    final answered = quizQuestionsAnswered;
    if (answered <= 0) return null;
    return ((quizCorrectAnswers / answered) * 100).round();
  }

  int get currentStreak {
    final t = today;
    if (t == null) return 0;
    return streakLength(activityDates, t);
  }

  int get longestStreak => longestStreakLength(activityDates);

  bool get studiedToday {
    final t = today;
    if (t == null) return false;
    return activityDates.any((date) => _sameDay(date, t));
  }
}

DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

int streakLength(List<DateTime> activityDates, DateTime today) {
  final days = activityDates
      .map(dateOnly)
      .where((date) => !date.isAfter(dateOnly(today)))
      .toSet();
  if (days.isEmpty) return 0;
  var cursor = dateOnly(today);
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

int longestStreakLength(List<DateTime> activityDates) {
  final days = activityDates.map(dateOnly).toSet().toList()..sort();
  if (days.isEmpty) return 0;
  var longest = 1;
  var current = 1;
  for (var i = 1; i < days.length; i++) {
    final gap = days[i].difference(days[i - 1]).inDays;
    if (gap == 1) {
      current++;
      if (current > longest) longest = current;
    } else if (gap > 1) {
      current = 1;
    }
  }
  return longest;
}
