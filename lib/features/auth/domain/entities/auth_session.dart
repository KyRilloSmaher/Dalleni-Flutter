class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;
}
