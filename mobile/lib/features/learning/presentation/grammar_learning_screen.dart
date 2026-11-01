import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart' show preferencesProvider;
import '../../../shared/widgets/app_components.dart';
import '../data/learning_repository.dart';
import '../domain/learning_models.dart';

class GrammarLessonsScreen extends StatefulWidget {
  const GrammarLessonsScreen({super.key, this.repository});

  final LearningRepository? repository;

  @override
  State<GrammarLessonsScreen> createState() => _GrammarLessonsScreenState();
}

class _GrammarLessonsScreenState extends State<GrammarLessonsScreen> {
  late final LearningRepository _repository =
      widget.repository ?? LearningRepository.bundled();
  late final Future<List<GrammarLesson>> _lessonsFuture = _repository
      .loadGrammarLessons();
  String _selectedLevel = _allLevels;

  static const _allLevels = 'all';
  static const _levels = ['beginner', 'elementary', 'intermediate', 'advanced'];

  @override
  Widget build(BuildContext context) {
    final isUrdu = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      appBar: AppBar(title: Text(isUrdu ? 'انگریزی گرامر' : 'English grammar')),
      body: FutureBuilder<List<GrammarLesson>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppStateView(
              icon: Icons.error_outline,
              title: isUrdu ? 'مواد دستیاب نہیں' : 'Content unavailable',
              message: isUrdu
                  ? 'گرامر اسباق لوڈ نہیں ہو سکے۔'
                  : 'Grammar lessons could not be loaded.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final lessons = snapshot.data!;
          final visible = _selectedLevel == _allLevels
              ? lessons
              : lessons
                    .where((lesson) => lesson.level == _selectedLevel)
                    .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isUrdu
                          ? 'قواعد کو مرحلہ وار سیکھیں، مثالیں سنیں، اور عام غلطیاں درست کریں۔'
                          : 'Learn grammar step by step, listen to examples, and fix common errors.',
                    ),
                    const SizedBox(height: AppSpacing.small),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: _allLevels,
                            label: Text(isUrdu ? 'سب' : 'All'),
                          ),
                          for (final level in _levels)
                            ButtonSegment(
                              value: level,
                              label: Text(_levelLabel(level, isUrdu)),
                            ),
                        ],
                        selected: {_selectedLevel},
                        onSelectionChanged: (selection) =>
                            setState(() => _selectedLevel = selection.first),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.medium,
                    0,
                    AppSpacing.medium,
                    AppSpacing.large,
                  ),
                  itemCount: visible.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.small),
                  itemBuilder: (context, index) {
                    final lesson = visible[index];
                    return _GrammarLessonCard(
                      lesson: lesson,
                      isUrdu: isUrdu,
                      onTap: () => context.push('/learn/grammar/${lesson.id}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class GrammarLessonDetailScreen extends ConsumerStatefulWidget {
  const GrammarLessonDetailScreen({
    super.key,
    required this.id,
    this.repository,
    this.speechService,
  });

  final String id;
  final LearningRepository? repository;
  final SpeechService? speechService;

  @override
  ConsumerState<GrammarLessonDetailScreen> createState() =>
      _GrammarLessonDetailScreenState();
}

class _GrammarLessonDetailScreenState
    extends ConsumerState<GrammarLessonDetailScreen> {
  late final LearningRepository _repository =
      widget.repository ?? LearningRepository.bundled();
  late final SpeechService _speech =
      widget.speechService ?? DeviceSpeechService();
  late final Future<List<GrammarLesson>> _lessonsFuture = _repository
      .loadGrammarLessons();

  Future<void> _speakWithPreferences(String text) async {
    if (widget.speechService != null) {
      await _speech.speak(text);
      return;
    }
    final preferences = ref.read(preferencesProvider);
    await DeviceSpeechService(
      preferences: SpeechPreferences(
        enabled: preferences.speechEnabled,
        rate: preferences.speechRate,
      ),
    ).speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = Directionality.of(context) == TextDirection.rtl;
    return FutureBuilder<List<GrammarLesson>>(
      future: _lessonsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(isUrdu ? 'انگریزی گرامر' : 'English grammar'),
            ),
            body: AppStateView(
              icon: Icons.error_outline,
              title: isUrdu ? 'مواد دستیاب نہیں' : 'Content unavailable',
              message: isUrdu
                  ? 'گرامر سبق لوڈ نہیں ہو سکا۔'
                  : 'The grammar lesson could not be loaded.',
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final lessons = snapshot.data!;
        final index = lessons.indexWhere((lesson) => lesson.id == widget.id);
        if (index < 0) {
          return Scaffold(
            appBar: AppBar(
              title: Text(isUrdu ? 'سبق نہیں ملا' : 'Lesson not found'),
            ),
            body: AppStateView(
              icon: Icons.search_off,
              title: isUrdu ? 'سبق نہیں ملا' : 'Lesson not found',
              message: isUrdu
                  ? 'یہ گرامر سبق موجود نہیں۔'
                  : 'This grammar lesson is not available.',
            ),
          );
        }
        final lesson = lessons[index];
        return Scaffold(
          appBar: AppBar(
            title: Text(isUrdu ? lesson.titleUrdu : lesson.titleEnglish),
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.medium),
            children: [
              _HeaderCard(
                lesson: lesson,
                isUrdu: isUrdu,
                onSpeak: () => _speakWithPreferences(lesson.ttsText),
              ),
              const SizedBox(height: AppSpacing.medium),
              _ExplanationCard(lesson: lesson),
              const SizedBox(height: AppSpacing.medium),
              Text(
                isUrdu ? 'مثالیں' : 'Examples',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.small),
              for (final example in lesson.examples) ...[
                _ExampleCard(
                  example: example,
                  isUrdu: isUrdu,
                  onSpeak: () => _speakWithPreferences(example.ttsText),
                ),
                const SizedBox(height: AppSpacing.small),
              ],
              if (lesson.corrections.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.small),
                Text(
                  isUrdu
                      ? 'عام غلطی اور درستگی'
                      : 'Common error and correction',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                for (final correction in lesson.corrections) ...[
                  _CorrectionCard(correction: correction),
                  const SizedBox(height: AppSpacing.small),
                ],
              ],
              const SizedBox(height: AppSpacing.medium),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: index == 0
                          ? null
                          : () => context.go(
                              '/learn/grammar/${lessons[index - 1].id}',
                            ),
                      icon: const Icon(Icons.chevron_left),
                      label: Text(isUrdu ? 'پچھلا' : 'Previous'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: index == lessons.length - 1
                          ? null
                          : () => context.go(
                              '/learn/grammar/${lessons[index + 1].id}',
                            ),
                      icon: const Icon(Icons.chevron_right),
                      label: Text(isUrdu ? 'اگلا' : 'Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GrammarLessonCard extends StatelessWidget {
  const _GrammarLessonCard({
    required this.lesson,
    required this.isUrdu,
    required this.onTap,
  });

  final GrammarLesson lesson;
  final bool isUrdu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: AppRadii.medium,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isUrdu ? lesson.titleUrdu : lesson.titleEnglish,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Directionality(
                textDirection: isUrdu ? TextDirection.ltr : TextDirection.rtl,
                child: Text(
                  isUrdu ? lesson.titleEnglish : lesson.titleUrdu,
                  textAlign: isUrdu ? TextAlign.left : TextAlign.right,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.xSmall,
                children: [
                  Chip(label: Text(_levelLabel(lesson.level, isUrdu))),
                  Chip(
                    label: Text(
                      isUrdu
                          ? '${lesson.examples.length} مثالیں'
                          : '${lesson.examples.length} examples',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.lesson,
    required this.isUrdu,
    required this.onSpeak,
  });

  final GrammarLesson lesson;
  final bool isUrdu;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${isUrdu ? 'سبق' : 'Lesson'} ${lesson.order}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              IconButton(
                onPressed: onSpeak,
                tooltip: isUrdu ? 'تلفظ سنیں' : 'Listen',
                icon: const Icon(Icons.volume_up_outlined),
              ),
            ],
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              lesson.titleEnglish,
              textAlign: TextAlign.left,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              lesson.titleUrdu,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.lesson});

  final GrammarLesson lesson;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              lesson.explanationEnglish,
              textAlign: TextAlign.left,
              softWrap: true,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              lesson.explanationUrdu,
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.example,
    required this.isUrdu,
    required this.onSpeak,
  });

  final GrammarExample example;
  final bool isUrdu;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    example.english,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              IconButton(
                onPressed: onSpeak,
                tooltip: isUrdu ? 'تلفظ سنیں' : 'Listen',
                icon: const Icon(Icons.volume_up_outlined),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(example.urdu, textAlign: TextAlign.right),
          ),
          const SizedBox(height: AppSpacing.small),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              example.note,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    ),
  );
}

class _CorrectionCard extends StatelessWidget {
  const _CorrectionCard({required this.correction});

  final GrammarCorrection correction;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              'Incorrect: ${correction.incorrect}',
              textAlign: TextAlign.left,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              'Correct: ${correction.correct}',
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(correction.urdu, textAlign: TextAlign.right),
          ),
        ],
      ),
    ),
  );
}

String _levelLabel(String level, bool isUrdu) {
  if (isUrdu) {
    return switch (level) {
      'beginner' => 'ابتدائی',
      'elementary' => 'بنیادی',
      'intermediate' => 'درمیانی',
      'advanced' => 'اعلیٰ',
      _ => level,
    };
  }
  return switch (level) {
    'beginner' => 'Beginner',
    'elementary' => 'Elementary',
    'intermediate' => 'Intermediate',
    'advanced' => 'Advanced',
    _ => level,
  };
}
