import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/paged_list.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/question_entity.dart';
import 'questions_providers.dart';

class HomeFeedState {
  const HomeFeedState({
    required this.isLoading,
    required this.isLoadingMore,
    required this.isRefreshingSavedQuestions,
    required this.questions,
    required this.availableTags,
    required this.savedQuestionIds,
    required this.savedQuestionRecordIds,
    required this.currentPage,
    required this.hasMore,
    required this.searchQuery,
    this.selectedTag,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshingSavedQuestions;
  final List<Question> questions;
  final List<QuestionTag> availableTags;
  final Set<String> savedQuestionIds;
  final Map<String, String> savedQuestionRecordIds;
  final int currentPage;
  final bool hasMore;
  final String searchQuery;
  final QuestionTag? selectedTag;
  final String? errorMessage;

  factory HomeFeedState.initial() {
    return const HomeFeedState(
      isLoading: true,
      isLoadingMore: false,
      isRefreshingSavedQuestions: false,
      questions: <Question>[],
      availableTags: <QuestionTag>[],
      savedQuestionIds: <String>{},
      savedQuestionRecordIds: <String, String>{},
      currentPage: 1,
      hasMore: true,
      searchQuery: '',
    );
  }

  bool get showEmptyState =>
      !isLoading && questions.isEmpty && errorMessage == null;

  HomeFeedState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshingSavedQuestions,
    List<Question>? questions,
    List<QuestionTag>? availableTags,
    Set<String>? savedQuestionIds,
    Map<String, String>? savedQuestionRecordIds,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    QuestionTag? selectedTag,
    String? errorMessage,
    bool clearSelectedTag = false,
    bool clearError = false,
  }) {
    return HomeFeedState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshingSavedQuestions:
          isRefreshingSavedQuestions ?? this.isRefreshingSavedQuestions,
      questions: questions ?? this.questions,
      availableTags: availableTags ?? this.availableTags,
      savedQuestionIds: savedQuestionIds ?? this.savedQuestionIds,
      savedQuestionRecordIds:
          savedQuestionRecordIds ?? this.savedQuestionRecordIds,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTag: clearSelectedTag ? null : selectedTag ?? this.selectedTag,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class HomeFeedController extends Notifier<HomeFeedState> {
  static const int _pageSize = 10;

  Timer? _searchDebounce;

  @override
  HomeFeedState build() {
    Future.microtask(_bootstrap);
    ref.onDispose(() => _searchDebounce?.cancel());
    return HomeFeedState.initial();
  }

  Future<void> _bootstrap() async {
    await Future.wait(<Future<void>>[_loadTags(), _loadSavedQuestions()]);
    await refresh();
  }

  Future<void> _loadTags() async {
    try {
      final tags = await ref.read(questionsRepositoryProvider).getTags();
      state = state.copyWith(availableTags: tags);
    } catch (_) {
      // Keep feed usable even if tags fail.
    }
  }

  Future<void> _loadSavedQuestions() async {
    state = state.copyWith(isRefreshingSavedQuestions: true, clearError: true);
    try {
      final savedQuestions = await ref
          .read(questionsRepositoryProvider)
          .getSavedQuestions();
      state = state.copyWith(
        isRefreshingSavedQuestions: false,
        savedQuestionIds: savedQuestions
            .map((savedQuestion) => savedQuestion.questionId)
            .toSet(),
        savedQuestionRecordIds: <String, String>{
          for (final savedQuestion in savedQuestions)
            savedQuestion.questionId: savedQuestion.id,
        },
      );
    } catch (_) {
      state = state.copyWith(isRefreshingSavedQuestions: false);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      currentPage: 1,
      hasMore: true,
      clearError: true,
    );

    try {
      final pagedQuestions = await _loadPage(pageNumber: 1);
      state = state.copyWith(
        isLoading: false,
        questions: pagedQuestions.items,
        currentPage: pagedQuestions.pageNumber,
        hasMore: pagedQuestions.hasNextPage,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final nextPage = state.currentPage + 1;
      final pagedQuestions = await _loadPage(pageNumber: nextPage);
      state = state.copyWith(
        isLoadingMore: false,
        questions: <Question>[...state.questions, ...pagedQuestions.items],
        currentPage: pagedQuestions.pageNumber,
        hasMore: pagedQuestions.hasNextPage,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.toString(),
      );
    }
  }

  void updateSearchQuery(String value) {
    _searchDebounce?.cancel();
    state = state.copyWith(searchQuery: value);
    _searchDebounce = Timer(const Duration(milliseconds: 450), () => refresh());
  }

  Future<void> selectTag(QuestionTag? tag) async {
    state = state.copyWith(
      selectedTag: tag,
      searchQuery: '',
      clearSelectedTag: tag == null,
    );
    await refresh();
  }

  Future<void> upvoteQuestion(String questionId) async {
    await _applyOptimisticVote(questionId: questionId, delta: 1, voteType: 0);
  }

  Future<void> downvoteQuestion(String questionId) async {
    await _applyOptimisticVote(questionId: questionId, delta: -1, voteType: 1);
  }

  Future<void> toggleSaveQuestion(Question question) async {
    final currentlySaved = state.savedQuestionIds.contains(question.id);
    final previousSavedIds = state.savedQuestionIds;
    final previousRecordIds = state.savedQuestionRecordIds;

    if (currentlySaved) {
      final savedRecordId = state.savedQuestionRecordIds[question.id];
      if (savedRecordId == null) {
        return;
      }

      state = state.copyWith(
        savedQuestionIds: <String>{...state.savedQuestionIds}
          ..remove(question.id),
        savedQuestionRecordIds: <String, String>{
          ...state.savedQuestionRecordIds,
        }..remove(question.id),
      );

      try {
        await ref
            .read(questionsRepositoryProvider)
            .unsaveQuestion(savedRecordId);
      } catch (error) {
        state = state.copyWith(
          savedQuestionIds: previousSavedIds,
          savedQuestionRecordIds: previousRecordIds,
          errorMessage: error.toString(),
        );
      }

      return;
    }

    final userId = ref.read(localStorageServiceProvider).getUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }

    state = state.copyWith(
      savedQuestionIds: <String>{...state.savedQuestionIds, question.id},
    );

    try {
      await ref
          .read(questionsRepositoryProvider)
          .saveQuestion(question.id, userId);
      await _loadSavedQuestions();
    } catch (error) {
      state = state.copyWith(
        savedQuestionIds: previousSavedIds,
        savedQuestionRecordIds: previousRecordIds,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> _applyOptimisticVote({
    required String questionId,
    required int delta,
    required int voteType,
  }) async {
    final originalQuestions = state.questions;
    state = state.copyWith(
      questions: state.questions
          .map(
            (question) => question.id == questionId
                ? question.copyWith(upVotes: question.upVotes + delta)
                : question,
          )
          .toList(growable: false),
    );

    try {
      await ref
          .read(questionsRepositoryProvider)
          .voteQuestion(questionId, voteType);
    } catch (error) {
      state = state.copyWith(
        questions: originalQuestions,
        errorMessage: error.toString(),
      );
    }
  }

  Future<PagedList<Question>> _loadPage({required int pageNumber}) {
    final repository = ref.read(questionsRepositoryProvider);
    if (state.selectedTag != null) {
      return repository.getQuestionsByTag(
        tagId: state.selectedTag!.id,
        pageNumber: pageNumber,
        pageSize: _pageSize,
      );
    }

    if (state.searchQuery.trim().isNotEmpty) {
      return repository.searchQuestions(
        query: state.searchQuery.trim(),
        pageNumber: pageNumber,
        pageSize: _pageSize,
      );
    }

    return repository.getQuestions(pageNumber: pageNumber, pageSize: _pageSize);
  }
}

final homeFeedControllerProvider =
    NotifierProvider<HomeFeedController, HomeFeedState>(HomeFeedController.new);
