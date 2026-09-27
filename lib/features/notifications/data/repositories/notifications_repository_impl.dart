import '../../../../core/storage/local_storage_service.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../models/device_registration_request_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remoteDataSource,
    required LocalStorageService localStorageService,
  })  : _remoteDataSource = remoteDataSource,
        _localStorageService = localStorageService;

  final NotificationsRemoteDataSource _remoteDataSource;
  final LocalStorageService _localStorageService;

  @override
  Future<String> registerDevice(String token, {int platform = 1}) async {
    final deviceId = await _remoteDataSource.registerDevice(
      DeviceRegistrationRequestModel(
        deviceToken: token,
        platform: platform,
      ),
    );

    if (deviceId.isNotEmpty) {
      await _localStorageService.saveDeviceId(deviceId);
    }
    return deviceId;
  }

  @override
  Future<void> deactivateDevice() async {
    final deviceId = _localStorageService.getDeviceId();
    if (deviceId == null || deviceId.isEmpty) {
      print('[NotificationsRepository] No saved deviceId found to deactivate.');
      return;
    }

    try {
      await _remoteDataSource.deactivateDevice(deviceId);
      print('[NotificationsRepository] Deactivated device with id: $deviceId');
    } finally {
      await _localStorageService.removeDeviceId();
    }
  }
}
