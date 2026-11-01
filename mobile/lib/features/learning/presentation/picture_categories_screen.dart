import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/learning_models.dart';

class PictureCategoryListScreen extends StatelessWidget {
  const PictureCategoryListScreen({super.key, required this.categories});

  final List<PictureCategory> categories;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.small),
      itemBuilder: (context, index) {
        final category = categories[index];
        return PictureCategoryCard(category: category);
      },
    );
  }
}

class PictureCategoryCard extends StatelessWidget {
  const PictureCategoryCard({super.key, required this.category});

  final PictureCategory category;

  IconData _getIconData(String name) {
    // Map minimal icon names from JSON to actual Icons
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

  @override
  Widget build(BuildContext context) {
    final isUrdu = Directionality.of(context) == TextDirection.rtl;
    final title = isUrdu ? category.titleUrdu : category.titleEnglish;
    final countText = isUrdu
        ? '${category.itemCount} تصاویر'
        : '${category.itemCount} pictures';

    return Card(
      child: InkWell(
        onTap: () {
          // Navigating to detail
        },
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
                    _getIconData(category.iconName),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xSmall),
                    Text(
                      countText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedLight,
                      ),
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
  }
}
