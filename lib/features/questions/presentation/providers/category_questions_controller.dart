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
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final pagedResponse = await ref
          .read(questionsRepositoryProvider)
          .getQuestionsByCategory(categoryId: _categoryId);

      state = state.copyWith(
        isLoading: false,
        questions: pagedResponse.items,
        currentPage: pagedResponse.pageNumber,
        hasMore: pagedResponse.hasNextPage,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> refresh() => _fetchQuestions();

  Future<void> upvoteQuestion(String questionId) async {
    final originalQuestions = state.questions;
    state = state.copyWith(
      questions: state.questions
          .map(
            (question) => question.id == questionId
                ? question.copyWith(upVotes: question.upVotes + 1)
                : question,
          )
          .toList(growable: false),
    );

    try {
      await ref.read(questionsRepositoryProvider).voteQuestion(questionId, 0);
    } catch (_) {
      state = state.copyWith(questions: originalQuestions);
    }
  }

  Future<void> downvoteQuestion(String questionId) async {
    final originalQuestions = state.questions;
    state = state.copyWith(
      questions: state.questions
          .map(
            (question) => question.id == questionId
                ? question.copyWith(upVotes: question.upVotes - 1)
                : question,
          )
          .toList(growable: false),
    );

    try {
      await ref.read(questionsRepositoryProvider).voteQuestion(questionId, 1);
    } catch (_) {
      state = state.copyWith(questions: originalQuestions);
    }
  }
}

final categoryQuestionsControllerProvider =
    NotifierProviderFamily<CategoryQuestionsController, HomeFeedState, String>(
      CategoryQuestionsController.new,
    );
