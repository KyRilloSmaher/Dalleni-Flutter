/*import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/models/push_notification_data.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print('[FCM Service] Handling background message: ${message.messageId}');
}

class FcmService {
  FcmService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  bool _isInitialized = false;
  bool _localNotificationsInitialized = false;

  Future<void> initialize({
    required Future<void> Function(String token) onTokenReceived,
    required Future<void> Function(PushNotificationData data)
    onNotificationReceived,
    required Future<void> Function(PushNotificationData data)
    onNotificationOpened,
  }) async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      // Firebase may already be initialized.
      print('[FCM Service] Firebase initialization: $e');
    }

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request notification permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print(
        '[FCM Service] Permission status: '
        '${settings.authorizationStatus}',
      );

      // Get current FCM token
      final token = await _messaging.getToken();

      if (token != null && token.isNotEmpty) {
        print('[FCM Service] FCM token received');
        await onTokenReceived(token);
      }

      // Listen for FCM token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        if (newToken.isEmpty) return;

        print('[FCM Service] FCM token refreshed');

        await onTokenReceived(newToken);
      });

      // Background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('[FCM Service] Foreground notification received');

        final pushData = PushNotificationData.fromJson(
          message.data,
          title: message.notification?.title,
          body: message.notification?.body,
        );

        // Show system notification while app is open
        await _showForegroundNotification(pushData);

        // Notify NotificationController
        await onNotificationReceived(pushData);
      });

      // Notification opened while app was in background
      FirebaseMessaging.onMessageOpenedApp.listen((
        RemoteMessage message,
      ) async {
        print('[FCM Service] Notification opened from background');

        final pushData = PushNotificationData.fromJson(
          message.data,
          title: message.notification?.title,
          body: message.notification?.body,
        );

        await onNotificationOpened(pushData);
      });

      // Notification opened while app was terminated
      final initialMessage = await _messaging.getInitialMessage();

      if (initialMessage != null) {
        print(
          '[FCM Service] App opened from terminated state '
          'via notification',
        );

        final pushData = PushNotificationData.fromJson(
          initialMessage.data,
          title: initialMessage.notification?.title,
          body: initialMessage.notification?.body,
        );

        await onNotificationOpened(pushData);
      }

      _isInitialized = true;

      print('[FCM Service] FCM initialized successfully');
    } catch (e) {
      print('[FCM Service] FCM initialization error: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(settings: InitializationSettings());

    const notificationChannel = AndroidNotificationChannel(
      'dalleni_notifications',
      'Dalleni Notifications',
      description: 'Dalleni push notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(notificationChannel);

    _localNotificationsInitialized = true;
  }

  Future<void> _showForegroundNotification(PushNotificationData data) async {
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: data.title ?? 'Dalleni',
      body: data.body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'dalleni_notifications',
          'Dalleni Notifications',
          channelDescription: 'Dalleni push notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('[FCM Service] Error getting FCM token: $e');
      return null;
    }
  }
}*/

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/models/push_notification_data.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase may already be initialized.
  }

  debugPrint('[FCM Service] Handling background message: ${message.messageId}');
}

class FcmService {
  FcmService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  FirebaseMessaging? _messaging;

  final FlutterLocalNotificationsPlugin _localNotifications;

  bool _isInitialized = false;
  bool _localNotificationsInitialized = false;
  //
  static const String _webVapidKey = String.fromEnvironment(
    'FCM_WEB_VAPID_KEY',
  );

