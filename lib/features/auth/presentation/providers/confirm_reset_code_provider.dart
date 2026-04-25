import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class ConfirmResetCodeState {
  const ConfirmResetCodeState({
    required this.code,
    required this.isSubmitting,
    required this.isResending,
    this.errorMessage,
    this.didSucceed = false,
    this.resendSucceeded = false,
  });

  factory ConfirmResetCodeState.initial() => const ConfirmResetCodeState(
    code: '',
    isSubmitting: false,
    isResending: false,
  );

  final String code;
  final bool isSubmitting;
  final bool isResending;
  final String? errorMessage;

  /// True once confirmation succeeds → navigate to reset-password screen.
  final bool didSucceed;

  /// True once resend succeeds → restart the countdown timer in the UI.
  final bool resendSucceeded;

  ConfirmResetCodeState copyWith({
    String? code,
    bool? isSubmitting,
    bool? isResending,
    String? errorMessage,
    bool? didSucceed,
    bool? resendSucceeded,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearResend = false,
  }) {
    return ConfirmResetCodeState(
      code: code ?? this.code,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isResending: isResending ?? this.isResending,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      didSucceed: clearSuccess ? false : didSucceed ?? this.didSucceed,
      resendSucceeded: clearResend
          ? false
          : resendSucceeded ?? this.resendSucceeded,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ConfirmResetCodeController extends Notifier<ConfirmResetCodeState> {
  @override
  ConfirmResetCodeState build() => ConfirmResetCodeState.initial();

  void setCode(String value) {
    state = state.copyWith(code: value, clearError: true);
  }

  /// Calls POST /api/auth/confirm-reset-password-code
  Future<void> confirm({required String email}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final success = await ref
          .read(authRepositoryProvider)
          .confirmResetCode(email: email, code: state.code);

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

  /// Calls POST /api/auth/resend-reset-code
  Future<void> resend({required String email}) async {
    state = state.copyWith(
      isResending: true,
      clearError: true,
      clearResend: true,
    );

    try {
      final success = await ref
          .read(authRepositoryProvider)
          .resendResetCode(email: email);

      state = state.copyWith(
        isResending: false,
        resendSucceeded: success,
        errorMessage: success ? null : 'genericError',
      );
    } on ApiException catch (error) {
      state = state.copyWith(
        isResending: false,
        errorMessage: _resolveError(error),
      );
    } catch (_) {
      state = state.copyWith(isResending: false, errorMessage: 'genericError');
    }
  }

  void resetSuccess() => state = state.copyWith(clearSuccess: true);
  void resetResend() => state = state.copyWith(clearResend: true);

  String _resolveError(ApiException error) {
    if (error.message == 'TIMEOUT') return 'networkTimeout';
    if (error.errors != null && error.errors!.isNotEmpty) {
      return error.errors!.values.first.first;
    }
    return error.message.isEmpty ? 'genericError' : error.message;
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final confirmResetCodeControllerProvider =
    NotifierProvider<ConfirmResetCodeController, ConfirmResetCodeState>(
      ConfirmResetCodeController.new,
    );
