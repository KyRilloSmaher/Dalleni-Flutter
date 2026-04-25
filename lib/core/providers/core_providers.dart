import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/local_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError(
    'LocalStorageService must be overridden at bootstrap.',
  );
});
