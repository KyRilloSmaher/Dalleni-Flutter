import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class ForgotPasswordState {
  const ForgotPasswordState({
    required this.email,
    required this.isSubmitting,
    this.errorMessage,
    this.didSucceed = false,
  });

  factory ForgotPasswordState.initial() =>
      const ForgotPasswordState(email: '', isSubmitting: false);

  final String email;
  final bool isSubmitting;
  final String? errorMessage;

  /// True once the API returns success → navigate to confirm-code screen.
  final bool didSucceed;

  ForgotPasswordState copyWith({
    String? email,
    bool? isSubmitting,
    String? errorMessage,
    bool? didSucceed,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      didSucceed: clearSuccess ? false : didSucceed ?? this.didSucceed,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => ForgotPasswordState.initial();

  void setEmail(String value) {
    state = state.copyWith(email: value, clearError: true, clearSuccess: true);
  }

  /// Calls POST /api/auth/send-reset-code
  Future<void> submit() async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final success = await ref
          .read(authRepositoryProvider)
          .sendResetCode(email: state.email);

      state = state.copyWith(
        isSubmitting: false,
        didSucceed: success,
        // If API returns false without throwing, surface a generic error.
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

final forgotPasswordControllerProvider =
    NotifierProvider<ForgotPasswordController, ForgotPasswordState>(
      ForgotPasswordController.new,
    );
