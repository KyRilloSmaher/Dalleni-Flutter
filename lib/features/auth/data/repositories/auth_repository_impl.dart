import 'package:dalleni/core/helper/formart_utc.dart';

import '../../../../core/network/jwt_utils.dart';
import '../../../../core/services/token_scheduler.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/confirm_reset_code_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/login_request_model.dart';
import '../models/refresh_token_request_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/sign_up_request_model.dart';
import '../models/verfiy_identitiy_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required LocalStorageService localStorageService,
    required TokenScheduler tokenScheduler,
  }) : _remoteDataSource = remoteDataSource,
       _localStorageService = localStorageService,
       _tokenScheduler = tokenScheduler;

  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorageService _localStorageService;
  final TokenScheduler _tokenScheduler;

  // ─── Login ────────────────────────────────────────────────────────────────

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _remoteDataSource.login(
      LoginRequestModel(userNameOrEmail: email, password: password),
    );

    await _persistSession(session);

    return session;
  }

  // ─── Verify OTP ───────────────────────────────────────────────────────────

  @override
  Future<bool> verifyOtp({required String email, required String code}) async {
    final session = await _remoteDataSource.verifyOtp(
      VerfiyOTPRequestModel(email: email, code: code),
    );

    return session;
  }

  // ─── Refresh Token ────────────────────────────────────────────────────────

  @override
  Future<AuthSession> RefreshToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    print('[AUTH DEBUG] ===== REFRESH TOKEN =====');
    print(
      '[AUTH DEBUG] Refresh started at: '
      '${DateTime.now().toUtc()}',
    );

    print(
      '[AUTH DEBUG] Access token expiry before refresh: '
      '${JwtUtils.extractExpiry(accessToken)}',
    );
    // NOTE: refreshToken is opaque (not a JWT). Never call
    // JwtUtils.extractExpiry(refreshToken) — it will throw and abort this
    // method before the actual refresh API call ever runs.

    final session = await _remoteDataSource.refreshToken(
      RefreshTokenRequestModel(token: accessToken, refreshToken: refreshToken),
    );
    print('[AUTH DEBUG] Refresh API returned successfully');

    print(
      '[AUTH DEBUG] New access expiry: '
      '${JwtUtils.extractExpiry(session.accessToken)}',
    );
    // NOTE: same reasoning — do not decode session.refreshToken as a JWT.

    await _persistSession(session);

    return session;
  }

  // ─── Sign Up ──────────────────────────────────────────────────────────────

  @override
  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String userName,
    required String email,
    required String password,
    required String phoneNumber,
    String? profileImagePath,
  }) {
    return _remoteDataSource.signUp(
      SignUpRequestModel(
        firstName: firstName,
        lastName: lastName,
        userName: userName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        profileImagePath: profileImagePath,
      ),
    );
  }

  // ─── Restore Session ──────────────────────────────────────────────────────
  @override
  Future<void> restoreSession() async {
    print(
      '[AUTH DEBUG] AuthRepositoryImpl.restoreSession() '
      '(instance: ${identityHashCode(_localStorageService)})',
    );

    final accessToken = _localStorageService.getToken();
    final refreshToken = _localStorageService.getRefreshToken();
    final accessExpiresAt = _localStorageService.getAccessTokenExpiresAt();
    final refreshExpiresAt = _localStorageService.getrefreashTokenExpiresAt();

    print('[AUTH DEBUG] ===== RESTORE SESSION =====');
    print(
      '[AUTH DEBUG] accessToken exists: ${accessToken != null && accessToken.isNotEmpty}',
    );
    print(
      '[AUTH DEBUG] refreshToken exists: ${refreshToken != null && refreshToken.isNotEmpty}',
    );
    print('[AUTH DEBUG] accessTokenExpiresAt: $accessExpiresAt');
    print('[AUTH DEBUG] refreshTokenExpiresAt: $refreshExpiresAt');

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      print(
        '[AUTH DEBUG] Restore session skipped. Access token or refresh token is missing.',
      );
      return;
    }

    final now = DateTime.now().toUtc();

    // Logout only when we KNOW the refresh token expired.
    // A missing/null refreshTokenExpiresAt must NEVER trigger a logout.
    if (refreshExpiresAt != null && !refreshExpiresAt.isAfter(now)) {
      print('[AUTH DEBUG] Refresh token has actually expired. Logging out.');
      await logout();
      return;
    }

    if (accessExpiresAt == null) {
      print(
        '[AUTH DEBUG] Access token expiry is missing. Cannot schedule proactive refresh.',
      );
      return;
    }

    print('[AUTH DEBUG] Restore access token expires at: $accessExpiresAt');
    print('[AUTH DEBUG] Restore current UTC: $now');

    // Access token already expired.
    if (!accessExpiresAt.isAfter(now)) {
      print(
        '[AUTH DEBUG] Access token already expired. Refreshing immediately.',
      );
      try {
        await RefreshToken(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      } catch (e) {
        print('[AUTH DEBUG] Restore refresh failed: $e. Calling logout().');
        await logout();
      }
      return;
    }

    // Access token is still valid.
    _scheduleTokenRefresh(accessExpiresAt);
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    print(
      '[AUTH DEBUG] AuthRepositoryImpl.logout() called '
      '(instance: ${identityHashCode(_localStorageService)})',
    );

    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignore logout API errors.
      // Local cleanup must always happen.
    }

    _tokenScheduler.cancel();

    await _localStorageService.clearSession();
  }

  // ─── Forgot Password ─────────────────────────────────────────────────────

  @override
  Future<bool> sendResetCode({required String email}) =>
      _remoteDataSource.sendResetCode(ForgotPasswordRequestModel(email: email));

  @override
  Future<bool> confirmResetCode({
    required String email,
    required String code,
  }) => _remoteDataSource.confirmResetCode(
    ConfirmResetCodeRequestModel(email: email, code: code),
  );

  @override
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) => _remoteDataSource.resetPassword(
    ResetPasswordRequestModel(email: email, code: '', newPassword: newPassword),
  );

  @override
  Future<bool> resendResetCode({required String email}) => _remoteDataSource
      .resendResetCode(ForgotPasswordRequestModel(email: email));

  // ─── Persist Session ─────────────────────────────────────────────────────
  Future<void> _persistSession(AuthSession session) async {
    print('[AUTH DEBUG] ===== PERSIST SESSION =====');

    final accessExpiry = session.accessTokenExpiresAt;
    final refreshExpiry = session.refreshTokenExpiresAt;

    print('[AUTH DEBUG] NEW access token expiry: ${formatUtc(accessExpiry)}');
    print(
      '[AUTH DEBUG] NEW refresh token expiry: ${formatUtc(refreshExpiry!)}',
    );
    print('[AUTH DEBUG] Current UTC: ${formatUtc(DateTime.now())}');

    final now = DateTime.now();
    final nowUtc = now.toUtc();

    print('[AUTH DEBUG] Local now: $now');
    print('[AUTH DEBUG] UTC now: $nowUtc');
    print('[AUTH DEBUG] UTC ISO: ${nowUtc.toIso8601String()}');
    print('[AUTH DEBUG] Local ISO: ${now.toIso8601String()}');
    // Save tokens + expirations exactly once, in one place.
    await _localStorageService.saveToken(session.accessToken);
    await _localStorageService.saveRefreshToken(session.refreshToken);
    await _localStorageService.saveAccessTokenExpiresAt(
      session.accessTokenExpiresAt,
    );
    await _localStorageService.saveRefereshTokenExpiresAt(
      session.refreshTokenExpiresAt,
    );

    final userId = JwtUtils.extractUserId(session.accessToken);
    if (userId != null && userId.isNotEmpty) {
      await _localStorageService.saveUserId(userId);
    }

    print(
      '[AUTH DEBUG] AFTER SAVE ACCESS: ${session.accessToken.isNotEmpty} '
      '(instance: ${identityHashCode(_localStorageService)})',
    );
    print(
      '[AUTH DEBUG] AFTER SAVE REFRESH: ${session.refreshToken.isNotEmpty} '
      '(instance: ${identityHashCode(_localStorageService)})',
    );

    // Schedule using the NEW access token expiry — never a JWT decode.
    _scheduleTokenRefresh(session.accessTokenExpiresAt);
  }

  // ─── Token Scheduler ──────────────────────────────────────────────────────

  void _scheduleTokenRefresh(DateTime accessTokenExpiresAt) {
    _tokenScheduler.schedule(
      accessTokenExpiresAt: accessTokenExpiresAt,
      onRefreshDue: () async {
        final latestAccessToken = _localStorageService.getToken();

        final latestRefreshToken = _localStorageService.getRefreshToken();

        if (latestAccessToken == null ||
            latestAccessToken.isEmpty ||
            latestRefreshToken == null ||
            latestRefreshToken.isEmpty) {
          print(
            '[AUTH DEBUG] Proactive refresh due but '
            'tokens are missing. Calling logout().',
          );

          await logout();
          return;
        }

        try {
          print(
            '[AUTH DEBUG] Proactive refresh due. '
            'Executing refreshToken().',
          );

          await RefreshToken(
            accessToken: latestAccessToken,
            refreshToken: latestRefreshToken,
          );
        } catch (e) {
          print(
            '[AUTH DEBUG] Proactive refresh failed: $e. '
            'Calling logout().',
          );

          await logout();
        }
      },
    );
  }
}
