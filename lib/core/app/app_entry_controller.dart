import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_client.dart';
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
    print(
      '[AUTH DEBUG] AppEntryController._init() (storage instance: ${identityHashCode(storage)})',
    );

    final isFirst = storage.isFirstLaunch();
    final hasToken = storage.getToken()?.isNotEmpty ?? false;

    if (isFirst) {
      state = AppStartState.onboarding;
    } else if (hasToken) {
      await ref.read(authRepositoryProvider).restoreSession();
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
    print('[AUTH DEBUG] AppEntryController.logout() requested by user UI');
    await ref.read(authRepositoryProvider).logout();
    state = AppStartState.auth;
  }
}
