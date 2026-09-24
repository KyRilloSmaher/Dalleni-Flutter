import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';
import '../../../questions/domain/entities/question_entity.dart';
import '../../data/models/update_user_model.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user_profile.dart';

class ProfileState {
  const ProfileState({
    required this.profile,
    required this.isLoading,
    required this.savedQuestions,
    this.errorMessage,
    required this.questionuser,
    this.selectedImage,
  });

  final UserProfile? profile;
  final bool isLoading;
  final String? errorMessage;
  final List<SavedQuestion> savedQuestions;
  final List<QuestionUser> questionuser;
  final File? selectedImage;

  factory ProfileState.initial() => const ProfileState(
        profile: null,
        isLoading: true,
        savedQuestions: [],
        questionuser: [],
        selectedImage: null,
      );

  String get firstName {
    final nameParts = profile?.fullName.split(' ') ?? [];
    return nameParts.isNotEmpty ? nameParts.first : '';
  }

  String get lastName {
    final nameParts = profile?.fullName.split(' ') ?? [];
    return nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
  }

  String get userName => profile?.userName ?? '';
  String get phoneNumber => profile?.phoneNumber ?? '';

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<SavedQuestion>? savedQuestions,
    List<QuestionUser>? questionuser,
    File? selectedImage,
    bool clearSelectedImage = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      savedQuestions: savedQuestions ?? this.savedQuestions,
      questionuser: questionuser ?? this.questionuser,
      selectedImage:
          clearSelectedImage ? null : (selectedImage ?? this.selectedImage),
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

  Future<void> pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        state = state.copyWith(selectedImage: File(pickedFile.path));
      }
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Failed to pick image from gallery.',
      );
    }
  }

  void clearSelectedImage() {
    state = state.copyWith(clearSelectedImage: true);
  }

  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validationFirstNameRequired';
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validationLastNameRequired';
    }
    return null;
  }

  String? validateUserName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validationUserNameRequired';
    }
    return null;
  }

  Future<bool> saveProfile({
    required String firstName,
    required String lastName,
    required String userName,
    String? phoneNumber,
    String? bio,
  }) async {
    final currentProfile = state.profile;
    if (currentProfile == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    if (state.selectedImage != null) {
      try {
        await ref
            .read(userRepositoryProvider)
            .updateProfileImage(currentProfile.id, state.selectedImage!);
      } on ApiException catch (e) {
        state = state.copyWith(isLoading: false, errorMessage: e.message);
        return false;
      } catch (_) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to upload image.',
        );
        return false;
      }
    }

    final updateRequest = UpdateUserAccount(
      id: currentProfile.id,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      userName: userName.trim(),
      phoneNumber: phoneNumber != null && phoneNumber.trim().isNotEmpty
          ? phoneNumber.trim()
          : null,
    );

    try {
      final updatedProfile = await ref
          .read(userRepositoryProvider)
          .updateProfile(updateRequest);
      state = state.copyWith(
        isLoading: false,
        profile: updatedProfile,
        clearSelectedImage: true,
      );
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
      await _fetchProfile();
      state = state.copyWith(clearSelectedImage: true);
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

  Future<void> fetchSavedQuestions() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final savedQuestions = await ref
          .read(userRepositoryProvider)
          .getSavedQuestions();

      state = state.copyWith(isLoading: false, savedQuestions: savedQuestions);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load saved questions.',
      );
    }
  }

  Future<void> fetchQuestuionUser() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final questionuser = await ref
          .read(userRepositoryProvider)
          .getQuestionsUser();

      state = state.copyWith(isLoading: false, questionuser: questionuser);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load saved questions.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
