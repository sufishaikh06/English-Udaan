import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart' show preferencesProvider, AppLanguage;
import '../../../shared/widgets/app_components.dart';
import '../data/dictionary_repository.dart';
import '../domain/dictionary_models.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _selectedSource = 'ur'; // 'ur' or 'en'

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    _focusNode.unfocus();
    ref
        .read(dictionaryProvider.notifier)
        .lookup(query, sourceLanguage: _selectedSource);
  }

  void _clear() {
    _controller.clear();
    ref.read(dictionaryProvider.notifier).clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(preferencesProvider).language;
    final isUrdu = language == AppLanguage.urdu;
    final lookupState = ref.watch(dictionaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'اردو-انگریزی لغت' : 'Urdu–English Dictionary'),
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────
          _SearchPanel(
            controller: _controller,
            focusNode: _focusNode,
            isUrdu: isUrdu,
            selectedSource: _selectedSource,
            onSourceChanged: (v) => setState(() => _selectedSource = v),
            onSubmit: _submit,
            onClear: _clear,
          ),
          // ── Content ────────────────────────────────────────────
          Expanded(
            child: switch (lookupState) {
              DictionaryIdle() => _IdleView(isUrdu: isUrdu),
              DictionaryLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              DictionarySuccess(:final result) => _ResultView(
                result: result,
                isUrdu: isUrdu,
              ),
              DictionaryEmpty(:final query) => _EmptyView(
                query: query,
                isUrdu: isUrdu,
              ),
              DictionaryError(
                :final message,
                :final isOffline,
                :final aiUnavailable,
              ) =>
                _ErrorView(
                  message: message,
                  isOffline: isOffline,
                  aiUnavailable: aiUnavailable,
                  isUrdu: isUrdu,
                  onRetry: _submit,
                ),
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Search panel ────────────────────────────────────────────

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.controller,
    required this.focusNode,
    required this.isUrdu,
    required this.selectedSource,
    required this.onSourceChanged,
    required this.onSubmit,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isUrdu;
  final String selectedSource;
  final ValueChanged<String> onSourceChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.medium,
          AppSpacing.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Source language toggle
            Row(
              children: [
                Text(
                  isUrdu ? 'تلاش کی زبان:' : 'Search in:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: AppSpacing.small),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'ur',
                      label: Text(isUrdu ? 'اردو' : 'Urdu'),
                    ),
                    ButtonSegment(
                      value: 'en',
                      label: Text(isUrdu ? 'انگریزی' : 'English'),
                    ),
                  ],
                  selected: {selectedSource},
                  onSelectionChanged: (s) => onSourceChanged(s.first),
                  style: ButtonStyle(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            // Query field + buttons
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSubmit(),
                    textDirection: selectedSource == 'ur'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: selectedSource == 'ur'
                          ? (isUrdu ? 'اردو لفظ لکھیں' : 'Type an Urdu word…')
                          : (isUrdu
                                ? 'انگریزی لفظ لکھیں'
                                : 'Type an English word…'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: ListenableBuilder(
                        listenable: controller,
                        builder: (context, _) => controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                tooltip: isUrdu ? 'صاف کریں' : 'Clear',
                                onPressed: onClear,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                FilledButton(
                  onPressed: onSubmit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(52, 52),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────── Idle state ───────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  const _IdleView({required this.isUrdu});
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.menu_book_outlined,
      title: isUrdu ? 'لغت میں تلاش کریں' : 'Search the dictionary',
      message: isUrdu
          ? 'اردو یا انگریزی لفظ لکھ کر تلاش کریں۔\nAI خودکار ترجمہ فراہم کرے گا۔'
          : 'Type a word above to look it up.\nDatabase results appear instantly; rare words use AI.',
    );
  }
}

// ─────────────────── Empty state ─────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.query, required this.isUrdu});
  final String query;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.search_off_outlined,
      title: isUrdu ? 'کوئی نتیجہ نہیں' : 'No result found',
      message: isUrdu
          ? '"$query" کا نتیجہ نہیں ملا۔ ہجے جانچیں یا دوسرا لفظ آزمائیں۔'
          : '"$query" was not found. Check the spelling or try another word.',
    );
  }
}

// ─────────────────── Error state ─────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.isOffline,
    required this.aiUnavailable,
    required this.isUrdu,
    required this.onRetry,
  });

  final String message;
  final bool isOffline;
  final bool aiUnavailable;
  final bool isUrdu;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final icon = isOffline
        ? Icons.wifi_off_outlined
        : aiUnavailable
        ? Icons.psychology_outlined
        : Icons.error_outline;

    return AppStateView(
      icon: icon,
      title: isOffline
          ? (isUrdu ? 'آف لائن' : 'Offline')
          : aiUnavailable
          ? (isUrdu ? 'AI دستیاب نہیں' : 'AI unavailable')
          : (isUrdu ? 'ایک مسئلہ ہوا' : 'Something went wrong'),
      message: message,
      actionLabel: isOffline ? (isUrdu ? 'دوبارہ کوشش کریں' : 'Retry') : null,
      onAction: isOffline ? onRetry : null,
    );
  }
}

