class RefreshTokenRequestModel {
  const RefreshTokenRequestModel({
    required this.token,
    required this.refreshToken,
  });

  final String token;
  final String refreshToken;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'token': token, 'refreshToken': refreshToken};
  }
}
