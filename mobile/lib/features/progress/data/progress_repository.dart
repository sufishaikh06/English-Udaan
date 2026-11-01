import '../../learning/data/learning_repository.dart';
import '../../practice/domain/practice_models.dart';
import '../domain/progress_models.dart';

class ProgressRepository {
  ProgressRepository([LearningRepository? learningRepository, this._clock])
    : _learningRepository = learningRepository ?? LearningRepository.bundled();

  static const activityDatesKey = 'progress.activity.dates';
  static const syncStateKey = 'progress.sync.state';
  static const activeUserKey = 'progress.active.firebase.uid';

  static const vocabularySections =
      <({String id, int length, String en, String ur})>[
        (
          id: 'vocabulary-two',
          length: 2,
          en: '2-letter words',
          ur: 'دو حرفی الفاظ',
        ),
        (
          id: 'vocabulary-three',
          length: 3,
          en: '3-letter words',
          ur: 'تین حرفی الفاظ',
        ),
        (
          id: 'vocabulary-four',
          length: 4,
          en: '4-letter words',
          ur: 'چار حرفی الفاظ',
        ),
        (
          id: 'vocabulary-five',
          length: 5,
          en: '5-letter words',
          ur: 'پانچ حرفی الفاظ',
        ),
      ];

  static ProgressSummary? _memory;
  static String? _activeUid;
  final LearningRepository _learningRepository;
  final DateTime Function()? _clock;
  DateTime _now() => _clock?.call() ?? DateTime.now();

  Future<List<LessonSectionStatus>> _loadSectionCatalog() async {
    final sections = <LessonSectionStatus>[];
    for (final section in vocabularySections) {
      final words = await _learningRepository.loadVocabulary(
        wordLength: section.length,
      );
      sections.add(
        LessonSectionStatus(
          id: section.id,
          labelEnglish: section.en,
          labelUrdu: section.ur,
          completed: false,
          wordCount: words.length,
        ),
      );
    }
    for (final category in await _learningRepository.loadPictureCategories()) {
      sections.add(
        LessonSectionStatus(
          id: 'pictures-${category.id}',
          labelEnglish: category.titleEnglish,
          labelUrdu: category.titleUrdu,
          completed: false,
        ),
      );
    }
    return sections;
  }

  Future<ProgressSummary> loadSummary() async {
    final stored = _memory;
    if (stored != null) {
      return ProgressSummary(
        sections: stored.sections,
        quizResults: stored.quizResults,
        activityDates: stored.activityDates,
        today: dateOnly(_now()),
        syncState: stored.syncState,
      );
    }

    // Guest sessions have no persistent state. Build the display catalogue
    // without retaining any learner progress on the device.
    return ProgressSummary(
      sections: await _loadSectionCatalog(),
      quizResults: const [],
      activityDates: const [],
      today: dateOnly(_now()),
      syncState: SyncState.localOnly,
    );
  }

  Future<void> activateAccount(String uid) async {
    // Repeated initialization for the same Firebase session must not erase
    // progress that has already been restored or recorded in memory.
    if (_activeUid == uid) return;
    _activeUid = uid;
    _memory = null;

    // Seed the in-memory account session with the complete section catalogue
    // before the first GET. A fresh MongoDB account legitimately returns empty
    // arrays, but the app still needs known sections to record its first lesson.
    final catalog = await _loadSectionCatalog();
    if (_activeUid != uid) return;
    _memory = ProgressSummary(
      sections: catalog,
      quizResults: const [],
      activityDates: const [],
      today: dateOnly(_now()),
      syncState: SyncState.pending,
    );
  }

  void clearMemory() {
    _activeUid = null;
    _memory = null;
  }

  bool get hasActiveAccount => _activeUid != null;
  String? get activeUid => _activeUid;
  bool isActiveFor(String uid) => _activeUid == uid;

