import '../../domain/entities/question_entity.dart';

class CategoryModel extends QuestionCategory {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.questionCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
    );
  }
}
