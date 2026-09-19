import 'dart:async';

import 'package:dalleni/core/models/paged_list.dart';
import 'package:dalleni/core/network/api_exception.dart';
import 'package:dalleni/core/providers/core_providers.dart';
import 'package:dalleni/core/storage/local_storage_service.dart';
import 'package:dalleni/features/questions/domain/entities/question_entity.dart';
import 'package:dalleni/features/questions/domain/repositories/questions_repository.dart';
import 'package:dalleni/features/questions/presentation/providers/home_feed_controller.dart';
import 'package:dalleni/features/questions/presentation/providers/questions_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeQuestionsRepository repository;
  late LocalStorageService storage;
  late ProviderContainer container;
  late Question question;

  Question buildQuestion() {
    return Question(
      id: 'question-1',
      title: 'How does save work?',
      userId: 'author-1',
      authorName: 'Author',
      upVotes: 0,
      downVotes: 0,
      views: 0,
      answersCount: 0,
      isClosed: false,
      createdAt: DateTime.utc(2026, 1, 1),
      tags: const <QuestionTag>[],
    );
  }

  Future<void> pumpMicrotasks() async {
    await Future<void>.value();
    await Future<void>.value();
  }

  setUp(() async {
    question = buildQuestion();
    repository = _FakeQuestionsRepository(question: question);
    SharedPreferences.setMockInitialValues(<String, Object>{
      LocalStorageService.userIdKey: 'user-1',
    });
    storage = LocalStorageService(await SharedPreferences.getInstance());
    container = ProviderContainer(
      overrides: <Override>[
        questionsRepositoryProvider.overrideWithValue(repository),
        localStorageServiceProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);
  });

  test('does not save until the initial saved-questions load completes', () async {
    container.read(homeFeedControllerProvider);
    await pumpMicrotasks();

    final controller = container.read(homeFeedControllerProvider.notifier);
    await controller.refresh();
    await controller.toggleSaveQuestion(question);

    expect(
      container.read(homeFeedControllerProvider).savedQuestionIds,
      isEmpty,
    );
    expect(repository.saveCallCount, 0);

    repository.savedQuestionsCompleters.single.complete(const <SavedQuestion>[]);
    await pumpMicrotasks();

    expect(container.read(homeFeedControllerProvider).areSavedQuestionsReady, isTrue);
    expect(
      container.read(homeFeedControllerProvider).savedQuestionIds,
      isEmpty,
    );
  });

  test('ignores a stale saved-questions response after optimistic save', () async {
    container.read(homeFeedControllerProvider);
    await pumpMicrotasks();
    repository.savedQuestionsCompleters.single.complete(const <SavedQuestion>[]);
    await pumpMicrotasks();

    final controller = container.read(homeFeedControllerProvider.notifier);
    unawaited(controller.reloadSavedQuestions());
    await pumpMicrotasks();

    await controller.toggleSaveQuestion(question);

    expect(
      container.read(homeFeedControllerProvider).savedQuestionIds,
      contains(question.id),
    );

    repository.savedQuestionsCompleters.last.complete(const <SavedQuestion>[]);
    await pumpMicrotasks();

    final state = container.read(homeFeedControllerProvider);
    expect(state.savedQuestionIds, contains(question.id));
    expect(state.savedQuestionRecordIds[question.id], 'record-1');
  });

  test('rolls back optimistic save when the API fails', () async {
    repository.saveQuestionError = const ApiException(message: 'Save failed');

    container.read(homeFeedControllerProvider);
    await pumpMicrotasks();
    repository.savedQuestionsCompleters.single.complete(const <SavedQuestion>[]);
    await pumpMicrotasks();

    await container
        .read(homeFeedControllerProvider.notifier)
        .toggleSaveQuestion(question);
    await pumpMicrotasks();

    final state = container.read(homeFeedControllerProvider);
    expect(state.savedQuestionIds, isEmpty);
    expect(state.savedQuestionRecordIds, isEmpty);
    expect(state.errorMessage, contains('Save failed'));
  });

  test('ignores a second save tap for the same question while in flight', () async {
    final saveCompleter = Completer<String?>();
    repository.saveQuestionCompleter = saveCompleter;

    container.read(homeFeedControllerProvider);
    await pumpMicrotasks();
    repository.savedQuestionsCompleters.single.complete(const <SavedQuestion>[]);
    await pumpMicrotasks();

    final controller = container.read(homeFeedControllerProvider.notifier);
    final firstToggle = controller.toggleSaveQuestion(question);
    final secondToggle = controller.toggleSaveQuestion(question);
    saveCompleter.complete('record-1');
    await Future.wait(<Future<void>>[firstToggle, secondToggle]);

    expect(repository.saveCallCount, 1);
    expect(
      container.read(homeFeedControllerProvider).savedQuestionIds,
      contains(question.id),
    );
  });
}

class _FakeQuestionsRepository implements QuestionsRepository {
  _FakeQuestionsRepository({required this.question});

  final Question question;
  final List<Completer<List<SavedQuestion>>> savedQuestionsCompleters =
      <Completer<List<SavedQuestion>>>[];
  Completer<String?>? saveQuestionCompleter;
  Object? saveQuestionError;
  int saveCallCount = 0;

  @override
  Future<List<SavedQuestion>> getSavedQuestions() {
    final completer = Completer<List<SavedQuestion>>();
    savedQuestionsCompleters.add(completer);
    return completer.future;
  }

  @override
  Future<String?> saveQuestion(String questionId, String userId) async {
    saveCallCount++;
    if (saveQuestionError != null) {
      throw saveQuestionError!;
    }
    if (saveQuestionCompleter != null) {
      return saveQuestionCompleter!.future;
    }
    return 'record-1';
  }

  @override
  Future<bool> unsaveQuestion(String savedQuestionId) async => true;

  @override
  Future<PagedList<Question>> getQuestions({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return PagedList<Question>(
      items: <Question>[question],
      pageNumber: pageNumber,
      totalPages: 1,
      totalCount: 1,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  @override
  Future<PagedList<Question>> searchQuestions({
    required String query,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return getQuestions(pageNumber: pageNumber, pageSize: pageSize);
  }

  @override
  Future<PagedList<Question>> getQuestionsByTag({
    required String tagId,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return getQuestions(pageNumber: pageNumber, pageSize: pageSize);
  }

  @override
  Future<PagedList<Question>> getQuestionsByCategory({
    required String categoryId,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return getQuestions(pageNumber: pageNumber, pageSize: pageSize);
  }

  @override
  Future<Question> getQuestion(String id) async => question;

  @override
  Future<bool> createQuestion({
    required String title,
    required String content,
    required String categoryId,
    required List<String> tags,
  }) async => true;

  @override
  Future<bool> voteQuestion(String id, int type) async => true;

  @override
  Future<List<QuestionCategory>> getCategories() async =>
      const <QuestionCategory>[];

  @override
  Future<List<QuestionTag>> getTags({int pageNumber = 1, int pageSize = 20}) async =>
      const <QuestionTag>[];
}
