import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/question_entity.dart';
import 'tag_filter_bar.dart';

class HomeFeedFilterSection extends StatelessWidget {
  const HomeFeedFilterSection({
    super.key,
    required this.selectedCategoryId,
    required this.categories,
    required this.onCategorySelected,
  });

  final String? selectedCategoryId;
  final List<QuestionCategory> categories;
  final ValueChanged<QuestionCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final colors = context.dalleniColors;

    return SliverToBoxAdapter(
      child: Container(
        color: colors.surface,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CategoryFilterBar(
              selectedTagId: selectedCategoryId,
              tags: categories,
              onTagSelected: onCategorySelected,
            ),
          ],
        ),
      ),
    );
  }
}
