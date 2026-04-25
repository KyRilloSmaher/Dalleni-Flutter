import '../../../../core/models/paged_list.dart';
import '../entities/question_entity.dart';

abstract class QuestionsRepository {
  Future<PagedList<Question>> getQuestions({
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<PagedList<Question>> searchQuestions({
    required String query,
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<PagedList<Question>> getQuestionsByTag({
    required String tagId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<PagedList<Question>> getQuestionsByCategory({
    required String categoryId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<Question> getQuestion(String id);

  Future<bool> createQuestion({
    required String title,
    required String content,
    required String categoryId,
    required List<String> tags,
  });

  Future<bool> voteQuestion(String id, int type);
  Future<List<QuestionCategory>> getCategories();
  Future<List<QuestionTag>> getTags({int pageNumber = 1, int pageSize = 20});
  Future<bool> saveQuestion(String questionId, String userId);
  Future<bool> unsaveQuestion(String savedQuestionId);
  Future<List<SavedQuestion>> getSavedQuestions();
}

abstract class AnswersRepository {
  Future<List<Answer>> getAnswers(String questionId);
  Future<bool> createAnswer({
    required String content,
    required String questionId,
  });
  Future<bool> voteAnswer(String id, int type);
  Future<bool> acceptAnswer(String answerId, String questionId);
}
