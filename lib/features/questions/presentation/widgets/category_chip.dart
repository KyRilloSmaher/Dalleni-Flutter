
import 'package:dalleni/core/theme/dalleni_theme.dart';
import 'package:dalleni/features/questions/data/models/category_model.dart';
import 'package:dalleni/features/questions/domain/entities/question_entity.dart';
import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.category,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  final QuestionCategory category;
  final bool isSelected;
  final DalleniColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary
              : colors.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outlineVariant.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          category.name,
          style: TextStyle(
            color: isSelected
                ? colors.onPrimary
                : colors.onSurfaceVariant,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}