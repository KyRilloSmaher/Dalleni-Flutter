/// Request body for POST /api/auth/send-reset-code
/// and POST /api/auth/resend-reset-code
class ForgotPasswordRequestModel {
  const ForgotPasswordRequestModel({required this.email});

  final String email;

  Map<String, dynamic> toJson() => <String, dynamic>{'email': email};
}
