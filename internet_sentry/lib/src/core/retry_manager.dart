import 'dart:async';
import 'dart:ui';

/// Manages the periodic timer for automatic reconnection attempts.
class RetryManager {
  final Duration interval;
  final VoidCallback onRetry;
  
  Timer? _timer;

  RetryManager({
    required this.interval,
    required this.onRetry,
  });

  /// Starts the periodic retry timer.
  void start() {
    if (_timer != null && _timer!.isActive) return;
    _timer = Timer.periodic(interval, (_) => onRetry());
  }

  /// Stops and cleans up the timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}