import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> refreshToken({
    required String accessToken,
    required String refreshToken,
  });

  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String userName,
    required String email,
    required String password,
    required String phoneNumber,
    String? profileImagePath,
  });

  Future<bool> verifyOtp({required String email, required String code});

  Future<void> restoreSession();

  Future<void> logout();

  // ─── Forgot-password flow ──────────────────────────────────────────────────

  /// Sends a reset-code to [email].  POST /api/auth/send-reset-code
  Future<bool> sendResetCode({required String email});

  /// Verifies that [code] matches what the server sent to [email].
  /// POST /api/auth/confirm-reset-password-code
  Future<bool> confirmResetCode({required String email, required String code});

  /// Sets a [newPassword] for [email] after code has been confirmed.
  /// POST /api/auth/reset-password
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  });

  /// Re-sends the reset code to [email].  POST /api/auth/resend-reset-code
  Future<bool> resendResetCode({required String email});
}
