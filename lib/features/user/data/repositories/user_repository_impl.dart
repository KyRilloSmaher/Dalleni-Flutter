import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/update_user_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remoteDataSource);

  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile> getProfile() => _remoteDataSource.getProfile();

  @override
  Future<String> updateProfileImage(String userId, File profileImage) =>
      _remoteDataSource.updateProfileImage(userId, profileImage);

  @override
  Future<UserProfile> updateProfile(UpdateUserAccount request) =>
      _remoteDataSource.updateProfile(request);
}

// ─── Riverpod Providers ──────────────────────────────────────────────────────

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return UserRemoteDataSourceImpl(dio);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource);
});
