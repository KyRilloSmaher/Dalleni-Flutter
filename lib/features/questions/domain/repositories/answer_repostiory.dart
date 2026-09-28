import 'package:dalleni/features/questions/data/models/question_model.dart';
import 'package:dalleni/features/questions/domain/entities/question_entity.dart';

abstract class AnswersRepository {
  Future<List<Answer>> getAnswers(String questionId);
  Future<bool> createAnswer({
    required String content,
    required String questionId,
  });
  Future<bool> voteAnswer(String id, int type);
  Future<bool> removevote(String voteid);
  Future<bool> acceptAnswer(String answerId);
  Future<bool> unacceptAnswer(String answerId);
    Future<bool> deleteAnswer(String answerId);
  Future<String?> markAnswer(String answerId);
  Future<String?> markUnsuccessfulAnswer(String answerId);
  Future<bool> removemarkAnswer(String successRecordId);
     Future<Map<String, String>> getUserAnswerVotes();
}
