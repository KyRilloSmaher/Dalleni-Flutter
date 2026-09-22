import 'dart:async';

import 'package:flutter/foundation.dart';
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
    required this.areSavedQuestionsReady,
    required this.questions,
    required this.availablecategory,
    required this.savedQuestionIds,
    required this.savedQuestionRecordIds,
    required this.currentPage,
    required this.hasMore,
    required this.searchQuery,
    this.selectedCategory,
    this.errorMessage,
    this.selectedTag,
  });

  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshingSavedQuestions;
  final bool areSavedQuestionsReady;
  final List<Question> questions;
  final List<QuestionCategory> availablecategory;
  final Set<String> savedQuestionIds;
  final Map<String, String> savedQuestionRecordIds;
  final int currentPage;
  final bool hasMore;
  final String searchQuery;
  final QuestionCategory? selectedCategory;
  final QuestionTag? selectedTag;
  final String? errorMessage;

  factory HomeFeedState.initial() {
    return const HomeFeedState(
      isLoading: true,
      isLoadingMore: false,
      isRefreshingSavedQuestions: false,
      areSavedQuestionsReady: false,
      questions: <Question>[],
      availablecategory: <QuestionCategory>[],
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
    bool? areSavedQuestionsReady,
    List<Question>? questions,
    List<QuestionCategory>? availablecategory,
    Set<String>? savedQuestionIds,
    Map<String, String>? savedQuestionRecordIds,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    QuestionCategory? selectedCategory,
    QuestionTag? selectedtag,
    String? errorMessage,
    bool clearSelectedTag = false,
    bool clearSelectedcategory = false,
    bool clearError = false,
  }) {
    return HomeFeedState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshingSavedQuestions:
          isRefreshingSavedQuestions ?? this.isRefreshingSavedQuestions,
      areSavedQuestionsReady:
          areSavedQuestionsReady ?? this.areSavedQuestionsReady,
      questions: questions ?? this.questions,
      availablecategory: availablecategory ?? this.availablecategory,
      savedQuestionIds: savedQuestionIds ?? this.savedQuestionIds,
      savedQuestionRecordIds:
          savedQuestionRecordIds ?? this.savedQuestionRecordIds,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearSelectedcategory
          ? null
          : selectedCategory ?? this.selectedCategory,
      selectedTag: clearSelectedTag ? null : selectedtag ?? this.selectedTag,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class HomeFeedController extends Notifier<HomeFeedState> {
  static const int _pageSize = 10;

  Timer? _searchDebounce;
  bool _isBootstrapping = false;
  int _savedStateEpoch = 0;
  final Set<String> _inFlightSaveQuestionIds = <String>{};

  @override
  HomeFeedState build() {
    Future.microtask(_bootstrap);
    ref.onDispose(() => _searchDebounce?.cancel());
    return HomeFeedState.initial();
  }

  Future<void> _bootstrap() async {
    if (_isBootstrapping) {
      return;
    }
    _isBootstrapping = true;
    try {
      await Future.wait(<Future<void>>[_loadCategory(), _loadSavedQuestions()]);
      await refresh();
    } finally {
      _isBootstrapping = false;
    }
  }

  Future<void> _loadCategory() async {
    try {
      final category = await ref
          .read(questionsRepositoryProvider)
          .getCategories();
      state = state.copyWith(availablecategory: category);
    } catch (_) {
      // Keep feed usable even if tags fail.
    }
  }

  Future<void> _loadSavedQuestions() async {
    final epochAtStart = _savedStateEpoch;
    state = state.copyWith(isRefreshingSavedQuestions: true, clearError: true);
    try {
      final savedQuestions = await ref
          .read(questionsRepositoryProvider)
          .getSavedQuestions();
      if (epochAtStart != _savedStateEpoch) {
        return;
      }
      state = state.copyWith(
        isRefreshingSavedQuestions: false,
        areSavedQuestionsReady: true,
        savedQuestionIds: savedQuestions
            .map((savedQuestion) => savedQuestion.questionId)
            .toSet(),
        savedQuestionRecordIds: <String, String>{
          for (final savedQuestion in savedQuestions)
            savedQuestion.questionId: savedQuestion.id,
        },
      );
    } catch (_) {
      if (epochAtStart != _savedStateEpoch) {
        return;
      }
      state = state.copyWith(
        isRefreshingSavedQuestions: false,
        areSavedQuestionsReady: true,
      );
    } finally {
      if (state.isRefreshingSavedQuestions) {
        state = state.copyWith(
          isRefreshingSavedQuestions: false,
          areSavedQuestionsReady: true,
        );
      }
    }
  }

  @visibleForTesting
  Future<void> reloadSavedQuestions() => _loadSavedQuestions();

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

  Future<void> upvoteQuestion(String questionId) async {
    await _applyOptimisticVote(questionId: questionId, delta: 1, voteType: 0);
  }

  Future<void> downvoteQuestion(String questionId) async {
    await _applyOptimisticVote(questionId: questionId, delta: -1, voteType: 1);
  }

  Future<void> toggleSaveQuestion(Question question) async {
    if (!state.areSavedQuestionsReady) {
      return;
    }
    if (!_inFlightSaveQuestionIds.add(question.id)) {
      return;
    }

    final currentlySaved = state.savedQuestionIds.contains(question.id);
    final previousSavedIds = state.savedQuestionIds;
    final previousRecordIds = state.savedQuestionRecordIds;

    try {
      if (currentlySaved) {
        await _unsaveQuestion(
          question: question,
          previousSavedIds: previousSavedIds,
          previousRecordIds: previousRecordIds,
        );
        return;
      }

      await _saveQuestion(
        question: question,
        previousSavedIds: previousSavedIds,
        previousRecordIds: previousRecordIds,
      );
    } finally {
      _inFlightSaveQuestionIds.remove(question.id);
    }
  }

  Future<void> _unsaveQuestion({
    required Question question,
    required Set<String> previousSavedIds,
    required Map<String, String> previousRecordIds,
  }) async {
    final savedRecordId = state.savedQuestionRecordIds[question.id];
    if (savedRecordId == null) {
      return;
    }

    _savedStateEpoch++;
    state = state.copyWith(
      savedQuestionIds: <String>{...state.savedQuestionIds}
        ..remove(question.id),
      savedQuestionRecordIds: <String, String>{...state.savedQuestionRecordIds}
        ..remove(question.id),
    );

    try {
      await ref.read(questionsRepositoryProvider).unsaveQuestion(savedRecordId);
    } catch (error) {
      state = state.copyWith(
        savedQuestionIds: previousSavedIds,
        savedQuestionRecordIds: previousRecordIds,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> _saveQuestion({
    required Question question,
    required Set<String> previousSavedIds,
    required Map<String, String> previousRecordIds,
  }) async {
    final userId = ref.read(localStorageServiceProvider).getUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }

    _savedStateEpoch++;
    state = state.copyWith(
      savedQuestionIds: <String>{...state.savedQuestionIds, question.id},
    );

    try {
      final savedRecordId = await ref
          .read(questionsRepositoryProvider)
          .saveQuestion(question.id, userId);
      if (savedRecordId != null && savedRecordId.isNotEmpty) {
        state = state.copyWith(
          savedQuestionRecordIds: <String, String>{
            ...state.savedQuestionRecordIds,
            question.id: savedRecordId,
          },
        );
      }
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
                ? (voteType == 0
                      ? question.copyWith(upVotes: question.upVotes + delta)
                      : question.copyWith(
                          downVotes: question.downVotes + delta.abs(),
                        ))
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

  Future<void> selectCategory(QuestionCategory? category) async {
    state = state.copyWith(
      selectedCategory: category,
      searchQuery: '',
      clearSelectedcategory: category == null,
      clearSelectedTag: true,
    );
    await refresh();
  }

  Future<void> selecttag(QuestionTag? tag) async {
    state = state.copyWith(
      selectedtag: tag,
      searchQuery: '',
      clearSelectedTag: tag == null,
      clearSelectedcategory: true,
    );
    await refresh();
  }

  Future<PagedList<Question>> _loadPage({required int pageNumber}) {
    final repository = ref.read(questionsRepositoryProvider);
    if (state.selectedCategory != null) {
      return repository.getQuestionsByCategory(
        categoryId: state.selectedCategory!.id,
        pageNumber: pageNumber,
        pageSize: _pageSize,
      );
    }
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
