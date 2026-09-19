import 'package:dalleni/core/theme/dalleni_theme.dart';
import 'package:flutter/material.dart';

class QuestionComposer extends StatelessWidget {
  const QuestionComposer({
    required this.colors,
    required this.theme,
    required this.titleController,
    required this.descriptionController,
    required this.titleFocusNode,
    required this.descriptionFocusNode,
  });

  final DalleniColors colors;
  final ThemeData theme;

  final TextEditingController titleController;
  final TextEditingController descriptionController;

  final FocusNode titleFocusNode;
  final FocusNode descriptionFocusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.onSurface.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: titleController,
              focusNode: titleFocusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) {
                descriptionFocusNode.requestFocus();
              },
              decoration: InputDecoration(
                hintText: 'What would you like to ask?',
                border: InputBorder.none,
                hintStyle: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant.withOpacity(0.65),
                ),
              ),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ),

          Divider(height: 1, color: colors.onSurface.withOpacity(0.08)),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: descriptionController,
              focusNode: descriptionFocusNode,
              minLines: 4,
              maxLines: 7,
              decoration: InputDecoration(
                hintText: 'Add more details...',
                border: InputBorder.none,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
