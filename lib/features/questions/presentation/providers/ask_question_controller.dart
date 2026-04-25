import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/question_entity.dart';
import 'questions_providers.dart';

class AskQuestionState {
  const AskQuestionState({
    required this.categories,
    required this.isLoading,
    this.errorMessage,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  final List<QuestionCategory> categories;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitting;
  final bool isSuccess;

  factory AskQuestionState.initial() =>
      const AskQuestionState(categories: [], isLoading: true);

  AskQuestionState copyWith({
    List<QuestionCategory>? categories,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitting,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return AskQuestionState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class AskQuestionController extends Notifier<AskQuestionState> {
  @override
  AskQuestionState build() {
    Future.microtask(_fetchCategories);
    return AskQuestionState.initial();
  }

  Future<void> _fetchCategories() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final categories = await ref
          .read(questionsRepositoryProvider)
          .getCategories();
      state = state.copyWith(isLoading: false, categories: categories);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> submitQuestion({
    required String title,
    required String content,
    required String categoryId,
    required List<String> tags,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final success = await ref
          .read(questionsRepositoryProvider)
          .createQuestion(
            title: title,
            content: content,
            categoryId: categoryId,
            tags: tags,
          );
      state = state.copyWith(isSubmitting: false, isSuccess: success);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }

  void resetSuccess() => state = state.copyWith(isSuccess: false);
}

final askQuestionControllerProvider =
    NotifierProvider<AskQuestionController, AskQuestionState>(
      AskQuestionController.new,
    );
