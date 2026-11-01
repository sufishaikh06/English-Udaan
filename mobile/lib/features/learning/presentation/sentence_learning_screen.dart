import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart' show preferencesProvider;
import '../../../shared/widgets/app_components.dart';
import '../data/learning_repository.dart';
import '../domain/learning_models.dart';

class SentenceLearningScreen extends ConsumerStatefulWidget {
  const SentenceLearningScreen({super.key, this.speechService});

  final SpeechService? speechService;

  @override
  ConsumerState<SentenceLearningScreen> createState() =>
      _SentenceLearningScreenState();
}

class _SentenceLearningScreenState
    extends ConsumerState<SentenceLearningScreen> {
  final _repository = LearningRepository.bundled();
  late final SpeechService _speech =
      widget.speechService ?? DeviceSpeechService();
  late final Future<List<SentenceLearningItem>> _itemsFuture = _repository
      .loadSentenceLearningItems();
  LearningContentType? _selectedType;
  static const _allLessons = 'all';

  @override
  Widget build(BuildContext context) {
    final isUrdu = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'جملے اور پیراگراف' : 'Sentences & paragraphs'),
      ),
      body: FutureBuilder<List<SentenceLearningItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppStateView(
              icon: Icons.error_outline,
              title: isUrdu ? 'مواد دستیاب نہیں' : 'Content unavailable',
              message: isUrdu
                  ? 'سبق لوڈ نہیں ہو سکا۔'
                  : 'Lessons could not be loaded.',
            );
          }
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final all = snapshot.data!;
          final visible = _selectedType == null
              ? all
              : all.where((item) => item.type == _selectedType).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: _allLessons,
                        label: Text(isUrdu ? 'سب' : 'All'),
                      ),
                      ButtonSegment(
                        value: LearningContentType.smallSentence.name,
                        label: Text(isUrdu ? 'آسان' : 'Small'),
                      ),
                      ButtonSegment(
                        value: LearningContentType.mediumSentence.name,
                        label: Text(isUrdu ? 'درمیانے' : 'Medium'),
                      ),
                      ButtonSegment(
                        value: LearningContentType.longSentence.name,
                        label: Text(isUrdu ? 'لمبے' : 'Long'),
                      ),
                      ButtonSegment(
                        value: LearningContentType.paragraph.name,
                        label: Text(isUrdu ? 'پیراگراف' : 'Paragraphs'),
                      ),
                    ],
                    selected: {_selectedType?.name ?? _allLessons},
                    onSelectionChanged: (selection) => setState(() {
                      _selectedType = selection.first == _allLessons
                          ? null
                          : LearningContentType.values.byName(selection.first);
                    }),
                  ),
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
                  itemBuilder: (context, index) => _LessonCard(
                    item: visible[index],
                    isUrdu: isUrdu,
                    onSpeak: () async {
                      if (widget.speechService != null) {
                        await _speech.speak(visible[index].ttsText);
                      } else {
                        final preferences = ref.read(preferencesProvider);
                        await DeviceSpeechService(
                          preferences: SpeechPreferences(
                            enabled: preferences.speechEnabled,
                            rate: preferences.speechRate,
                          ),
                        ).speak(visible[index].ttsText);
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.item,
    required this.isUrdu,
    required this.onSpeak,
  });

  final SentenceLearningItem item;
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
                  '${isUrdu ? 'سبق' : 'Lesson'} ${item.order}',
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
          const SizedBox(height: AppSpacing.small),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              item.english,
              textAlign: TextAlign.left,
              softWrap: true,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              item.urdu,
              textAlign: TextAlign.right,
              softWrap: true,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    ),
  );
}
