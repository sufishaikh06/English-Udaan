import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart' show preferencesProvider;
import '../../../shared/widgets/app_components.dart';
import '../../progress/data/progress_repository.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/learning_repository.dart';
import '../domain/learning_models.dart';

final _repository = LearningRepository.bundled();

// ─────────────────────────────
// Alphabet overview  (Phase 6)
// ─────────────────────────────

class AlphabetScreen extends StatelessWidget {
  const AlphabetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isUrdu = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      appBar: AppBar(title: Text(isUrdu ? 'حروف تہجی' : 'English alphabet')),
      body: FutureBuilder<List<AlphabetItem>>(
        future: _repository.loadAlphabet(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AppStateView(
              icon: Icons.error_outline,
              title: 'Error',
              message: 'Content could not be loaded.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.medium),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                child: InkWell(
                  onTap: () => context.push('/learn/alphabet/${item.id}'),
                  borderRadius: AppRadii.medium,
                  child: Center(
                    child: Text(
                      item.letter,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────
// Letter detail  (Phase 6)
// ─────────────────────────────

class LetterDetailScreen extends ConsumerStatefulWidget {
  const LetterDetailScreen({super.key, required this.id, this.speechService});

  final String id;
  final SpeechService? speechService;

  @override
  ConsumerState<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends ConsumerState<LetterDetailScreen> {
  late final SpeechService _speech =
      widget.speechService ?? DeviceSpeechService();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AlphabetItem>>(
      future: _repository.loadAlphabet(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _ContentErrorScreen();
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final items = snapshot.data!;
        final index = items.indexWhere((item) => item.id == widget.id);
        if (index < 0) return const _UnknownLetterScreen();
        final item = items[index];
        final isUrdu = Directionality.of(context) == TextDirection.rtl;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              isUrdu ? 'حرف ${item.letter}' : 'Letter ${item.letter}',
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${item.letter} ${item.lowercase}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  item.englishExample,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  item.urduMeaning,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Center(
                  child: AudioButton(
                    label: isUrdu ? 'تلفظ سنیں' : 'Listen to pronunciation',
                    onPressed: () => _speak(item.ttsText, isUrdu),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: index == 0
                            ? null
                            : () => context.go(
                                '/learn/alphabet/${items[index - 1].id}',
                              ),
                        child: Text(isUrdu ? 'پچھلا' : 'Previous'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => index == items.length - 1
                            ? context.push('/learn/vocabulary')
                            : context.go(
                                '/learn/alphabet/${items[index + 1].id}',
                              ),
                        child: Text(
                          index == items.length - 1
                              ? (isUrdu
                                    ? 'الفاظ جاری رکھیں'
                                    : 'Continue with words')
                              : (isUrdu ? 'اگلا' : 'Next'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _speak(String text, bool isUrdu) async {
    try {
      setState(() => _error = null);
      if (widget.speechService != null) {
        await _speech.speak(text);
      } else {
        final preferences = ref.read(preferencesProvider);
        await DeviceSpeechService(
          preferences: SpeechPreferences(
            enabled: preferences.speechEnabled,
            rate: preferences.speechRate,
          ),
        ).speak(text);
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().contains('turned off')
              ? (isUrdu
                    ? 'تلفظ ترتیبات میں بند ہے۔'
                    : 'Pronunciation is turned off in settings.')
              : (isUrdu
                    ? 'اس آلے پر انگریزی آواز دستیاب نہیں ہے۔'
                    : 'An English voice is unavailable on this device.'),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────
// Vocabulary list with sections & search (Phase 7)
// ─────────────────────────────────────────────────

class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({
    super.key,
    this.speechService,
    this.initialWordLength = 2,
  });

  final SpeechService? speechService;
  final int initialWordLength;

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  late final SpeechService _speech =
      widget.speechService ?? DeviceSpeechService();
  late int _selectedWordLength = widget.initialWordLength;
  late Future<List<VocabularyItem>> _vocabularyFuture = _repository
      .loadVocabulary(wordLength: _selectedWordLength);
  String _query = '';
  bool _complete = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkCompletion(_selectedWordLength);
  }

  void _onWordLengthChanged(int newLength) {
    if (newLength == _selectedWordLength) return;
    setState(() {
      _selectedWordLength = newLength;
      _query = '';
      _error = null;
      _vocabularyFuture = _repository.loadVocabulary(wordLength: newLength);
    });
    _checkCompletion(newLength);
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = Directionality.of(context) == TextDirection.rtl;
    final screenTitle = _selectedWordLength == 2
        ? (isUrdu ? 'دو حرفی الفاظ' : 'Two-letter words')
        : _selectedWordLength == 3
        ? (isUrdu ? 'تین حرفی الفاظ' : 'Three-letter words')
        : _selectedWordLength == 4
        ? (isUrdu ? 'چار حرفی الفاظ' : 'Four-letter words')
        : (isUrdu ? 'پانچ حرفی الفاظ' : 'Five-letter words');

    return Scaffold(
      appBar: AppBar(title: Text(screenTitle)),
      body: FutureBuilder<List<VocabularyItem>>(
        future: _vocabularyFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AppStateView(
              icon: Icons.error_outline,
              title: 'Error',
              message: 'Content could not be loaded.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;
          final filtered = all.where((item) => item.matches(_query)).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  AppSpacing.medium,
                  AppSpacing.medium,
                  AppSpacing.small,
                ),
                child: SegmentedButton<int>(
                  segments: [
                    ButtonSegment<int>(
                      value: 2,
                      label: Text(isUrdu ? '۲' : '2'),
                    ),
                    ButtonSegment<int>(
                      value: 3,
                      label: Text(isUrdu ? '۳' : '3'),
                    ),
                    ButtonSegment<int>(
                      value: 4,
                      label: Text(isUrdu ? '۴' : '4'),
                    ),
                    ButtonSegment<int>(
                      value: 5,
                      label: Text(isUrdu ? '۵' : '5'),
                    ),
                  ],
                  selected: {_selectedWordLength},
                  onSelectionChanged: (selected) {
                    if (selected.isNotEmpty) {
                      _onWordLengthChanged(selected.first);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium,
                ),
                child: AppSearchField(
                  hintText: isUrdu ? 'لفظ تلاش کریں' : 'Search words',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium,
                ),
                child: Row(
                  children: [
                    Text(
                      isUrdu ? '${all.length} الفاظ' : '${all.length} words',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedLight,
                      ),
                    ),
                    if (_query.isNotEmpty)
                      Text(
                        isUrdu
                            ? ' — ${filtered.length} نتائج'
                            : ' — ${filtered.length} results',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedLight,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Expanded(
                child: filtered.isEmpty
                    ? AppStateView(
                        icon: Icons.search_off,
                        title: isUrdu ? 'کوئی نتیجہ نہیں' : 'No results',
                        message: isUrdu
                            ? '"$_query" کے لیے کوئی لفظ نہیں ملا۔'
                            : 'No word found for "$_query".',
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.medium,
                        ),
                        children: [
                          for (final item in filtered)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.small,
                              ),
                              child: LearningCard(
                                title: item.word,
                                subtitle:
                                    '${item.urduMeaning} — ${item.example}',
                                icon: Icons.translate_outlined,
                                color: AppColors.primary,
                                trailing: AudioButton(
                                  label: 'Listen to ${item.word}',
                                  onPressed: () => _speak(item.ttsText, isUrdu),
                                ),
                              ),
                            ),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.small,
                              ),
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          if (_query.isEmpty) ...[
                            const SizedBox(height: AppSpacing.medium),
                            ElevatedButton(
                              onPressed: _complete ? null : _completeLesson,
                              child: Text(
                                _complete
                                    ? (isUrdu
                                          ? 'سبق مکمل ہو گیا'
                                          : 'Lesson completed')
                                    : (isUrdu
                                          ? 'سبق مکمل کریں'
                                          : 'Complete lesson'),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.large),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _speak(String text, bool isUrdu) async {
    try {
      if (widget.speechService != null) {
        await _speech.speak(text);
      } else {
        final preferences = ref.read(preferencesProvider);
        await DeviceSpeechService(
          preferences: SpeechPreferences(
            enabled: preferences.speechEnabled,
            rate: preferences.speechRate,
          ),
        ).speak(text);
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().contains('turned off')
              ? (isUrdu
                    ? 'تلفظ ترتیبات میں بند ہے۔'
                    : 'Pronunciation is turned off in settings.')
              : (isUrdu
                    ? 'اس آلے پر انگریزی آواز دستیاب نہیں ہے۔'
                    : 'Speech is unavailable on this device.'),
        );
      }
    }
  }

  Future<void> _checkCompletion(int wordLength) async {
    final summary = await ProgressRepository().loadSummary();
    final done = summary.sections
        .firstWhere(
          (s) =>
              s.wordCount != null &&
              s.id ==
                  'vocabulary-${['two', 'three', 'four', 'five'][wordLength - 2]}',
        )
        .completed;
    if (mounted) setState(() => _complete = done);
  }

  Future<void> _completeLesson() async {
    final repository = ProgressRepository();
    final id =
        'vocabulary-${['two', 'three', 'four', 'five'][_selectedWordLength - 2]}';
    await repository.markSectionCompleted(id);
    await repository.recordStudyActivity();
    if (mounted) {
      await ref
          .read(cloudProgressServiceProvider)
          .syncToCloud()
          .catchError((_) {});
    }
    if (mounted) setState(() => _complete = true);
  }
}

// ─────────────────────────────
// Private error helpers
// ─────────────────────────────

class _ContentErrorScreen extends StatelessWidget {
  const _ContentErrorScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: AppStateView(
      icon: Icons.error_outline,
      title: 'Error',
      message: 'Content could not be loaded.',
    ),
  );
}

class _UnknownLetterScreen extends StatelessWidget {
  const _UnknownLetterScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: AppStateView(
      icon: Icons.search_off,
      title: 'Not found',
      message: 'This letter does not exist.',
    ),
  );
}
