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

class PictureCategoriesScreen extends StatelessWidget {
  const PictureCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isUrdu = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'تصاویر سے سیکھیں' : 'Learn with pictures'),
      ),
      body: FutureBuilder<List<PictureCategory>>(
        future: _repository.loadPictureCategories(),
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
          final categories = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.medium),
            itemCount: categories.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.small),
            itemBuilder: (context, index) {
              final category = categories[index];
              final title = isUrdu ? category.titleUrdu : category.titleEnglish;
              final countText = isUrdu
                  ? '${category.itemCount} تصاویر'
                  : '${category.itemCount} pictures';

              return Card(
                child: InkWell(
                  onTap: () => context.push('/learn/pictures/${category.id}'),
                  borderRadius: AppRadii.medium,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    child: Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: AppRadii.small,
                          ),
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: Icon(
                              _getIconForName(category.iconName),
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: AppSpacing.xSmall),
                              Text(
                                countText,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.mutedLight),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
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

  IconData _getIconForName(String name) {
    switch (name) {
      case 'apple':
        return Icons.apple;
      case 'eco':
        return Icons.eco_outlined;
      case 'pets':
        return Icons.pets;
      case 'cruelty_free':
        return Icons.cruelty_free;
      case 'flutter_dash':
        return Icons.flutter_dash;
      case 'directions_car':
        return Icons.directions_car_outlined;
      case 'face':
        return Icons.face_outlined;
      case 'chair':
        return Icons.chair_alt_outlined;
      case 'park':
        return Icons.park_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}

class PictureItemsScreen extends ConsumerStatefulWidget {
  const PictureItemsScreen({
    super.key,
    required this.categoryId,
    this.speechService,
  });

  final String categoryId;
  final SpeechService? speechService;

  @override
  ConsumerState<PictureItemsScreen> createState() => _PictureItemsScreenState();
}

class _PictureItemsScreenState extends ConsumerState<PictureItemsScreen> {
  late final SpeechService _speech =
      widget.speechService ?? DeviceSpeechService();
  late final Future<List<PictureItem>> _itemsFuture = _repository
      .loadPictureItems(categoryId: widget.categoryId);
  late final Future<List<PictureCategory>> _categoriesFuture = _repository
      .loadPictureCategories();

  String _query = '';
  bool _complete = false;

  @override
  void initState() {
    super.initState();
    _checkCompletion();
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = Directionality.of(context) == TextDirection.rtl;

    return FutureBuilder<List<PictureCategory>>(
      future: _categoriesFuture,
      builder: (context, catSnapshot) {
        if (!catSnapshot.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        final category = catSnapshot.data!.cast<PictureCategory?>().firstWhere(
          (c) => c?.id == widget.categoryId,
          orElse: () => null,
        );
        if (category == null) {
          return const Scaffold(
            body: AppStateView(
              icon: Icons.search_off,
              title: 'Not found',
              message: 'This category does not exist.',
            ),
          );
        }

        final title = isUrdu ? category.titleUrdu : category.titleEnglish;

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: FutureBuilder<List<PictureItem>>(
            future: _itemsFuture,
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
              final filtered = all
                  .where((item) => item.matches(_query))
                  .toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.medium,
                      AppSpacing.medium,
                      AppSpacing.medium,
                      AppSpacing.small,
                    ),
                    child: AppSearchField(
                      hintText: isUrdu ? 'تلاش کریں' : 'Search',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? AppStateView(
                            icon: Icons.search_off,
                            title: isUrdu ? 'کوئی نتیجہ نہیں' : 'No results',
                            message: isUrdu
                                ? '"$_query" کے لیے کوئی تصویر نہیں ملی۔'
                                : 'No picture found for "$_query".',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.medium,
                              vertical: AppSpacing.small,
                            ),
                            itemCount: filtered.length + 1,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSpacing.small),
                            itemBuilder: (context, index) {
                              if (index == filtered.length) {
                                if (_query.isNotEmpty)
                                  return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.large,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _complete
                                        ? null
                                        : _completeLesson,
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
                                );
                              }

                              final item = filtered[index];
                              return PictureItemCard(
                                item: item,
                                onSpeak: () => _speak(item.ttsText),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _speak(String text) async {
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
    } catch (_) {
      // TTS errors not surfaced in UI as per Phase 3 requirement
    }
  }

  Future<void> _checkCompletion() async {
    final summary = await ProgressRepository().loadSummary();
    final done = summary.sections
        .firstWhere((s) => s.id == 'pictures-${widget.categoryId}')
        .completed;
    if (mounted) setState(() => _complete = done);
  }

  Future<void> _completeLesson() async {
    final repository = ProgressRepository();
    await repository.markSectionCompleted('pictures-${widget.categoryId}');
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

class PictureItemCard extends StatelessWidget {
  const PictureItemCard({super.key, required this.item, required this.onSpeak});

  final PictureItem item;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.medium,
        side: BorderSide(color: AppColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: _buildImage(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.english,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xSmall),
                      Text(
                        item.urdu,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (item.example != null) ...[
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          item.example!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.mutedLight),
                        ),
                      ],
                    ],
                  ),
                ),
                AudioButton(
                  label: 'Listen to ${item.english}',
                  onPressed: onSpeak,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (item.imageSourceType == ImageSourceType.localAsset &&
        item.localAssetPath != null) {
      return Image.asset(
        item.localAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    } else if (item.imageSourceType == ImageSourceType.remoteUrl &&
        item.remoteUrl != null) {
      return Image.network(
        item.remoteUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: AppColors.primarySoft,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: AppColors.primary),
      ),
    );
  }
}
