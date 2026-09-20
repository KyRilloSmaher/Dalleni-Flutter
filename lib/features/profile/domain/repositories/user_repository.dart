import 'dart:io';

import 'package:dalleni/features/questions/domain/entities/question_entity.dart';

import '../entities/user_profile.dart';
import '../../data/models/update_user_model.dart';

abstract class UserRepository {
  Future<UserProfile> getProfile();
  Future<String> updateProfileImage(String userId, File profileImage);
  Future<UserProfile> updateProfile(UpdateUserAccount request);
  Future<List<SavedQuestion>> getSavedQuestions();
}
