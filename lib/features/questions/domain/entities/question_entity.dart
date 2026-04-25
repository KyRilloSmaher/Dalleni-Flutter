class QuestionTag {
  const QuestionTag({
    required this.id,
    required this.name,
    required this.slug,
    required this.questionCount,
  });

  final String id;
  final String name;
  final String slug;
  final int questionCount;
}

class QuestionCategory {
  const QuestionCategory({
    required this.id,
    required this.name,
    required this.questionCount,
  });

  final String id;
  final String name;
  final int questionCount;
}

class Question {
  const Question({
    required this.id,
    required this.title,
    required this.userId,
    required this.authorName,
    required this.upVotes,
    required this.downVotes,
    required this.views,
    required this.answersCount,
    required this.isClosed,
    required this.createdAt,
    required this.tags,
    this.content,
    this.categoryId,
    this.categoryName,
    this.authorProfileImageUrl,
    this.authorReputation,
    this.acceptedAnswerId,
    this.answers = const <Answer>[],
  });

  final String id;
  final String title;
  final String userId;
  final String authorName;
  final int upVotes;
  final int downVotes;
  final int views;
  final int answersCount;
  final bool isClosed;
  final DateTime createdAt;
  final List<QuestionTag> tags;
  final String? content;
  final String? categoryId;
  final String? categoryName;
  final String? authorProfileImageUrl;
  final int? authorReputation;
  final String? acceptedAnswerId;
  final List<Answer> answers;

  String get body => content ?? '';
  int get upvotes => upVotes;
  int get answerCount => answersCount;
  DateTime get timestamp => createdAt;
  String? get authorProfileImage => authorProfileImageUrl;
  bool get isVerified => false;

  Question copyWith({
    String? id,
    String? title,
    String? userId,
    String? authorName,
    int? upVotes,
    int? downVotes,
    int? views,
    int? answersCount,
    bool? isClosed,
    DateTime? createdAt,
    List<QuestionTag>? tags,
    String? content,
    String? categoryId,
    String? categoryName,
    String? authorProfileImageUrl,
    int? authorReputation,
    String? acceptedAnswerId,
    List<Answer>? answers,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      upVotes: upVotes ?? this.upVotes,
      downVotes: downVotes ?? this.downVotes,
      views: views ?? this.views,
      answersCount: answersCount ?? this.answersCount,
      isClosed: isClosed ?? this.isClosed,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      authorProfileImageUrl:
          authorProfileImageUrl ?? this.authorProfileImageUrl,
      authorReputation: authorReputation ?? this.authorReputation,
      acceptedAnswerId: acceptedAnswerId ?? this.acceptedAnswerId,
      answers: answers ?? this.answers,
    );
  }
}

class SavedQuestion {
  const SavedQuestion({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.savedAt,
    required this.question,
  });

  final String id;
  final String userId;
  final String questionId;
  final DateTime savedAt;
  final Question question;
}

class Answer {
  const Answer({
    required this.id,
    required this.questionId,
    required this.content,
    required this.userId,
    required this.authorName,
    required this.upVotes,
    required this.downVotes,
    required this.isAccepted,
    required this.createdAt,
    this.authorProfileImageUrl,
    this.authorReputation,
  });

  final String id;
  final String questionId;
  final String content;
  final String userId;
  final String authorName;
  final String? authorProfileImageUrl;
  final int? authorReputation;
  final int upVotes;
  final int downVotes;
  final bool isAccepted;
  final DateTime createdAt;

  int get upvotes => upVotes;
  bool get isApproved => isAccepted;
  DateTime get timestamp => createdAt;

  Answer copyWith({
    String? id,
    String? questionId,
    String? content,
    String? userId,
    String? authorName,
    String? authorProfileImageUrl,
    int? authorReputation,
    int? upVotes,
    int? downVotes,
    bool? isAccepted,
    DateTime? createdAt,
  }) {
    return Answer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorProfileImageUrl:
          authorProfileImageUrl ?? this.authorProfileImageUrl,
      authorReputation: authorReputation ?? this.authorReputation,
      upVotes: upVotes ?? this.upVotes,
      downVotes: downVotes ?? this.downVotes,
      isAccepted: isAccepted ?? this.isAccepted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
