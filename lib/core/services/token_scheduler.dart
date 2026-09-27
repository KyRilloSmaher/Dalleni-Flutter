import 'dart:async';

class TokenScheduler {
  Timer? _timer;

  void schedule({
    required DateTime accessTokenExpiresAt,
    required Future<void> Function() onRefreshDue,
  }) {
    cancel();

    final expiresAt = accessTokenExpiresAt.toUtc();

    // Refresh 1 minute before access token expires.
    final refreshAt = expiresAt.subtract(const Duration(minutes: 1));

    final delay = refreshAt.difference(DateTime.now().toUtc());

    if (delay.isNegative) {
      print(
        '[AUTH DEBUG] TokenScheduler: '
        'Refresh time already passed. '
        'Deferring refresh to reactive AuthInterceptor.',
      );
      return;
    }

    print(
      '[AUTH DEBUG] TokenScheduler: '
      'Scheduled proactive token refresh in '
      '${delay.inSeconds} seconds.',
    );

    _timer = Timer(delay, () async {
      try {
        await onRefreshDue();
      } catch (error) {
        print(
          '[AUTH DEBUG] TokenScheduler: '
          'Proactive refresh failed: $error',
        );
      }
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}