// ─────────────────── Result view ─────────────────────────────────────────────

class _ResultView extends ConsumerWidget {
  const _ResultView({required this.result, required this.isUrdu});
  final DictionaryResult result;
  final bool isUrdu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Source badge ───────────────────────────────────────
          _SourceBadge(source: result.source, isUrdu: isUrdu),
          const SizedBox(height: AppSpacing.medium),

          // ── English word + TTS ─────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.englishWord,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                        if (result.partOfSpeech.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(
                            result.partOfSpeech,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ],
                    ),
                  ),
                  _TtsButton(text: result.ttsText, isUrdu: isUrdu),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.small),

          // ── Urdu meaning ───────────────────────────────────────
          _SectionCard(
            label: isUrdu ? 'اردو معنی' : 'Urdu meaning',
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  result.urduMeaning,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.small),

          // ── Simple definition ──────────────────────────────────
          if (result.simpleDefinition.isNotEmpty) ...[
            _SectionCard(
              label: isUrdu ? 'سادہ وضاحت' : 'Simple definition',
              child: Text(
                result.simpleDefinition,
                style: theme.textTheme.bodyMedium,
                textDirection: TextDirection.ltr,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
          ],

          // ── Example sentences ──────────────────────────────────
          if (result.examples.isNotEmpty) ...[
            _SectionCard(
              label: isUrdu ? 'مثالیں' : 'Example sentences',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < result.examples.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: AppSpacing.medium * 2,
                        color: colorScheme.outlineVariant,
                      ),
                    _ExampleTile(
                      example: result.examples[i],
                      number: i + 1,
                      isUrdu: isUrdu,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source, required this.isUrdu});
  final DictionaryResultSource source;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    final isDb = source == DictionaryResultSource.database;
    final color = isDb ? AppColors.primary : const Color(0xFF8A5CF6);
    final icon = isDb ? Icons.storage_outlined : Icons.psychology_outlined;
    final label = isDb
        ? (isUrdu ? 'ڈیٹابیس سے' : 'From database')
        : (isUrdu ? 'AI نے تیار کیا' : 'AI-generated');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadii.pill,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.small,
              vertical: AppSpacing.xSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: AppSpacing.xSmall),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            child,
          ],
        ),
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({
    required this.example,
    required this.number,
    required this.isUrdu,
  });

  final DictionaryExample example;
  final int number;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // English sentence LTR
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$number. ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: Text(
                example.english,
                style: theme.textTheme.bodyMedium,
                textDirection: TextDirection.ltr,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xSmall),
        // Urdu translation RTL
        Directionality(
          textDirection: TextDirection.rtl,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              example.urdu,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────── TTS button ───────────────────────────────────────────────

class _TtsButton extends ConsumerStatefulWidget {
  const _TtsButton({required this.text, required this.isUrdu});
  final String text;
  final bool isUrdu;

  @override
  ConsumerState<_TtsButton> createState() => _TtsButtonState();
}

class _TtsButtonState extends ConsumerState<_TtsButton> {
  bool _speaking = false;
  String? _error;

  Future<void> _speak() async {
    setState(() {
      _speaking = true;
      _error = null;
    });
    try {
      await DeviceSpeechService().speak(widget.text);
    } on StateError catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'TTS unavailable');
    } finally {
      if (mounted) setState(() => _speaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AudioButton(
          label: widget.isUrdu ? 'تلفظ سنیں' : 'Hear pronunciation',
          onPressed: _speaking ? null : _speak,
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xSmall),
            child: Text(
              _error!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
