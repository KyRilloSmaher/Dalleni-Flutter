import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../user/data/models/update_user_model.dart';
import '../../../user/data/repositories/user_repository_impl.dart';
import '../../../user/domain/entities/user_profile.dart';

class ProfileState {
  const ProfileState({
    required this.profile,
    required this.isLoading,
    this.errorMessage,
  });

  final UserProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  factory ProfileState.initial() =>
      const ProfileState(profile: null, isLoading: true);

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    Future.microtask(_fetchProfile);
    return ProfileState.initial();
  }

  Future<void> _fetchProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await ref.read(userRepositoryProvider).getProfile();
      state = state.copyWith(isLoading: false, profile: profile);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred.',
      );
    }
  }

  Future<void> refreshProfile() => _fetchProfile();

  Future<bool> updateProfile(UpdateUserAccount request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedProfile = await ref
          .read(userRepositoryProvider)
          .updateProfile(request);
      state = state.copyWith(isLoading: false, profile: updatedProfile);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update profile.',
      );
      return false;
    }
  }

  Future<bool> updateProfileImage(File imageFile) async {
    if (state.profile == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(userRepositoryProvider)
          .updateProfileImage(state.profile!.id, imageFile);
      // Wait a moment and refetch the profile as the endpoint only returns URL
      await _fetchProfile();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update image.',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
