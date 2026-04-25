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

  @override
  Future<bool> verifyOtp({required String email, required String code}) async {
    final session = await _remoteDataSource.verifyOtp(
      VerfiyOTPRequestModel(email: email, code: code),
    );
    return session;
  }

  @override
  Future<AuthSession> refreshToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    final session = await _remoteDataSource.refreshToken(
      RefreshTokenRequestModel(token: accessToken, refreshToken: refreshToken),
    );
    await _persistSession(session);
    return session;
  }

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

  @override
  Future<void> restoreSession() async {
    final accessToken = _localStorageService.getToken();
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    _tokenScheduler.schedule(
      accessToken: accessToken,
      onRefreshDue: () async {
        final storedAccessToken = _localStorageService.getToken();
        final storedRefreshToken = _localStorageService.getRefreshToken();

        if (storedAccessToken == null || storedRefreshToken == null) {
          await logout();
          return;
        }

        try {
          await refreshToken(
            accessToken: storedAccessToken,
            refreshToken: storedRefreshToken,
          );
        } catch (_) {
          await logout();
        }
      },
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignore errors on logout to ensure local cleanup always happens
    }
    _tokenScheduler.cancel();
    await _localStorageService.clearSession();
  }

  // ─── Forgot-password flow ──────────────────────────────────────────────────

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

  Future<void> _persistSession(AuthSession session) async {
    await _localStorageService.saveToken(session.accessToken);
    await _localStorageService.saveRefreshToken(session.refreshToken);

    final userId = JwtUtils.extractUserId(session.accessToken);
    if (userId != null && userId.isNotEmpty) {
      await _localStorageService.saveUserId(userId);
    }

    _tokenScheduler.schedule(
      accessToken: session.accessToken,
      onRefreshDue: () async {
        final latestAccessToken = _localStorageService.getToken();
        final latestRefreshToken = _localStorageService.getRefreshToken();
        if (latestAccessToken == null || latestRefreshToken == null) {
          await logout();
          return;
        }

        try {
          await refreshToken(
            accessToken: latestAccessToken,
            refreshToken: latestRefreshToken,
          );
        } catch (_) {
          await logout();
        }
      },
    );
  }
}
