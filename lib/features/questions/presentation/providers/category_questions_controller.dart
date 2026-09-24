import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_feed_controller.dart';
import 'questions_providers.dart';

class CategoryQuestionsController
    extends FamilyNotifier<HomeFeedState, String> {
  late String _categoryId;

  @override
  HomeFeedState build(String arg) {
    _categoryId = arg;
    Future.microtask(_fetchQuestions);
    return HomeFeedState.initial();
  }

  Future<void> _fetchQuestions() async {
    print('Iam Here');

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final pagedResponse = await ref
          .read(questionsRepositoryProvider)
          .getQuestionsByCategory(categoryId: _categoryId);

      print('Iam Here Again');
      print('Questions count = ${pagedResponse.items.length}');

      state = state.copyWith(
        isLoading: false,
        questions: pagedResponse.items,
        currentPage: pagedResponse.pageNumber,
        hasMore: pagedResponse.hasNextPage,
      );

      print('State updated successfully');
    } catch (error, stackTrace) {
      print('ERROR = $error');
      print('STACK = $stackTrace');

      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> refresh() => _fetchQuestions();

  Future<void> upvoteQuestion(String questionId) async {
    await _applyVote(questionId, 0);
  }

  Future<void> downvoteQuestion(String questionId) async {
    await _applyVote(questionId, 1);
  }

  Future<void> _applyVote(String questionId, int voteType) async {
    final originalQuestions = state.questions;
    final index = originalQuestions.indexWhere((q) => q.id == questionId);
    if (index == -1) return;

    final question = originalQuestions[index];
    final isCurrentlyUpvoted = question.upVotedByCurrentUser;
    final isCurrentlyDownvoted = question.downVotedByCurrentUser;
    final isRemovingVote =
        voteType == 0 ? isCurrentlyUpvoted : isCurrentlyDownvoted;

    final newIsUpvoted = !isRemovingVote && voteType == 0;
    final newIsDownvoted = !isRemovingVote && voteType == 1;

    var upVotes = question.upVotes;
    var downVotes = question.downVotes;

    if (isCurrentlyUpvoted && upVotes > 0) upVotes--;
    if (isCurrentlyDownvoted && downVotes > 0) downVotes--;

    if (newIsUpvoted) upVotes++;
    if (newIsDownvoted) downVotes++;

    final updatedQuestion = question.copyWith(
      upVotes: upVotes,
      downVotes: downVotes,
      upVotedByCurrentUser: newIsUpvoted,
      downVotedByCurrentUser: newIsDownvoted,
    );

    state = state.copyWith(
      questions: originalQuestions
          .map((q) => q.id == questionId ? updatedQuestion : q)
          .toList(growable: false),
    );

    try {
      await ref.read(questionsRepositoryProvider).voteQuestion(questionId, voteType);
    } catch (_) {
      state = state.copyWith(questions: originalQuestions);
    }
  }
}

final categoryQuestionsControllerProvider =
    NotifierProviderFamily<CategoryQuestionsController, HomeFeedState, String>(
      CategoryQuestionsController.new,
    );
