import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/question_entity.dart';
import 'questions_providers.dart';
class QuestionDetailsState {
  const QuestionDetailsState({
    required this.isLoading,
    this.errorMessage,
    required this.answers,
    required this.markedAnswers,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<Answer> answers;

  /// answerId -> whether current user marked this answer
  final Map<String, bool> markedAnswers;

  factory QuestionDetailsState.initial() {
    return const QuestionDetailsState(
      isLoading: true,
      answers: [],
      markedAnswers: {},
    );
  }

  QuestionDetailsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Answer>? answers,
    Map<String, bool>? markedAnswers,
    bool clearError = false,
  }) {
    return QuestionDetailsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      answers: answers ?? this.answers,
      markedAnswers: markedAnswers ?? this.markedAnswers,
    );
  }
}

class QuestionDetailsController
    extends FamilyNotifier<QuestionDetailsState, String> {
  late String _questionId;

  @override
  QuestionDetailsState build(String arg) {
    _questionId = arg;
    Future.microtask(() => _fetchAnswers(_questionId));
    return QuestionDetailsState.initial();
  }

  Future<void> _fetchAnswers(String questionId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = ref.read(answersRepositoryProvider);
      final answers = await repository.getAnswers(questionId);

      state = state.copyWith(isLoading: false, answers: answers);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() => _fetchAnswers(_questionId);

  Future<void> createComment(String content) async {
    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true);

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
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteComment(String answerId) async {
    state = state.copyWith(isLoading: true, clearError: true);

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
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> upvoteAnswer(String answerId) async {
    final originalAnswers = [...state.answers];

    final updatedAnswers = state.answers.map((a) {
      if (a.id == answerId) {
        return a.copyWith(upVotes: a.upVotes + 1);
      }
      return a;
    }).toList();
    state = state.copyWith(answers: updatedAnswers);

    try {
      final repository = ref.read(answersRepositoryProvider);
      await repository.voteAnswer(answerId, 0); // 0 = Up
    } catch (_) {
      state = state.copyWith(answers: originalAnswers);
    }
  }

  Future<void> downvoteAnswer(String answerId) async {
    final originalAnswers = [...state.answers];

    final updatedAnswers = state.answers.map((a) {
      if (a.id == answerId) {
        return a.copyWith(downVotes: a.downVotes + 1);
      }
      return a;
    }).toList();
    state = state.copyWith(answers: updatedAnswers);

    try {
      final repository = ref.read(answersRepositoryProvider);
      await repository.voteAnswer(answerId, 1); // 1 = Down
    } catch (_) {
      state = state.copyWith(answers: originalAnswers);
    }
  }

  Future<void> toggleAcceptAnswer({
    required String answerId,
    required bool isAccepted,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

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
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleMarkAnswer({
    required String answerId,
    required bool shouldMark,
  }) async {
    final oldValue = state.markedAnswers[answerId] ?? false;

    final updatedMarks = {...state.markedAnswers, answerId: shouldMark};

    // Optimistic UI
    state = state.copyWith(markedAnswers: updatedMarks);

    try {
      final repository = ref.read(answersRepositoryProvider);

      final success = shouldMark
          ? await repository.markAnswer(answerId)
          : await repository.unmarkAnswer(answerId);

      if (!success) {
        state = state.copyWith(
          markedAnswers: {...state.markedAnswers, answerId: oldValue},
        );
      }
    } catch (_) {
      state = state.copyWith(
        markedAnswers: {...state.markedAnswers, answerId: oldValue},
      );
    }
  }
}


final questionDetailsControllerProvider =
    NotifierProviderFamily<
      QuestionDetailsController,
      QuestionDetailsState,
      String
    >(QuestionDetailsController.new);
