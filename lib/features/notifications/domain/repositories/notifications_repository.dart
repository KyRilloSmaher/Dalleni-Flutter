abstract class NotificationsRepository {
  Future<String> registerDevice(String token, {int platform = 1});
  Future<void> deactivateDevice();
}
