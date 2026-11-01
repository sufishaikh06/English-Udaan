import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart' show preferencesProvider, AppLanguage;
import '../../../shared/widgets/app_components.dart';

/// The Learn tab hub: displays all available learning sections as cards.
class LearningHubScreen extends ConsumerWidget {
  const LearningHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(preferencesProvider).language;
    final isUrdu = language == AppLanguage.urdu;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'سیکھیں' : 'Learn'),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            tooltip: isUrdu ? 'ترتیبات' : 'Settings',
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          // ── Intro banner ──────────────────────────────────────────
          _IntroCard(isUrdu: isUrdu),
          const SizedBox(height: AppSpacing.large),

          // ── Section header ────────────────────────────────────────
          AppSectionHeader(
            title: isUrdu ? 'سیکھنے کے موضوعات' : 'Learning topics',
          ),
          const SizedBox(height: AppSpacing.small),

          // ── 1. Alphabet ───────────────────────────────────────────
          LearningCard(
            title: isUrdu ? 'انگریزی حروف تہجی' : 'English Alphabet',
            subtitle: isUrdu
                ? 'A سے Z تک حروف اور تلفظ سیکھیں'
                : 'Learn letters A to Z with pronunciation',
            icon: Icons.text_fields_outlined,
            color: AppColors.primary,
            onTap: () => context.push('/learn/alphabet'),
          ),
          const SizedBox(height: AppSpacing.small),

          // ── 2. Vocabulary ─────────────────────────────────────────
          LearningCard(
            title: isUrdu ? 'الفاظ کا ذخیرہ' : 'Vocabulary',
            subtitle: isUrdu
                ? '2 سے 5 حرفی الفاظ، معنی اور مثالیں'
                : '2- to 5-letter words, meanings and examples',
            icon: Icons.translate_outlined,
            color: const Color(0xFF8A5CF6),
            onTap: () => context.push('/learn/vocabulary'),
          ),
          const SizedBox(height: AppSpacing.small),

          // ── 3. Picture Learning ───────────────────────────────────
          LearningCard(
            title: isUrdu ? 'تصویری سیکھنا' : 'Picture Learning',
            subtitle: isUrdu
                ? 'پھل، سبزیاں، جانور اور بہت کچھ'
                : 'Fruits, vegetables, animals and more',
            icon: Icons.image_outlined,
            color: const Color(0xFFF59E0B),
            onTap: () => context.push('/learn/pictures'),
          ),
          const SizedBox(height: AppSpacing.small),

          // ── 4. Sentences & Paragraphs ─────────────────────────────
          LearningCard(
            title: isUrdu ? 'جملے اور پیراگراف' : 'Sentences & Paragraphs',
            subtitle: isUrdu
                ? 'چھوٹے جملے، لمبے جملے اور پیراگراف'
                : 'Short sentences, long sentences and paragraphs',
            icon: Icons.subject_outlined,
            color: const Color(0xFF159A9C),
            onTap: () => context.push('/learn/sentences'),
          ),
          const SizedBox(height: AppSpacing.small),

          // ── 5. Grammar ────────────────────────────────────────────
          LearningCard(
            title: isUrdu ? 'انگریزی گرامر' : 'English Grammar',
            subtitle: isUrdu
                ? 'قواعد، مثالیں اور سطح بہ سطح سیکھنا'
                : 'Rules, examples and level-by-level learning',
            icon: Icons.rule_outlined,
            color: const Color(0xFF087B7D),
            onTap: () => context.push('/learn/grammar'),
          ),
          const SizedBox(height: AppSpacing.small),

          // ── 6. Dictionary ─────────────────────────────────────────
          LearningCard(
            title: isUrdu ? 'اردو-انگریزی لغت' : 'Urdu–English Dictionary',
            subtitle: isUrdu
                ? 'اردو یا انگریزی لفظ تلاش کریں — AI سے بھی'
                : 'Look up Urdu or English words — with AI fallback',
            icon: Icons.menu_book_outlined,
            color: const Color(0xFF2563EB),
            onTap: () => context.push('/learn/dictionary'),
          ),
          const SizedBox(height: AppSpacing.xLarge),
        ],
      ),
    );
  }
}

/// Bilingual intro banner shown at the top of the Learn Hub.
class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.isUrdu});

  final bool isUrdu;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: AppRadii.medium,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.18),
                borderRadius: AppRadii.small,
              ),
              child: const SizedBox(
                height: 52,
                width: 52,
                child: Icon(
                  Icons.school_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUrdu
                        ? 'انگریزی سیکھنے کا آسان راستہ'
                        : 'Your complete English learning journey',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(
                    isUrdu
                        ? 'حروف سے لے کر گرامر اور لغت تک — سب ایک جگہ'
                        : 'From alphabet to grammar and dictionary — all in one place',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
