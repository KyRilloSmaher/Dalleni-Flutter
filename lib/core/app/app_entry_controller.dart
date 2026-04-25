import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';

enum AppStartState { loading, onboarding, auth, main }

final appEntryControllerProvider =
    NotifierProvider<AppEntryController, AppStartState>(AppEntryController.new);

class AppEntryController extends Notifier<AppStartState> {
  bool _didScheduleInit = false;

  @override
  AppStartState build() {
    if (!_didScheduleInit) {
      _didScheduleInit = true;
      Future.microtask(_init);
    }
    return AppStartState.loading;
  }

  Future<void> _init() async {
    final storage = ref.read(localStorageServiceProvider);

    final isFirst = storage.isFirstLaunch();
    final hasToken = storage.getToken()?.isNotEmpty ?? false;

    if (isFirst) {
      state = AppStartState.onboarding;
    } else if (hasToken) {
      state = AppStartState.main;
    } else {
      state = AppStartState.auth;
    }
  }

  Future<void> completeOnboarding() async {
    final storage = ref.read(localStorageServiceProvider);

    await storage.setFirstLaunchDone();

    state = AppStartState.auth;
  }

  void completeLogin() {
    state = AppStartState.main;
  }

  Future<void> logout() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.clearSession();
    state = AppStartState.auth;
  }
}
