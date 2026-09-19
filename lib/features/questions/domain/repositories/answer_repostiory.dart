import 'package:dalleni/features/questions/data/models/question_model.dart';
import 'package:dalleni/features/questions/domain/entities/question_entity.dart';

abstract class AnswersRepository {
  Future<List<Answer>> getAnswers(String questionId);
  Future<bool> createAnswer({
    required String content,
    required String questionId,
  });
  Future<bool> voteAnswer(String id, int type);
  Future<bool> acceptAnswer(String answerId, String questionId);
    Future<bool> deleteAnswer(String answerId);
}
