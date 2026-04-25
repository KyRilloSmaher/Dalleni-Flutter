import '../../../../core/models/paged_list.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/repositories/questions_repository.dart';
import '../datasources/questions_remote_data_source.dart';
import '../models/question_model.dart';

class QuestionsRepositoryImpl implements QuestionsRepository {
  QuestionsRepositoryImpl({required QuestionsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final QuestionsRemoteDataSource _remoteDataSource;

  @override
  Future<PagedList<Question>> getQuestions({
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return _remoteDataSource.getQuestions(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  @override
  Future<PagedList<Question>> searchQuestions({
    required String query,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return _remoteDataSource.searchQuestions(
      query: query,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  @override
  Future<PagedList<Question>> getQuestionsByTag({
    required String tagId,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return _remoteDataSource.getQuestionsByTag(
      tagId: tagId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  @override
  Future<PagedList<Question>> getQuestionsByCategory({
    required String categoryId,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return _remoteDataSource.getQuestionsByCategory(
      categoryId: categoryId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  @override
  Future<Question> getQuestion(String id) {
    return _remoteDataSource.getQuestion(id);
  }

  @override
  Future<bool> createQuestion({
    required String title,
    required String content,
    required String categoryId,
    required List<String> tags,
  }) {
    final model = QuestionModel(
      id: '',
      title: title,
      userId: '',
      authorName: '',
      upVotes: 0,
      downVotes: 0,
      views: 0,
      answersCount: 0,
      isClosed: false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      tags: tags
          .map(
            (tagName) =>
                QuestionTag(id: '', name: tagName, slug: '', questionCount: 0),
          )
          .toList(growable: false),
      content: content,
      categoryId: categoryId,
    );

    return _remoteDataSource.createQuestion(model);
  }

  @override
  Future<bool> voteQuestion(String id, int type) {
    return _remoteDataSource.voteQuestion(id, type);
  }

  @override
  Future<List<QuestionCategory>> getCategories() {
    return _remoteDataSource.getCategories();
  }

  @override
  Future<List<QuestionTag>> getTags({int pageNumber = 1, int pageSize = 20}) {
    return _remoteDataSource.getTags(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  @override
  Future<bool> saveQuestion(String questionId, String userId) {
    return _remoteDataSource.saveQuestion(questionId, userId);
  }

  @override
  Future<bool> unsaveQuestion(String savedQuestionId) {
    return _remoteDataSource.unsaveQuestion(savedQuestionId);
  }

  @override
  Future<List<SavedQuestion>> getSavedQuestions() {
    return _remoteDataSource.getSavedQuestions();
  }
}
