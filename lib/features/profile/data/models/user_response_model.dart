import '../../domain/entities/user_profile.dart';

class UserResponseDto extends UserProfile {
  const UserResponseDto({
    required super.id,
    required super.fullName,
    required super.userName,
    required super.email,
    required super.reputation,
    required super.answersCount,
    required super.questionsCount,
    super.phoneNumber,
    super.profileImageUrl,
    super.lastLoginAt,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    return UserResponseDto(
      id: json['id'] as String? ?? json['Id'] as String? ?? '',
      fullName:
          json['fullName'] as String? ?? json['FullName'] as String? ?? '',
      userName:
          json['userName'] as String? ?? json['UserName'] as String? ?? '',
      email: json['email'] as String? ?? json['Email'] as String? ?? '',
      phoneNumber:
          json['phoneNumber'] as String? ?? json['PhoneNumber'] as String?,
      profileImageUrl:
          json['profileImageUrl'] as String? ??
          json['ProfileImageUrl'] as String?,
      reputation: json['reputation'] as int? ?? json['Reputation'] as int? ?? 0,
      answersCount:
          json['answersCount'] as int? ?? json['AnswersCount'] as int? ?? 0,
      questionsCount:
          json['questionsCount'] as int? ?? json['QuestionsCount'] as int? ?? 0,
      lastLoginAt: json['lastLoginAt'] != null || json['LastLoginAt'] != null
          ? DateTime.tryParse(
              json['lastLoginAt'] as String? ??
                  json['LastLoginAt'] as String? ??
                  '',
            )
          : null,
    );
  }
}
