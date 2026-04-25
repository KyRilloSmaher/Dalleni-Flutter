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
      return;
    }

    final refreshAt = expiresAt.subtract(const Duration(minutes: 1));
    final delay = refreshAt.difference(DateTime.now().toUtc());

    if (delay.isNegative) {
      _timer = Timer(Duration.zero, () async => onRefreshDue());
      return;
    }

    _timer = Timer(delay, () async => onRefreshDue());
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