  Future<void> initialize({
    required Future<void> Function(String token) onTokenReceived,
    required Future<void> Function(PushNotificationData data)
    onNotificationReceived,
    required Future<void> Function(PushNotificationData data)
    onNotificationOpened,
  }) async {
    if (_isInitialized) {
      return;
    }

    try {
      await _initializeFirebase();

      final messaging = _messaging ?? FirebaseMessaging.instance;
      _messaging = messaging;

      final isSupported = await messaging.isSupported();

      if (!isSupported) {
        debugPrint(
          '[FCM Service] Firebase Messaging is not supported '
          'on this platform.',
        );

        _isInitialized = true;
        return;
      }

      await _initializeLocalNotifications();

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        '[FCM Service] Permission status: '
        '${settings.authorizationStatus}',
      );

      final token = await _getFcmToken(messaging);

      if (token != null && token.isNotEmpty) {
        debugPrint('[FCM Service] FCM token received');

        await onTokenReceived(token);
      } else {
        debugPrint('[FCM Service] No FCM token available');
      }

      messaging.onTokenRefresh.listen(
        (newToken) async {
          if (newToken.isEmpty) {
            return;
          }

          debugPrint('[FCM Service] FCM token refreshed');

          await onTokenReceived(newToken);
        },
        onError: (Object error) {
          debugPrint('[FCM Service] Token refresh error: $error');
        },
      );

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // ------------------------------------------------------------
      // 9. Foreground messages
      // ------------------------------------------------------------
      FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) async {
          debugPrint('[FCM Service] Foreground notification received');

          final pushData = PushNotificationData.fromJson(
            message.data,
            title: message.notification?.title,
            body: message.notification?.body,
          );

          // Show local/browser notification.
          await _showForegroundNotification(pushData);

          // Notify NotificationController.
          await onNotificationReceived(pushData);
        },
        onError: (Object error) {
          debugPrint('[FCM Service] Foreground message error: $error');
        },
      );

      // ------------------------------------------------------------
      // 10. Notification opened from background
      // ------------------------------------------------------------
      FirebaseMessaging.onMessageOpenedApp.listen(
        (RemoteMessage message) async {
          debugPrint('[FCM Service] Notification opened from background');

          final pushData = PushNotificationData.fromJson(
            message.data,
            title: message.notification?.title,
            body: message.notification?.body,
          );

          await onNotificationOpened(pushData);
        },
        onError: (Object error) {
          debugPrint('[FCM Service] Notification opened error: $error');
        },
      );

      // ------------------------------------------------------------
      // 11. Notification opened from terminated state
      // ------------------------------------------------------------
      final initialMessage = await messaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint(
          '[FCM Service] App opened from terminated state '
          'via notification',
        );

        final pushData = PushNotificationData.fromJson(
          initialMessage.data,
          title: initialMessage.notification?.title,
          body: initialMessage.notification?.body,
        );

        await onNotificationOpened(pushData);
      }

      _isInitialized = true;

      debugPrint('[FCM Service] FCM initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('[FCM Service] FCM initialization error: $e');

      debugPrint('[FCM Service] Stack trace: $stackTrace');
    }
  }

  // ================================================================
  // Firebase initialization
  // ================================================================

  Future<void> _initializeFirebase() async {
    try {
      // Check whether Firebase already has an initialized app.
      Firebase.app();

      debugPrint('[FCM Service] Firebase already initialized');
    } on FirebaseException {
      // No default Firebase app exists.
      await Firebase.initializeApp();

      debugPrint('[FCM Service] Firebase initialized successfully');
    }
  }

  // ================================================================
  // FCM token
  // ================================================================

  Future<String?> _getFcmToken(FirebaseMessaging messaging) async {
    try {
      if (kIsWeb) {
        // Web requires the VAPID public key.
        if (_webVapidKey.isEmpty) {
          debugPrint('[FCM Service] Web VAPID key is missing.');

          debugPrint('[FCM Service] Run the app with:');

          debugPrint('--dart-define=FCM_WEB_VAPID_KEY=YOUR_PUBLIC_VAPID_KEY');

          return null;
        }

        debugPrint('[FCM Service] Getting Web FCM token...');

        return await messaging.getToken(vapidKey: _webVapidKey);
      }

      // Android / iOS
      return await messaging.getToken();
    } catch (e, stackTrace) {
      debugPrint('[FCM Service] Error getting FCM token: $e');

      debugPrint('[FCM Service] Token stack trace: $stackTrace');

      return null;
    }
  }

  // ================================================================
  // Local notifications initialization
  // ================================================================

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) {
      return;
    }

    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const webSettings = WebInitializationSettings();

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        web: webSettings,
      );

      await _localNotifications.initialize(settings: initializationSettings);

      if (!kIsWeb) {
        const notificationChannel = AndroidNotificationChannel(
          'dalleni_notifications',
          'Dalleni Notifications',
          description: 'Dalleni push notifications',
          importance: Importance.high,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(notificationChannel);
      }

      if (kIsWeb) {
        final webPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<
              WebFlutterLocalNotificationsPlugin
            >();

        if (webPlugin != null) {
          debugPrint(
            '[FCM Service] Web notification permission: '
            '${webPlugin.permissionStatus}',
          );
        }
      }

      _localNotificationsInitialized = true;

      debugPrint('[FCM Service] Local notifications initialized');
    } catch (e, stackTrace) {
      debugPrint('[FCM Service] Local notifications initialization error: $e');

      debugPrint('[FCM Service] Local notification stack trace: $stackTrace');
    }
  }

  // ================================================================
  // Foreground notification
  // ================================================================

  Future<void> _showForegroundNotification(PushNotificationData data) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (kIsWeb) {
        final webPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<
              WebFlutterLocalNotificationsPlugin
            >();

        if (webPlugin == null) {
          debugPrint('[FCM Service] Web notification plugin unavailable');

          return;
        }

        final permission = webPlugin.permissionStatus;

        debugPrint('[FCM Service] Web notification permission: $permission');

        if (permission != WebNotificationPermission.granted) {
          debugPrint('[FCM Service] Web notification permission not granted');

          return;
        }

        await webPlugin.show(
          id: notificationId,
          title: data.title ?? 'Dalleni',
          body: data.body ?? '',
          notificationDetails: const WebNotificationDetails(
            requireInteraction: false,
            direction: WebNotificationDirection.auto,
          ),
        );

        return;
      }

      // ------------------------------------------------------------
      // Android / iOS
      // ------------------------------------------------------------

      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'dalleni_notifications',
          'Dalleni Notifications',
          channelDescription: 'Dalleni push notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      );

      await _localNotifications.show(
        id: notificationId,
        title: data.title ?? 'Dalleni',
        body: data.body ?? '',
        notificationDetails: notificationDetails,
      );
    } catch (e, stackTrace) {
      debugPrint('[FCM Service] Error showing foreground notification: $e');

      debugPrint('[FCM Service] Notification stack trace: $stackTrace');
    }
  }

  // ================================================================
  // Public getToken
  // ================================================================

  Future<String?> getToken() async {
    try {
      final messaging = _messaging;

      if (messaging == null) {
        debugPrint('[FCM Service] Messaging is not initialized');

        return null;
      }

      return await _getFcmToken(messaging);
    } catch (e) {
      debugPrint('[FCM Service] Error getting FCM token: $e');

      return null;
    }
  }
}
