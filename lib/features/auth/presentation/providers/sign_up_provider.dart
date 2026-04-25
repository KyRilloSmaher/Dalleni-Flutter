import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

class SignUpFormState {
  const SignUpFormState({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.isSubmitting,
    this.profileImagePath,
    this.errorMessage,
    this.didComplete = false,
  });

  factory SignUpFormState.initial() {
    return const SignUpFormState(
      firstName: '',
      lastName: '',
      userName: '',
      email: '',
      password: '',
      phoneNumber: '',
      isSubmitting: false,
    );
  }

  final String firstName;
  final String lastName;
  final String userName;
  final String email;
  final String password;
  final String phoneNumber;
  final String? profileImagePath;
  final bool isSubmitting;
  final String? errorMessage;
  final bool didComplete;

  SignUpFormState copyWith({
    String? firstName,
    String? lastName,
    String? userName,
    String? email,
    String? password,
    String? phoneNumber,
    String? profileImagePath,
    bool? isSubmitting,
    String? errorMessage,
    bool? didComplete,
    bool clearError = false,
    bool clearCompletion = false,
  }) {
    return SignUpFormState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      didComplete: clearCompletion ? false : didComplete ?? this.didComplete,
    );
  }
}

class SignUpController extends Notifier<AsyncValue<SignUpFormState>> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  AsyncValue<SignUpFormState> build() {
    return AsyncValue.data(SignUpFormState.initial());
  }

  void setFirstName(String value) => _update(
    (state) => state.copyWith(
      firstName: value,
      clearError: true,
      clearCompletion: true,
    ),
  );

  void setLastName(String value) => _update(
    (state) => state.copyWith(
      lastName: value,
      clearError: true,
      clearCompletion: true,
    ),
  );

  void setUserName(String value) => _update(
    (state) => state.copyWith(
      userName: value,
      clearError: true,
      clearCompletion: true,
    ),
  );

  void setEmail(String value) => _update(
    (state) =>
        state.copyWith(email: value, clearError: true, clearCompletion: true),
  );

  void setPassword(String value) => _update(
    (state) => state.copyWith(
      password: value,
      clearError: true,
      clearCompletion: true,
    ),
  );

  void setPhoneNumber(String value) => _update(
    (state) => state.copyWith(
      phoneNumber: value,
      clearError: true,
      clearCompletion: true,
    ),
  );

  Future<void> pickProfileImage(BuildContext context) async {
    final localizations = AppLocalizations.of(context);

    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (file == null) {
        return;
      }

      _update(
        (state) => state.copyWith(
          profileImagePath: file.path,
          clearError: true,
          clearCompletion: true,
        ),
      );
    } catch (_) {
      _update(
        (state) => state.copyWith(
          errorMessage: localizations.translate('profileImagePickerError'),
        ),
      );
    }
  }

  Future<void> submit() async {
    final currentState = state.valueOrNull ?? SignUpFormState.initial();
    state = AsyncValue.data(
      currentState.copyWith(
        isSubmitting: true,
        clearError: true,
        clearCompletion: true,
      ),
    );

    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            firstName: currentState.firstName,
            lastName: currentState.lastName,
            userName: currentState.userName,
            email: currentState.email,
            password: currentState.password,
            phoneNumber: currentState.phoneNumber,
            profileImagePath: currentState.profileImagePath,
          );

      state = AsyncValue.data(
        (state.valueOrNull ?? currentState).copyWith(
          isSubmitting: false,
          didComplete: true,
        ),
      );
    } on ApiException catch (error) {
      state = AsyncValue.data(
        (state.valueOrNull ?? currentState).copyWith(
          isSubmitting: false,
          errorMessage: _resolveErrorMessage(error),
        ),
      );
    } catch (_) {
      state = AsyncValue.data(
        (state.valueOrNull ?? currentState).copyWith(
          isSubmitting: false,
          errorMessage: 'genericError',
        ),
      );
    }
  }

  void resetCompletion() {
    _update((state) => state.copyWith(clearCompletion: true));
  }

  void _update(SignUpFormState Function(SignUpFormState state) update) {
    final currentState = state.valueOrNull ?? SignUpFormState.initial();
    state = AsyncValue.data(update(currentState));
  }

  String _resolveErrorMessage(ApiException error) {
    if (error.message == 'TIMEOUT') {
      return 'networkTimeout';
    }

    if (error.errors != null && error.errors!.isNotEmpty) {
      return error.errors!.values.first.first;
    }

    return error.message.isEmpty ? 'genericError' : error.message;
  }
}

final signUpControllerProvider =
    NotifierProvider<SignUpController, AsyncValue<SignUpFormState>>(
      SignUpController.new,
    );
