import 'package:dalleni/features/questions/domain/entities/question_entity.dart';
import 'package:dalleni/features/questions/presentation/widgets/category_chip.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../data/models/category_model.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.colors,
    required this.onCategorySelected,
  });

  final List<QuestionCategory> categories;
  final String? selectedCategoryId;
  final DalleniColors colors;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (int index = 0; index < categories.length; index++)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: CategoryChip(
                category: categories[index],
                isSelected: _isSelected(categories[index], index),
                colors: colors,
                onTap: () =>
                    onCategorySelected(categories[index].id),
              ),
            ),
        ],
      ),
    );
  }

  bool _isSelected(QuestionCategory category, int index) {
    return selectedCategoryId == category.id ||
        (selectedCategoryId == null && index == 0);
  }
}
