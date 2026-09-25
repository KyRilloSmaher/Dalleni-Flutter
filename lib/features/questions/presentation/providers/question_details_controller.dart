import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/question_entity.dart';
import 'home_feed_controller.dart';
import 'questions_providers.dart';

class QuestionDetailsState {
  const QuestionDetailsState({
    required this.isLoading,
    this.activeQuestion,
    this.errorMessage,
    required this.answers,
    required this.markedAnswers,
    required this.isQuestionOwner,
    required this.isCheckingOwner,
  });

  final bool isLoading;
  final Question? activeQuestion;
  final String? errorMessage;
  final List<Answer> answers;

  /// answerId -> whether current user marked this answer
  final Map<String, bool> markedAnswers;

  final bool isQuestionOwner;
  final bool isCheckingOwner;

  factory QuestionDetailsState.initial() {
    return const QuestionDetailsState(
      isLoading: true,
      answers: [],
      markedAnswers: {},
      isQuestionOwner: false,
      isCheckingOwner: true,
    );
  }

  QuestionDetailsState copyWith({
    bool? isLoading,
    Question? activeQuestion,
    String? errorMessage,
    List<Answer>? answers,
    Map<String, bool>? markedAnswers,
    bool? isQuestionOwner,
    bool? isCheckingOwner,
    bool clearError = false,
  }) {
    return QuestionDetailsState(
      isLoading: isLoading ?? this.isLoading,
      activeQuestion: activeQuestion ?? this.activeQuestion,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      answers: answers ?? this.answers,
      markedAnswers: markedAnswers ?? this.markedAnswers,
      isQuestionOwner: isQuestionOwner ?? this.isQuestionOwner,
      isCheckingOwner: isCheckingOwner ?? this.isCheckingOwner,
    );
  }
}

