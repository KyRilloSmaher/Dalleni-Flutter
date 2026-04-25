/// Request body for POST /api/auth/reset-password
class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  final String email;
  final String code;
  final String newPassword;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email,
    'code': code,
    'newPassword': newPassword,
  };
}
