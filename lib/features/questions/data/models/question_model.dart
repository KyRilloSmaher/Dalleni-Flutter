import '../../domain/entities/question_entity.dart';
import 'tag_model.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.title,
    required super.userId,
    required super.authorName,
    required super.upVotes,
    required super.downVotes,
    required super.views,
    required super.answersCount,
    required super.isClosed,
    required super.createdAt,
    required super.tags,
    super.content,
    super.categoryId,
    super.categoryName,
    super.authorProfileImageUrl,
    super.authorReputation,
    super.acceptedAnswerId,
    super.answers,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      userId: json['userId']?.toString() ?? '',
      authorName: json['authorName'] as String? ?? '',
      upVotes: (json['upVotes'] as num?)?.toInt() ?? 0,
      downVotes: (json['downVotes'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      answersCount: (json['answersCount'] as num?)?.toInt() ?? 0,
      isClosed: json['isClosed'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      tags: (json['tags'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(TagModel.fromJson)
          .toList(growable: false),
      content: json['content'] as String?,
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName'] as String?,
      authorProfileImageUrl: json['authorProfileImageUrl'] as String?,
      authorReputation: (json['authorReputation'] as num?)?.toInt(),
      acceptedAnswerId: json['acceptedAnswerId']?.toString(),
      answers: (json['answers'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(AnswerModel.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return <String, dynamic>{
      'title': title,
      'content': content ?? '',
      'categoryId': categoryId,
      'tags': tags.map((tag) => tag.name).toList(growable: false),
    };
  }
}

class AnswerModel extends Answer {
  const AnswerModel({
    required super.id,
    required super.questionId,
    required super.content,
    required super.userId,
    required super.authorName,
    required super.upVotes,
    required super.downVotes,
    required super.isAccepted,
    required super.createdAt,
    super.authorProfileImageUrl,
    super.authorReputation,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id']?.toString() ?? '',
      questionId: json['questionId']?.toString() ?? '',
      content: json['content'] as String? ?? '',
      userId: json['userId']?.toString() ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorProfileImageUrl: json['authorProfileImageUrl'] as String?,
      authorReputation: (json['authorReputation'] as num?)?.toInt(),
      upVotes: (json['upVotes'] as num?)?.toInt() ?? 0,
      downVotes: (json['downVotes'] as num?)?.toInt() ?? 0,
      isAccepted: json['isAccepted'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return <String, dynamic>{'content': content, 'questionId': questionId};
  }
}
