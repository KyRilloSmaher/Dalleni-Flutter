import '../../domain/entities/question_entity.dart';

class TagModel extends QuestionTag {
  const TagModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.questionCount,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
    );
  }
}
