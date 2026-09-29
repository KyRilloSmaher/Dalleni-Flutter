import 'package:dalleni/features/notifications/presentation/providers/notification_controller.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/core_providers.dart';
import 'core/storage/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorageService = await LocalStorageService.create();

  runApp(
    ProviderScope(
      overrides: <Override>[
        localStorageServiceProvider.overrideWithValue(localStorageService),
      ],
      child: DevicePreview(
        enabled: true,
        builder: (context) => const DalleniApp(),
      ),
    ),
  );
}