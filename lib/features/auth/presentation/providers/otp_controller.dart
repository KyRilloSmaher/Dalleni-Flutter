import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';

class OtpState {
  final String code;
  final bool isSubmitting;
  final String? errorMessage;

  const OtpState({
    required this.code,
    required this.isSubmitting,
    this.errorMessage,
  });

  factory OtpState.initial() {
    return const OtpState(code: '', isSubmitting: false);
  }

  OtpState copyWith({
    String? code,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OtpState(
      code: code ?? this.code,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class OtpController extends Notifier<OtpState> {
  @override
  OtpState build() => OtpState.initial();

  void setCode(String value) {
    state = state.copyWith(code: value, clearError: true);
  }

  Future<void> verify({required String email}) async {
    state = state.copyWith(isSubmitting: true);

    try {
      final repo = ref.read(authRepositoryProvider);

      await repo.verifyOtp(email: email, code: state.code);

      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: "Invalid OTP");
    }
  }
}

final otpControllerProvider = NotifierProvider<OtpController, OtpState>(
  OtpController.new,
);
