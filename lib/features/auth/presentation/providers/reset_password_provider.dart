import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class ResetPasswordState {
  const ResetPasswordState({
    required this.newPassword,
    required this.confirmPassword,
    required this.isSubmitting,
    required this.obscurePassword,
    required this.obscureConfirm,
    this.errorMessage,
    this.didSucceed = false,
  });

  factory ResetPasswordState.initial() => const ResetPasswordState(
    newPassword: '',
    confirmPassword: '',
    isSubmitting: false,
    obscurePassword: true,
    obscureConfirm: true,
  );

  final String newPassword;
  final String confirmPassword;
  final bool isSubmitting;
  final bool obscurePassword;
  final bool obscureConfirm;
  final String? errorMessage;

  /// True once the server confirms the password reset → navigate to login.
  final bool didSucceed;

  ResetPasswordState copyWith({
    String? newPassword,
    String? confirmPassword,
    bool? isSubmitting,
    bool? obscurePassword,
    bool? obscureConfirm,
    String? errorMessage,
    bool? didSucceed,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ResetPasswordState(
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      didSucceed: clearSuccess ? false : didSucceed ?? this.didSucceed,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ResetPasswordController extends Notifier<ResetPasswordState> {
  @override
  ResetPasswordState build() => ResetPasswordState.initial();

  void setNewPassword(String value) =>
      state = state.copyWith(newPassword: value, clearError: true);

  void setConfirmPassword(String value) =>
      state = state.copyWith(confirmPassword: value, clearError: true);

  void toggleObscurePassword() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void toggleObscureConfirm() =>
      state = state.copyWith(obscureConfirm: !state.obscureConfirm);

  /// Calls POST /api/auth/reset-password.
  /// Validation (passwords match + min-length) is handled in the Form; the
  /// provider trusts the UI has already validated before calling [submit].
  Future<void> submit({required String email}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final success = await ref
          .read(authRepositoryProvider)
          .resetPassword(email: email, newPassword: state.newPassword);

      state = state.copyWith(
        isSubmitting: false,
        didSucceed: success,
        errorMessage: success ? null : 'genericError',
      );
    } on ApiException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _resolveError(error),
      );
    } catch (_) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'genericError');
    }
  }

  void resetSuccess() => state = state.copyWith(clearSuccess: true);

  String _resolveError(ApiException error) {
    if (error.message == 'TIMEOUT') return 'networkTimeout';
    if (error.errors != null && error.errors!.isNotEmpty) {
      return error.errors!.values.first.first;
    }
    return error.message.isEmpty ? 'genericError' : error.message;
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final resetPasswordControllerProvider =
    NotifierProvider<ResetPasswordController, ResetPasswordState>(
      ResetPasswordController.new,
    );
