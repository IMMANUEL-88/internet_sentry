import 'package:flutter/widgets.dart';

/// Listens to Flutter application lifecycle events to trigger actions
/// when the application returns to the foreground.
class AppLifecycleHandler with WidgetsBindingObserver {
  final VoidCallback onResumed;
  bool _isObserving = false;

  AppLifecycleHandler({required this.onResumed});

  /// Starts listening to the app lifecycle.
  void start() {
    if (_isObserving) return;
    WidgetsBinding.instance.addObserver(this);
    _isObserving = true;
  }

  /// Stops listening to the app lifecycle.
  void stop() {
    if (!_isObserving) return;
    WidgetsBinding.instance.removeObserver(this);
    _isObserving = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The app just came back to the foreground.
      onResumed();
    }
  }
}