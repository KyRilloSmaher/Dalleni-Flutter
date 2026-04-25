import '../../domain/entities/question_entity.dart';
import '../../domain/repositories/questions_repository.dart';
import '../datasources/answers_remote_data_source.dart';
import '../models/question_model.dart';

class AnswersRepositoryImpl implements AnswersRepository {
  AnswersRepositoryImpl({required AnswersRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AnswersRemoteDataSource _remoteDataSource;

  @override
  Future<List<Answer>> getAnswers(String questionId) {
    return _remoteDataSource.getAnswers(questionId);
  }

  @override
  Future<bool> createAnswer({
    required String content,
    required String questionId,
  }) {
    final model = AnswerModel(
      id: '',
      questionId: questionId,
      userId: '',
      authorName: '',
      content: content,
      upVotes: 0,
      downVotes: 0,
      isAccepted: false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
    return _remoteDataSource.createAnswer(model);
  }

  @override
  Future<bool> voteAnswer(String id, int type) {
    return _remoteDataSource.voteAnswer(id, type);
  }

  @override
  Future<bool> acceptAnswer(String answerId, String questionId) {
    return _remoteDataSource.acceptAnswer(answerId, questionId);
  }
}
