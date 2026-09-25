import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../providers/ask_question_controller.dart';
import '../widgets/ask_question_form_widget.dart';
import '../widgets/ask_question_loading_widget.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _showMessengerSnackBar(String message, {bool floating = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: floating ? SnackBarBehavior.floating : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final l10n = context.l10n;
    final state = ref.watch(askQuestionControllerProvider);
    final controller = ref.read(askQuestionControllerProvider.notifier);

    ref.listen<AskQuestionState>(askQuestionControllerProvider, (previous, next) {
      if (next.isSuccess) {
        _showMessengerSnackBar(
          l10n.translate('askSuccessMessage'),
          floating: true,
        );
        _titleController.clear();
        _descriptionController.clear();
        controller.resetSuccess();
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        _showMessengerSnackBar(next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      drawer: const AnimatedFunkyDrawer(),
      appBar: CommonGlassAppBar(title: l10n.translate('navAsk')),
      body: state.isLoading
          ? const AskQuestionLoadingWidget()
          : AskQuestionFormWidget(
              categories: state.categories,
              selectedCategoryId: state.selectedCategoryId,
              isSubmitting: state.isSubmitting,
              titleController: _titleController,
              descriptionController: _descriptionController,
              titleFocusNode: _titleFocusNode,
              descriptionFocusNode: _descriptionFocusNode,
              onCategorySelected: controller.selectCategory,
              onSubmit: () => controller.submitQuestionWithValidation(
                title: _titleController.text,
                content: _descriptionController.text,
              ),
            ),
    );
  }
}
