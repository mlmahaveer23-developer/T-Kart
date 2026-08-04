import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/category.dart';
import 'category_icon_mapper.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
    this.category,
  });

  /// Null represents the "All" chip.
  final Category? category;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        avatar: Icon(
          category == null ? Icons.apps_rounded : categoryIcon(category!.iconKey),
          size: 16,
          color: selected ? scheme.onPrimary : scheme.primary,
        ),
        label: Text(label),
        selectedColor: scheme.primary,
        labelStyle: TextStyle(
          color: selected ? scheme.onPrimary : scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: scheme.surfaceContainerHighest,
        showCheckmark: false,
        side: BorderSide.none,
      ),
    );
  }
}