  Future<void> markSectionCompleted(String id) async {
    if (!hasActiveAccount) return;
    final summary = await loadSummary();
    _memory = ProgressSummary(
      sections: summary.sections
          .map(
            (s) => s.id == id
                ? LessonSectionStatus(
                    id: s.id,
                    labelEnglish: s.labelEnglish,
                    labelUrdu: s.labelUrdu,
                    completed: true,
                    wordCount: s.wordCount,
                  )
                : s,
          )
          .toList(),
      quizResults: summary.quizResults,
      activityDates: summary.activityDates,
      today: summary.today,
      syncState: SyncState.pending,
    );
  }

  Future<void> saveQuizResult(
    PracticeCategory category,
    int score,
    int total,
  ) async {
    if (!hasActiveAccount) return;
    final summary = await loadSummary();
    final results = [
      ...summary.quizResults.where((q) => q.category != category.name),
      QuizCategoryResult(
        category: category.name,
        score: score,
        total: total,
        completedAt: _now(),
      ),
    ];
    _memory = ProgressSummary(
      sections: summary.sections,
      quizResults: results,
      activityDates: summary.activityDates,
      today: summary.today,
      syncState: SyncState.pending,
    );
  }

  Future<void> recordStudyActivity([DateTime? when]) async {
    if (!hasActiveAccount) return;
    final day = dateOnly(when ?? _now());
    if (day.isAfter(dateOnly(_now()))) return;
    final summary = await loadSummary();
    final dates = {...summary.activityDates.map(dateOnly), day}.toList()
      ..sort();
    _memory = ProgressSummary(
      sections: summary.sections,
      quizResults: summary.quizResults,
      activityDates: dates,
      today: summary.today,
      syncState: SyncState.pending,
    );
  }

  Future<void> setSyncState(SyncState state) async {
    if (_memory == null) return;
    _memory = ProgressSummary(
      sections: _memory!.sections,
      quizResults: _memory!.quizResults,
      activityDates: _memory!.activityDates,
      today: _memory!.today,
      syncState: state,
    );
  }

  Future<void> mergeCloudSummary(
    ProgressSummary cloud, {
    String? expectedUid,
  }) async {
    if (expectedUid != null && expectedUid != _activeUid) return;

    final current = _memory;
    final catalog = current?.sections ?? await _loadSectionCatalog();
    if (expectedUid != null && expectedUid != _activeUid) return;

    final currentById = <String, LessonSectionStatus>{
      for (final section in current?.sections ?? const <LessonSectionStatus>[])
        section.id: section,
    };
    final cloudById = <String, LessonSectionStatus>{
      for (final section in cloud.sections) section.id: section,
    };
    final sections = catalog.map((section) {
      final local = currentById[section.id];
      final saved = cloudById.remove(section.id);
      return LessonSectionStatus(
        id: section.id,
        labelEnglish: section.labelEnglish,
        labelUrdu: section.labelUrdu,
        completed: (saved?.completed ?? false) || (local?.completed ?? false),
        wordCount: section.wordCount ?? saved?.wordCount ?? local?.wordCount,
      );
    }).toList();
    sections.addAll(cloudById.values);

    // Preserve quiz attempts recorded while the restore request was in flight,
    // while keeping only the newest result per category (the Progress UI's
    // documented behavior).
    final quizzesByCategory = <String, QuizCategoryResult>{};
    for (final result in [
      ...?current?.quizResults,
      ...cloud.quizResults,
    ]) {
      final previous = quizzesByCategory[result.category];
      final candidateTime = result.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final previousTime = previous?.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      if (previous == null || !candidateTime.isBefore(previousTime)) {
        quizzesByCategory[result.category] = result;
      }
    }

    final activityDates = {
      ...?current?.activityDates.map(dateOnly),
      ...cloud.activityDates.map(dateOnly),
    }.toList()..sort();

    _memory = ProgressSummary(
      sections: sections,
      quizResults: quizzesByCategory.values.toList(),
      activityDates: activityDates,
      today: dateOnly(_now()),
      syncState: cloud.syncState,
    );
  }
}
