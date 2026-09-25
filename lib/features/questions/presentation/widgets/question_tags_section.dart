import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/question_entity.dart';

class QuestionTagsSection extends StatelessWidget {
  const QuestionTagsSection({
    super.key,
    this.categoryId,
    this.categoryName,
    required this.tags,
    this.onCategoryTap,
    this.onTagTap,
  });

  final String? categoryId;
  final String? categoryName;
  final List<QuestionTag> tags;
  final VoidCallback? onCategoryTap;
  final ValueChanged<QuestionTag>? onTagTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final textTheme = Theme.of(context).textTheme;

    final hasCategory = categoryId != null && categoryName != null;

    if (!hasCategory && tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasCategory) ...[
          const SizedBox(height: 14),
          ActionChip(
            backgroundColor: colors.surfaceContainerHigh,
            side: BorderSide.none,
            label: Text(categoryName!),
            labelStyle: textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
            onPressed: onCategoryTap,
          ),
        ],
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags
                .map(
                  (tag) => ActionChip(
                    backgroundColor: colors.surfaceContainerHigh,
                    side: BorderSide.none,
                    label: Text('#${tag.name}'),
                    labelStyle: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: onTagTap == null ? null : () => onTagTap!(tag),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ],
    );
  }
}
