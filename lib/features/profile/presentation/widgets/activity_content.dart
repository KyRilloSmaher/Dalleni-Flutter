import 'package:dalleni/features/questions/domain/entities/question_entity.dart';
import 'package:flutter/material.dart';

class ActivityContent extends StatelessWidget {
  const ActivityContent({required this.question, required this.colors});

  final Question question;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.categoryName != null &&
            question.categoryName!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CategoryChip(
              label: question.categoryName!,
              colors: colors,
            ),
          ),

        Text(
          question.body,
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.55,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }



}



class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.colors,
  });

  final String label;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}