import 'package:dalleni/features/questions/domain/repositories/answer_repostiory.dart';

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
      upVotedByCurrentUser: false,
      downVotedByCurrentUser: false,
      markedSuccessedByCurrentUser: false,
      markedUnsuccessedByCurrentUser: false,
    );
    return _remoteDataSource.createAnswer(model);
  }

  @override
  Future<bool> deleteAnswer(String answerId) {
    return _remoteDataSource.deleteAnswer(answerId);
  }

  @override
  Future<bool> voteAnswer(String id, int type) {
    return _remoteDataSource.voteAnswer(id, type);
  }

  @override
  Future<bool> removevote(String voteid) {
    return _remoteDataSource.removevote(voteid);
  }

  @override
  Future<bool> acceptAnswer(String answerId) {
    return _remoteDataSource.acceptAnswer(answerId);
  }

  @override
  Future<bool> unacceptAnswer(String answerId) {
    return _remoteDataSource.unacceptAnswer(answerId);
  }

  @override
  Future<String?> markAnswer(String answerId) {
    return _remoteDataSource.markAnswer(answerId);
  }

  @override
  Future<String?> markUnsuccessfulAnswer(String answerId) {
    return _remoteDataSource.markUnsuccessfulAnswer(answerId);
  }

  @override
  Future<bool> removemarkAnswer(String successRecordId) {
    return _remoteDataSource.removemarkAnswer(successRecordId);
  }

  @override
  Future<Map<String, String>> getUserAnswerVotes() {
    return _remoteDataSource.getUserAnswerVotes();
  }
}
