class LoginRequestModel {
  const LoginRequestModel({
    required this.userNameOrEmail,
    required this.password,
  });

  final String userNameOrEmail;
  final String password;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'Email': userNameOrEmail,
      'password': password,
    };
  }
}
