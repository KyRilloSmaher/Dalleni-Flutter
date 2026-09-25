import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/question_entity.dart';
import 'ask_header.dart';
import 'ask_question_submit_button.dart';
import 'category_selector.dart';
import 'question_composer.dart';
import 'section_title.dart';

class AskQuestionFormWidget extends StatelessWidget {
  const AskQuestionFormWidget({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.isSubmitting,
    required this.titleController,
    required this.descriptionController,
    required this.titleFocusNode,
    required this.descriptionFocusNode,
    required this.onCategorySelected,
    required this.onSubmit,
  });

  final List<QuestionCategory> categories;
  final String? selectedCategoryId;
  final bool isSubmitting;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final FocusNode titleFocusNode;
  final FocusNode descriptionFocusNode;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AskHeader(colors: colors, theme: theme),
            const SizedBox(height: 10),
            SectionTitle(title: 'Category', colors: colors),
            const SizedBox(height: 10),
            CategorySelector(
              categories: categories,
              selectedCategoryId: selectedCategoryId,
              colors: colors,
              onCategorySelected: onCategorySelected,
            ),
            const SizedBox(height: 20),
            QuestionComposer(
              colors: colors,
              theme: theme,
              titleController: titleController,
              descriptionController: descriptionController,
              titleFocusNode: titleFocusNode,
              descriptionFocusNode: descriptionFocusNode,
            ),
            const SizedBox(height: 20),
            AskQuestionSubmitButton(
              isSubmitting: isSubmitting,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
