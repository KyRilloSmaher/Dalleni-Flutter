import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/external_auth_launcher.dart';
import '../../domain/entities/auth_session.dart';

class LoginFormState {
  const LoginFormState({
    required this.email,
    required this.password,
    required this.isSubmitting,
    required this.isReady,
    this.errorMessage,
    this.session,
  });

  factory LoginFormState.initial() {
    return const LoginFormState(
      email: '',
      password: '',
      isSubmitting: false,
      isReady: true,
    );
  }

  final String email;
  final String password;
  final bool isSubmitting;
  final bool isReady;
  final String? errorMessage;
  final AuthSession? session;

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isSubmitting,
    bool? isReady,
    String? errorMessage,
    AuthSession? session,
    bool clearError = false,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isReady: isReady ?? this.isReady,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      session: session ?? this.session,
    );
  }
}

class LoginController extends Notifier<AsyncValue<LoginFormState>> {
  @override
  AsyncValue<LoginFormState> build() {
    return AsyncValue.data(LoginFormState.initial());
  }

  void setEmail(String value) {
    final currentState = state.valueOrNull ?? LoginFormState.initial();
    state = AsyncValue.data(
      currentState.copyWith(email: value, clearError: true),
    );
  }

  void setPassword(String value) {
    final currentState = state.valueOrNull ?? LoginFormState.initial();
    state = AsyncValue.data(
      currentState.copyWith(password: value, clearError: true),
    );
  }

  Future<void> submit(
    BuildContext context, {
    required String identifier,
    required String password,
  }) async {
    final localizations = AppLocalizations.of(context);
    final currentState = state.valueOrNull ?? LoginFormState.initial();
    state = AsyncValue.data(
      currentState.copyWith(
        email: identifier.trim(),
        password: password,
        isSubmitting: true,
        clearError: true,
      ),
    );

    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: identifier.trim(), password: password);
      state = AsyncValue.data(
        (state.valueOrNull ?? currentState).copyWith(
          email: identifier.trim(),
          password: password,
          isSubmitting: false,
          session: session,
        ),
      );
    } on ApiException catch (error) {
      final fallbackMessage = error.message == 'TIMEOUT'
          ? localizations.translate('networkTimeout')
          : _resolveBackendMessage(localizations, error);
      state = AsyncValue.data(
        (state.valueOrNull ?? currentState).copyWith(
          email: identifier.trim(),
          password: password,
          isSubmitting: false,
          errorMessage: fallbackMessage,
        ),
      );
    } catch (_) {
      state = AsyncValue.data(
        (state.valueOrNull ?? currentState).copyWith(
          email: identifier.trim(),
          password: password,
          isSubmitting: false,
          errorMessage: localizations.translate('genericError'),
        ),
      );
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    final currentState = state.valueOrNull ?? LoginFormState.initial();
    state = AsyncValue.data(
      currentState.copyWith(isSubmitting: true, clearError: true),
    );

    final launched = await ref.read(externalAuthLauncherProvider).launch(
      '${AppConstants.baseUrl}/auth/google-login',
    );

    if (launched) {
      state = AsyncValue.data(
        (state.valueOrNull ?? currentState).copyWith(isSubmitting: false),
      );
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        isSubmitting: false,
        errorMessage: context.l10n.translate('googleLoginUnavailable'),
      ),
    );
  }

  String _resolveBackendMessage(
    AppLocalizations localizations,
    ApiException error,
  ) {
    if (error.errors == null || error.errors!.isEmpty) {
      return error.message.isEmpty
          ? localizations.translate('genericError')
          : error.message;
    }

    return error.errors!.values.first.first;
  }
}

final loginControllerProvider =
    NotifierProvider<LoginController, AsyncValue<LoginFormState>>(
      LoginController.new,
    );
