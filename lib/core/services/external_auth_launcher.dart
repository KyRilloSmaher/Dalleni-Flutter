import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'external_auth_launcher_stub.dart'
    if (dart.library.html) 'external_auth_launcher_web.dart' as launcher;

class ExternalAuthLauncher {
  const ExternalAuthLauncher();

  Future<bool> launch(String url) {
    return launcher.launchExternalAuthUrl(url);
  }
}

final externalAuthLauncherProvider = Provider<ExternalAuthLauncher>((ref) {
  return const ExternalAuthLauncher();
});
