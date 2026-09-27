import 'package:dalleni/core/providers/core_providers.dart';
import 'package:dalleni/core/storage/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/models/push_notification_data.dart';

class NotificationState {
  const NotificationState({
    this.lastReceivedNotification,
    this.lastTappedNotification,
    this.fcmToken,
    this.deviceId,
    this.isInitialized = false,
  });

  final PushNotificationData? lastReceivedNotification;
  final PushNotificationData? lastTappedNotification;
  final String? fcmToken;
  final String? deviceId;
  final bool isInitialized;

  NotificationState copyWith({
    PushNotificationData? lastReceivedNotification,
    PushNotificationData? lastTappedNotification,
    String? fcmToken,
    String? deviceId,
    bool? isInitialized,
  }) {
    return NotificationState(
      lastReceivedNotification:
          lastReceivedNotification ?? this.lastReceivedNotification,
      lastTappedNotification:
          lastTappedNotification ?? this.lastTappedNotification,
      fcmToken: fcmToken ?? this.fcmToken,
      deviceId: deviceId ?? this.deviceId,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class NotificationController extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    return const NotificationState();
  }

  Future<void> initializeFCM() async {
    if (state.isInitialized) return;

    final fcmService = ref.read(fcmServiceProvider);

    await fcmService.initialize(
      onTokenReceived: (token) async {
        await registerDeviceToken(token);
      },
      onNotificationReceived: (data) async {
        handleForegroundNotification(data);
      },
      onNotificationOpened: (data) async {
        handleNotificationTap(
          type: data.type,
          entityType: data.entityType,
          entityId: data.entityId,
          notificationId: data.notificationId,
          actorId: data.actorId,
        );
      },
    );

    state = state.copyWith(isInitialized: true);
  }

  Future<void> registerDeviceToken(String token) async {
    if (token.isEmpty) return;

 final storage = ref.read(localStorageServiceProvider);

    final registeredToken = await storage.getFCMRegisteredToken();

    if (registeredToken == token) {
      print(
        '[NotificationController] Same FCM token already registered. '
        'Skipping API call.',
      );

      state = state.copyWith(fcmToken: token);

      return;
    }

    try {
      print('[NotificationController] Registering FCM device token...');

      final repository = ref.read(notificationsRepositoryProvider);

      final deviceId = await repository.registerDevice(token, platform: 1);

      await storage.setFCMRegisteredToken(token);

      state = state.copyWith(fcmToken: token, deviceId: deviceId);

      print(
        '[NotificationController] Device registered successfully. '
        'deviceId: $deviceId',
      );
    } catch (e) {
      print('[NotificationController] Error registering device token: $e');
    }
  }

  void handleNotificationTap({
    required String? type,
    required String? entityType,
    required String? entityId,
    required String? notificationId,
    required String? actorId,
  }) {
    final notificationData = PushNotificationData(
      type: type,
      entityType: entityType,
      entityId: entityId,
      notificationId: notificationId,
      actorId: actorId,
    );

    print(
      '[NotificationController] Notification tap handler triggered:\n'
      '  type: $type\n'
      '  entityType: $entityType\n'
      '  entityId: $entityId\n'
      '  notificationId: $notificationId\n'
      '  actorId: $actorId',
    );

    state = state.copyWith(lastTappedNotification: notificationData);
  }

  void handleForegroundNotification(PushNotificationData data) {
    print('[NotificationController] Foreground notification received: $data');
    state = state.copyWith(lastReceivedNotification: data);
  }

  Future<void> deactivateDeviceOnLogout() async {
    try {
      print('[NotificationController] Deactivating device on logout...');
      final repository = ref.read(notificationsRepositoryProvider);
      await repository.deactivateDevice();
      final storage = ref.read(localStorageServiceProvider);
      await storage.removeFCMRegisteredToken();
      state = state.copyWith(deviceId: null, fcmToken: null);
      print('[NotificationController] Device deactivation process completed.');
    } catch (e) {
      print('[NotificationController] Error deactivating device: $e');
    }
  }
}

final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(
      NotificationController.new,
    );
