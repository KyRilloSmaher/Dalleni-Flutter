import '../../domain/entities/question_entity.dart';
import 'question_model.dart';

class SavedQuestionModel extends SavedQuestion {
  const SavedQuestionModel({
    required super.id,
    required super.userId,
    required super.questionId,
    required super.savedAt,
    required super.question,
  });

  factory SavedQuestionModel.fromJson(Map<String, dynamic> json) {
    return SavedQuestionModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      questionId: json['questionId']?.toString() ?? '',
      savedAt:
          DateTime.tryParse(json['savedAt'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      question: QuestionModel.fromJson(
        json['question'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }
}
