import 'package:dalleni/core/localization/app_localizations.dart';
import 'package:dalleni/core/theme/dalleni_theme.dart';
import 'package:dalleni/features/questions/domain/entities/question_entity.dart';
import 'package:flutter/material.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    required this.selectedTagId,
    required this.tags,
    required this.onTagSelected,
  });

  final String? selectedTagId;
  final List<QuestionCategory> tags;
  final ValueChanged<QuestionCategory?> onTagSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isAllOption = index == 0;
          final isSelected = isAllOption
              ? selectedTagId == null
              : tags[index - 1].id == selectedTagId;
          final label = isAllOption
              ? context.l10n.translate('homeAllTags')
              : tags[index - 1].name;

          return ChoiceChip(
            selected: isSelected,
            label: Text(label),
            onSelected: (_) =>
                onTagSelected(isAllOption ? null : tags[index - 1]),
            selectedColor: colors.primaryContainer,
            backgroundColor: colors.surfaceContainerHigh,
            side: BorderSide(
              color: isSelected ? colors.primary : colors.outlineVariant,
            ),
            labelStyle: textTheme.labelLarge?.copyWith(
              color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }
}
