import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../../domain/entities/question_entity.dart';
import '../providers/question_details_controller.dart';
import '../widgets/question_details_answers_header_widget.dart';
import '../widgets/question_details_answers_list_widget.dart';
import '../widgets/question_details_card_widget.dart';
import '../widgets/question_details_comment_input_widget.dart';
import '../widgets/question_details_empty_answers_widget.dart';
import '../widgets/question_details_error_widget.dart';
import '../widgets/question_details_loading_widget.dart';

class QuestionDetailsScreen extends ConsumerStatefulWidget {
  const QuestionDetailsScreen({super.key, required this.question});

  final Question question;

  @override
  ConsumerState<QuestionDetailsScreen> createState() =>
      _QuestionDetailsScreenState();
}

class _QuestionDetailsScreenState
    extends ConsumerState<QuestionDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(questionDetailsControllerProvider(widget.question.id).notifier)
          .initQuestion(widget.question);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final state = ref.watch(
      questionDetailsControllerProvider(widget.question.id),
    );
    final controller = ref.read(
      questionDetailsControllerProvider(widget.question.id).notifier,
    );

    final activeQuestion = state.activeQuestion ?? widget.question;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: const CommonGlassAppBar(title: 'Question'),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.only(top: kToolbarHeight + 32),
          ),
          QuestionDetailsCardWidget(
            question: activeQuestion,
            onUpvote: () => controller.voteQuestionPost(0),
            onDownvote: () => controller.voteQuestionPost(1),
          ),
          QuestionDetailsAnswersHeaderWidget(
            answersCount: state.answers.length,
          ),
          if (state.isLoading)
            const QuestionDetailsLoadingWidget()
          else if (state.errorMessage != null)
            QuestionDetailsErrorWidget(
              errorMessage: state.errorMessage!,
              onRetry: controller.refresh,
            )
          else if (state.answers.isEmpty)
            const QuestionDetailsEmptyAnswersWidget()
          else
            QuestionDetailsAnswersListWidget(
              answers: state.answers,
              questionId: widget.question.id,
              questionUserId: widget.question.userId,
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
      bottomNavigationBar: QuestionDetailsCommentInputWidget(
        controller: _commentController,
        focusNode: _commentFocusNode,
        onSend: controller.createComment,
      ),
    );
  }
}
