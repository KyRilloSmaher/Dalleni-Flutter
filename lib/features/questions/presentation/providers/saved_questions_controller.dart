import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/question_entity.dart';
import 'questions_providers.dart';

class SavedQuestionsState {
  const SavedQuestionsState({
    required this.questions,
    required this.savedRecordIds,
    required this.isLoading,
    this.errorMessage,
  });

  final List<Question> questions;
  final Map<String, String> savedRecordIds;
  final bool isLoading;
  final String? errorMessage;

  factory SavedQuestionsState.initial() => const SavedQuestionsState(
    questions: <Question>[],
    savedRecordIds: <String, String>{},
    isLoading: false,
  );

  SavedQuestionsState copyWith({
    List<Question>? questions,
    Map<String, String>? savedRecordIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SavedQuestionsState(
      questions: questions ?? this.questions,
      savedRecordIds: savedRecordIds ?? this.savedRecordIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class SavedQuestionsController extends Notifier<SavedQuestionsState> {
  @override
  SavedQuestionsState build() {
    Future.microtask(fetchSavedQuestions);
    return SavedQuestionsState.initial();
  }

  Future<void> fetchSavedQuestions() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final savedQuestions = await ref
          .read(questionsRepositoryProvider)
          .getSavedQuestions();
      state = state.copyWith(
        isLoading: false,
        questions: savedQuestions
            .map((savedQuestion) => savedQuestion.question)
            .toList(growable: false),
        savedRecordIds: <String, String>{
          for (final savedQuestion in savedQuestions)
            savedQuestion.questionId: savedQuestion.id,
        },
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> toggleSave(Question question) async {
    final savedQuestionId = state.savedRecordIds[question.id];
    if (savedQuestionId == null) {
      return;
    }

    final originalState = state;
    state = state.copyWith(
      questions: state.questions
          .where((savedQuestion) => savedQuestion.id != question.id)
          .toList(growable: false),
      savedRecordIds: <String, String>{...state.savedRecordIds}
        ..remove(question.id),
    );

    try {
      await ref
          .read(questionsRepositoryProvider)
          .unsaveQuestion(savedQuestionId);
    } catch (error) {
      state = originalState.copyWith(errorMessage: error.toString());
    }
  }

  bool isBookmarked(String questionId) =>
      state.savedRecordIds.containsKey(questionId);
}

final savedQuestionsControllerProvider =
    NotifierProvider<SavedQuestionsController, SavedQuestionsState>(
      SavedQuestionsController.new,
    );
