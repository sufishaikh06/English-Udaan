import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../../shared/widgets/app_components.dart';
import '../../practice/domain/practice_models.dart';
import '../data/progress_repository.dart';
import '../domain/progress_models.dart';

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(),
);

final progressSummaryProvider = FutureProvider<ProgressSummary>((ref) {
  return ref.watch(progressRepositoryProvider).loadSummary();
});

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.invalidate(progressSummaryProvider));
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(preferencesProvider).language;
    final isUrdu = language == AppLanguage.urdu;
    final summary = ref.watch(progressSummaryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(isUrdu ? 'پیش رفت' : 'Progress')),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => AppStateView(
          icon: Icons.error_outline,
          title: isUrdu ? 'پیش رفت نہیں کھل سکی' : 'Progress unavailable',
          message: isUrdu
              ? 'مقامی ریکارڈ اس وقت نہیں پڑھے جا سکے۔'
              : 'Local progress could not be read.',
        ),
        data: (data) => _ProgressBody(summary: data, isUrdu: isUrdu),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.summary, required this.isUrdu});

  final ProgressSummary summary;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    final empty = summary.sectionsCompleted == 0 && summary.quizzesRecorded == 0;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        _SyncStatusCard(summary: summary, isUrdu: isUrdu),
        const SizedBox(height: AppSpacing.small),
        if (empty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Text(
                isUrdu
                    ? 'ابھی کوئی سبق مکمل نہیں ہوا۔ الفاظ یا تصاویر کا سبق مکمل کریں، یا کوئز حل کریں۔'
                    : 'No lessons are complete yet. Finish a word or picture lesson, or take a quiz.',
              ),
            ),
          ),
        _SummaryCard(summary: summary, isUrdu: isUrdu),
        const SizedBox(height: AppSpacing.large),
        AppSectionHeader(title: isUrdu ? 'مکمل حصے' : 'Completed sections'),
        const SizedBox(height: AppSpacing.small),
        for (final section in summary.sections)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              section.completed
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: section.completed
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            title: Text(isUrdu ? section.labelUrdu : section.labelEnglish),
            subtitle: section.wordCount == null
                ? null
                : Text(
                    isUrdu
                        ? '${section.wordCount} الفاظ اس حصے میں'
                        : '${section.wordCount} words in this section',
                  ),
            trailing: Text(
              section.completed
                  ? (isUrdu ? 'مکمل' : 'Done')
                  : (isUrdu ? 'باقی' : 'Not yet'),
            ),
          ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          isUrdu
              ? 'الفاظ کی گنتی صرف مکمل حصے کے الفاظ دکھاتی ہے۔ ہر لفظ الگ سے ریکارڈ نہیں ہوتا۔ حروف، جملے اور گرامر کی تکمیل ابھی محفوظ نہیں۔'
              : 'Word count is the size of a completed vocabulary section, not individual word mastery. Alphabet, sentences, and grammar do not store completion yet.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.large),
        AppSectionHeader(title: isUrdu ? 'کوئز کے نتائج' : 'Quiz results'),
        const SizedBox(height: AppSpacing.small),
        if (summary.quizResults.isEmpty)
          Text(
            isUrdu
                ? 'ابھی کوئی کوئز نتیجہ محفوظ نہیں۔'
                : 'No quiz results are saved yet.',
          )
        else
          for (final result in summary.quizResults)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_quizLabel(result.category, isUrdu)),
              subtitle: Text(
                isUrdu
                    ? 'تازہ ترین نتیجہ، مکمل تاریخ نہیں'
                    : 'Latest result only, not full history',
              ),
              trailing: Text(
                result.accuracyPercent == null
                    ? '${result.score}/${result.total}'
                    : '${result.score}/${result.total} · ${result.accuracyPercent}%',
              ),
            ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          isUrdu
              ? 'درستگی تازہ ترین نتائج کے سوالات پر مبنی ہے۔ پرانے کوئز محفوظ نہیں۔'
              : 'Accuracy uses questions in the latest saved result for each category. Older quizzes are not stored.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _quizLabel(String category, bool isUrdu) {
    final match = PracticeCategory.values.where((item) => item.name == category);
    if (match.isEmpty) return category;
    return isUrdu ? match.first.titleUrdu() : match.first.titleEnglish();
  }
}

class _SyncStatusCard extends StatelessWidget {
  const _SyncStatusCard({required this.summary, required this.isUrdu});

  final ProgressSummary summary;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    final label = switch (summary.syncState) {
      SyncState.localOnly => isUrdu ? 'صرف اس آلے پر' : 'Local only',
      SyncState.pending => isUrdu ? 'محفوظ ہو رہا ہے' : 'Syncing',
      SyncState.synced => isUrdu ? 'کلاؤڈ میں محفوظ' : 'Synced',
      SyncState.failed => isUrdu ? 'ہم وقت سازی ناکام' : 'Sync failed',
    };
    final icon = switch (summary.syncState) {
      SyncState.localOnly => Icons.phone_android,
      SyncState.pending => Icons.sync,
      SyncState.synced => Icons.cloud_done,
      SyncState.failed => Icons.cloud_off,
    };
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(isUrdu ? 'پیش رفت کی حالت' : 'Progress sync'),
        subtitle: Text(label),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.isUrdu});

  final ProgressSummary summary;
  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    final percent = summary.overallPercent;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: percent == null ? 0 : percent / 100,
                    strokeWidth: 7,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Text(
                    percent == null
                        ? (isUrdu ? 'ابھی کوئی حصہ نہیں' : 'No sections yet')
                        : isUrdu
                        ? '$percent% حصے مکمل'
                        : '$percent% of sections complete',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            _Metric(
              label: isUrdu ? 'مکمل حصے' : 'Sections complete',
              value: '${summary.sectionsCompleted}/${summary.sectionsTotal}',
            ),
            _Metric(
              label: isUrdu ? 'مکمل حصوں کے الفاظ' : 'Words in completed sections',
              value: '${summary.wordsInCompletedSections}',
            ),
            _Metric(
              label: isUrdu ? 'کوئز درستگی' : 'Quiz accuracy',
              value: summary.accuracyPercent == null
                  ? (isUrdu ? 'ابھی نہیں' : 'Not yet')
                  : '${summary.accuracyPercent}%',
            ),
            _Metric(
              label: isUrdu ? 'موجودہ سلسلہ' : 'Current streak',
              value: isUrdu
                  ? '${summary.currentStreak} دن'
                  : '${summary.currentStreak} days',
            ),
            _Metric(
              label: isUrdu ? 'طویل ترین سلسلہ' : 'Longest streak',
              value: isUrdu
                  ? '${summary.longestStreak} دن'
                  : '${summary.longestStreak} days',
            ),
            _Metric(
              label: isUrdu ? 'محفوظ حالت' : 'Saved on device',
              value: switch (summary.syncState) {
                SyncState.synced => isUrdu ? 'کلاؤڈ میں محفوظ' : 'Cloud synced',
                SyncState.pending => isUrdu ? 'محفوظ ہو رہا ہے' : 'Syncing',
                SyncState.failed => isUrdu ? 'ہم وقت سازی ناکام' : 'Sync failed',
                SyncState.localOnly => isUrdu ? 'صرف اس آلے پر' : 'This device only',
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
