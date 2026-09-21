import 'package:dalleni/features/questions/domain/entities/question_entity.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.reputation,
    required this.answersCount,
    required this.questionsCount,
    this.phoneNumber,
    this.profileImageUrl,
    this.lastLoginAt,
  });

  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final int reputation;
  final int answersCount;
  final int questionsCount;
  final DateTime? lastLoginAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          userName == other.userName &&
          email == other.email &&
          phoneNumber == other.phoneNumber &&
          profileImageUrl == other.profileImageUrl &&
          reputation == other.reputation &&
          answersCount == other.answersCount &&
          questionsCount == other.questionsCount &&
          lastLoginAt == other.lastLoginAt;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      userName.hashCode ^
      email.hashCode ^
      phoneNumber.hashCode ^
      profileImageUrl.hashCode ^
      reputation.hashCode ^
      answersCount.hashCode ^
      questionsCount.hashCode ^
      lastLoginAt.hashCode;
}


class QuestionUser {
  const QuestionUser({
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