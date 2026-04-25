/// Request body for POST /api/auth/confirm-reset-password-code
class ConfirmResetCodeRequestModel {
  const ConfirmResetCodeRequestModel({required this.email, required this.code});

  final String email;
  final String code;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email,
    'code': code,
  };
}
