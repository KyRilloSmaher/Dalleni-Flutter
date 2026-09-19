import 'package:dalleni/features/questions/presentation/widgets/ask_header.dart';
import 'package:dalleni/features/questions/presentation/widgets/question_composer.dart';
import 'package:dalleni/features/questions/presentation/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../providers/ask_question_controller.dart';
import '../widgets/category_selector.dart';

class AskQuestionScreen extends ConsumerStatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  ConsumerState<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends ConsumerState<AskQuestionScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  String? _selectedCategoryId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _submitQuestion() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showError(
        context.l10n.translate('askErrorNoTitle') ?? 'Please enter a question',
      );
      return;
    }

    final state = ref.read(askQuestionControllerProvider);

    final categoryId =
        _selectedCategoryId ??
        (state.categories.isNotEmpty ? state.categories.first.id : '');

    ref
        .read(askQuestionControllerProvider.notifier)
        .submitQuestion(
          title: title,
          content: _descriptionController.text.trim(),
          categoryId: categoryId,
          tags: const [],
        );
  }

  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final state = ref.watch(askQuestionControllerProvider);

    ref.listen(askQuestionControllerProvider, (previous, next) {
      if (next.isSuccess) {
        _showSuccess(l10n.translate('askSuccessMessage') ?? 'Question posted');

        _titleController.clear();
        _descriptionController.clear();

        ref.read(askQuestionControllerProvider.notifier).resetSuccess();
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        _showError(next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      drawer: const AnimatedFunkyDrawer(),
      appBar: CommonGlassAppBar(title: l10n.translate('navAsk') ?? 'Ask'),
      body: state.isLoading
          ? const AppLoadingState()
          : SafeArea(
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
                      categories: state.categories,
                      selectedCategoryId: _selectedCategoryId,
                      colors: colors,
                      onCategorySelected: _selectCategory,
                    ),

                    const SizedBox(height: 20),

                    QuestionComposer(
                      colors: colors,
                      theme: theme,
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      titleFocusNode: _titleFocusNode,
                      descriptionFocusNode: _descriptionFocusNode,
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppButton(
                        label: state.isSubmitting
                            ? l10n.translate('askSubmitting') ?? 'Posting...'
                            : l10n.translate('askSubmitButton') ??
                                  'Ask Question',
                        isLoading: state.isSubmitting,
                        icon: state.isSubmitting
                            ? null
                            : Icon(
                                Icons.send_rounded,
                                color: colors.onPrimary,
                                size: 20,
                              ),
                        onPressed: _submitQuestion,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
