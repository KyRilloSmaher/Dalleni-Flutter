import 'dart:async';

import '../network/jwt_utils.dart';

class TokenScheduler {
  Timer? _timer;

  void schedule({
    required String accessToken,
    required Future<void> Function() onRefreshDue,
  }) {
    cancel();

    final expiresAt = JwtUtils.extractExpiry(accessToken);
    if (expiresAt == null) {
      print('[AUTH DEBUG] TokenScheduler: Expiry missing in access token.');
      return;
    }

    final refreshAt = expiresAt.subtract(const Duration(minutes: 1));
    final delay = refreshAt.difference(DateTime.now().toUtc());

    if (delay.isNegative) {
      print('[AUTH DEBUG] TokenScheduler: Refresh delay is negative (${delay.inSeconds}s). Deferring refresh to reactive AuthInterceptor.');
      return;
    }

    print('[AUTH DEBUG] TokenScheduler: Scheduled proactive token refresh in ${delay.inSeconds} seconds.');
    _timer = Timer(delay, () async => onRefreshDue());
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
