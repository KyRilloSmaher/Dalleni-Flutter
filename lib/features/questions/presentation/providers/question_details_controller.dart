import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/question_entity.dart';
import 'questions_providers.dart';

class QuestionDetailsState {
  const QuestionDetailsState({
    required this.isLoading,
    this.errorMessage,
    required this.answers,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<Answer> answers;

  factory QuestionDetailsState.initial() =>
      const QuestionDetailsState(isLoading: true, answers: []);

  QuestionDetailsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Answer>? answers,
    bool clearError = false,
  }) {
    return QuestionDetailsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      answers: answers ?? this.answers,
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
        return a.copyWith(upVotes: a.upVotes - 1);
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
}

final questionDetailsControllerProvider =
    NotifierProviderFamily<
      QuestionDetailsController,
      QuestionDetailsState,
      String
    >(QuestionDetailsController.new);
