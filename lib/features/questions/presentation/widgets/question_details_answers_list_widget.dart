import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/question_entity.dart';
import '../providers/question_details_controller.dart';
import 'answer_card.dart';

class QuestionDetailsAnswersListWidget extends ConsumerWidget {
  const QuestionDetailsAnswersListWidget({
    super.key,
    required this.answers,
    required this.questionId,
    required this.questionUserId,
  });

  final List<Answer> answers;
  final String questionId;
  final String? questionUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionDetailsControllerProvider(questionId));
    final controller = ref.read(
      questionDetailsControllerProvider(questionId).notifier,
    );
    final currentUserId = ref.read(localStorageServiceProvider).getUserId();
    final isQuestionOwner =
        currentUserId != null && currentUserId == questionUserId;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final answer = answers[index];
        final isAnswerOwner =
            currentUserId != null && currentUserId == answers[index].userId;

        final isMarkedSuccess =
            state.markedSuccessAnswers[answer.id] ??
            answer.markedSuccessedByCurrentUser;
        final isMarkedUnsuccess =
            state.markedUnsuccessAnswers[answer.id] ??
            answer.markedUnsuccessedByCurrentUser;

        return AnswerCard(
          isUpvoted: answer.upVotedByCurrentUser ?? false,
          isDownvoted: answer.downVotedByCurrentUser ?? false,
          answer: answer,
          isMarkedSuccess: isMarkedSuccess,
          isMarkedUnsuccess: isMarkedUnsuccess,
          isQuestionOwner: isQuestionOwner,
           isAnswerOwner: isAnswerOwner,
          onUpvote: () => controller.upvoteAnswer(answer.id),
          onDownvote: () => controller.downvoteAnswer(answer.id),
          onDelete: () => controller.deleteComment(answer.id),
          onToggleAccept: () => controller.toggleAcceptForAnswer(answer),
          onToggleMarkSuccess: () => controller.toggleMarkSuccess(answer.id),
          onToggleMarkUnsuccess: () =>
              controller.toggleMarkUnsuccess(answer.id),
        );
      }, childCount: answers.length),
    );
  }
}