class QuestionDetailsController
    extends FamilyNotifier<QuestionDetailsState, String> {
  late String _questionId;

  @override
  QuestionDetailsState build(String arg) {
    _questionId = arg;

    Future.microtask(() async {
      await _fetchAnswers(_questionId);
      await _checkQuestionOwner();
    });

    return QuestionDetailsState.initial();
  }

  // ---------------------------------------------------------------------------
  // QUESTION
  // ---------------------------------------------------------------------------

  void initQuestion(Question question) {
    if (state.activeQuestion == null) {
      state = state.copyWith(
        activeQuestion: question,
      );
    }
  }

  Future<void> voteQuestionPost(int voteType) async {
    final current = state.activeQuestion;

    if (current == null) return;

    final isCurrentlyUpvoted = current.upVotedByCurrentUser;
    final isCurrentlyDownvoted = current.downVotedByCurrentUser;

    final isRemovingVote =
        voteType == 0
            ? isCurrentlyUpvoted
            : isCurrentlyDownvoted;

    final newIsUpvoted =
        !isRemovingVote && voteType == 0;

    final newIsDownvoted =
        !isRemovingVote && voteType == 1;

    var upVotes = current.upVotes;
    var downVotes = current.downVotes;

    if (isCurrentlyUpvoted && upVotes > 0) {
      upVotes--;
    }

    if (isCurrentlyDownvoted && downVotes > 0) {
      downVotes--;
    }

    if (newIsUpvoted) {
      upVotes++;
    }

    if (newIsDownvoted) {
      downVotes++;
    }

    state = state.copyWith(
      activeQuestion: current.copyWith(
        upVotes: upVotes,
        downVotes: downVotes,
        upVotedByCurrentUser: newIsUpvoted,
        downVotedByCurrentUser: newIsDownvoted,
      ),
    );

    if (voteType == 0) {
      await ref
          .read(homeFeedControllerProvider.notifier)
          .upvoteQuestion(current.id);
    } else {
      await ref
          .read(homeFeedControllerProvider.notifier)
          .downvoteQuestion(current.id);
    }
  }

  // ---------------------------------------------------------------------------
  // OWNER
  // ---------------------------------------------------------------------------

  Future<void> _checkQuestionOwner() async {
    final localStorage = ref.read(localStorageServiceProvider);
    final currentUserId = localStorage.getUserId();

    final question = state.activeQuestion;

    if (question == null) {
      state = state.copyWith(
        isCheckingOwner: false,
      );
      return;
    }

    state = state.copyWith(
      isQuestionOwner: currentUserId == question.userId,
      isCheckingOwner: false,
    );
  }

  // ---------------------------------------------------------------------------
  // ANSWERS
  // ---------------------------------------------------------------------------

  Future<void> _fetchAnswers(String questionId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final repository = ref.read(answersRepositoryProvider);

      final answers = await repository.getAnswers(questionId);

      state = state.copyWith(
        isLoading: false,
        answers: answers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await _fetchAnswers(_questionId);
  }

  // ---------------------------------------------------------------------------
  // CREATE / DELETE
  // ---------------------------------------------------------------------------

  Future<void> createComment(String content) async {
    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final repository = ref.read(answersRepositoryProvider);

      final success = await repository.createAnswer(
        content: trimmedContent,
        questionId: _questionId,
      );

      if (success) {
        await _fetchAnswers(_questionId);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to create comment',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteComment(String answerId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final repository = ref.read(answersRepositoryProvider);

      final success = await repository.deleteAnswer(answerId);

      if (success) {
        await _fetchAnswers(_questionId);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to delete comment',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // ANSWER VOTES
  // ---------------------------------------------------------------------------

  Future<void> upvoteAnswer(String answerId) async {
    await _voteAnswer(
      answerId: answerId,
      voteType: 0,
    );
  }

  Future<void> downvoteAnswer(String answerId) async {
    await _voteAnswer(
      answerId: answerId,
      voteType: 1,
    );
  }

  Future<void> _voteAnswer({
    required String answerId,
    required int voteType,
  }) async {
    final currentAnswer = _findAnswer(answerId);

    if (currentAnswer == null) return;

    final isCurrentlyUpvoted =
        currentAnswer.upVotedByCurrentUser ?? false;

    final isCurrentlyDownvoted =
        currentAnswer.downVotedByCurrentUser ?? false; 

    final isRemovingVote =
        voteType == 0
            ? isCurrentlyUpvoted
            : isCurrentlyDownvoted;

    final newIsUpvoted =
        !isRemovingVote && voteType == 0;

    final newIsDownvoted =
        !isRemovingVote && voteType == 1;

    var upVotes = currentAnswer.upVotes;
    var downVotes = currentAnswer.downVotes;

    if (isCurrentlyUpvoted && upVotes > 0) {
      upVotes--;
    }

    if (isCurrentlyDownvoted && downVotes > 0) {
      downVotes--;
    }

    if (newIsUpvoted) {
      upVotes++;
    }

    if (newIsDownvoted) {
      downVotes++;
    }

    final updatedAnswer = currentAnswer.copyWith(
      upVotes: upVotes,
      downVotes: downVotes,
      upVotedByCurrentUser: newIsUpvoted,
      downVotedByCurrentUser: newIsDownvoted,
    );

    _updateAnswer(updatedAnswer);

    try {
      final repository = ref.read(answersRepositoryProvider);

      await repository.voteAnswer(
        answerId,
        voteType,
      );
    } catch (_) {
      // Rollback if API fails.
      _updateAnswer(currentAnswer);
    }
  }

  // ---------------------------------------------------------------------------
  // ACCEPT
  // ---------------------------------------------------------------------------

  Future<void> toggleAcceptForAnswer(Answer answer) async {
    await toggleAcceptAnswer(
      answerId: answer.id,
      isAccepted: answer.isApproved,
    );
  }

  Future<void> toggleAcceptAnswer({
    required String answerId,
    required bool isAccepted,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final repository = ref.read(answersRepositoryProvider);

      final success = isAccepted
          ? await repository.unacceptAnswer(answerId)
          : await repository.acceptAnswer(answerId);

      if (success) {
        await _fetchAnswers(_questionId);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: isAccepted
              ? 'Failed to unaccept answer'
              : 'Failed to accept answer',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // MARK
  // ---------------------------------------------------------------------------

  Future<void> toggleMarkForAnswer(Answer answer) async {
    final isMarked =
        state.markedAnswers[answer.id] ?? false;

    await toggleMarkAnswer(
      answerId: answer.id,
      shouldMark: !isMarked,
    );
  }

  Future<void> toggleMarkAnswer({
    required String answerId,
    required bool shouldMark,
  }) async {
    final oldValue =
        state.markedAnswers[answerId] ?? false;

    final updatedMarks = {
      ...state.markedAnswers,
      answerId: shouldMark,
    };

    // Optimistic UI.
    state = state.copyWith(
      markedAnswers: updatedMarks,
    );

    try {
      final repository = ref.read(answersRepositoryProvider);

      final success = shouldMark
          ? await repository.markAnswer(answerId)
          : await repository.unmarkAnswer(answerId);

      if (!success) {
        _rollbackMark(
          answerId: answerId,
          oldValue: oldValue,
        );
      }
    } catch (_) {
      _rollbackMark(
        answerId: answerId,
        oldValue: oldValue,
      );
    }
  }

  void _rollbackMark({
    required String answerId,
    required bool oldValue,
  }) {
    state = state.copyWith(
      markedAnswers: {
        ...state.markedAnswers,
        answerId: oldValue,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Answer? _findAnswer(String answerId) {
    for (final answer in state.answers) {
      if (answer.id == answerId) {
        return answer;
      }
    }

    return null;
  }

  void _updateAnswer(Answer updatedAnswer) {
    final updatedAnswers = state.answers.map((answer) {
      if (answer.id == updatedAnswer.id) {
        return updatedAnswer;
      }

      return answer;
    }).toList();

    state = state.copyWith(
      answers: updatedAnswers,
    );
  }
}

final questionDetailsControllerProvider =
    NotifierProviderFamily<
      QuestionDetailsController,
      QuestionDetailsState,
      String
    >(QuestionDetailsController.new);