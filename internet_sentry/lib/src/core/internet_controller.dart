import 'package:flutter/foundation.dart';

import '../lifecycle/app_lifecycle_handler.dart';
import 'connection_manager.dart';
import 'internet_checker_config.dart';
import 'internet_status.dart';
import 'retry_manager.dart';

class InternetController extends ValueNotifier {
  final bool autoRetry;
  final VoidCallback? onConnectionLost;
  final VoidCallback? onConnectionRestored;
  final ValueChanged? onStatusChanged;

  late final ConnectionManager _connectionManager;
  late final RetryManager _retryManager;
  late final AppLifecycleHandler _lifecycleHandler;

  InternetController({
    InternetCheckerConfig config = const InternetCheckerConfig(),
    this.autoRetry = true,
    Duration retryInterval = const Duration(seconds: 3),
    Duration debounceDuration = const Duration(milliseconds: 500),
    this.onConnectionLost,
    this.onConnectionRestored,
    this.onStatusChanged,
  }) : super(InternetStatus.checking) {
    
    _connectionManager = ConnectionManager(
      config: config,
      debounceDuration: debounceDuration,
      onCheckInitiated: _onCheckInitiated,
      onCheckCompleted: _onCheckCompleted,
    );

    _retryManager = RetryManager(
      interval: retryInterval,
      // FIX: Background retries are NOT manual
      onRetry: () => _connectionManager.checkNow(isManual: false), 
    );

    _lifecycleHandler = AppLifecycleHandler(
      // FIX: Lifecycle resumes are NOT manual
      onResumed: () => _connectionManager.checkNow(isManual: false),
    );

    _startServices();
  }

  bool get isConnected => value == InternetStatus.connected;

  // FIX: User clicking a button IS manual
  Future retry() async {
    await _connectionManager.checkNow(isManual: true);
  }

  void _startServices() {
    _lifecycleHandler.start();
    _connectionManager.start();
    _connectionManager.checkNow(isManual: false); 
  }

  // FIX: Listen to the flag
  void _onCheckInitiated(bool isManual) {
    // If this is a background check (auto-retry), we do NOT want to change the UI state.
    // This prevents the UI from flickering between "Disconnected" and "Restoring...".
    if (!isManual) return;

    if (value == InternetStatus.disconnected) {
      _updateStatus(InternetStatus.restoring);
    } else if (value == InternetStatus.connected) {
      // Ignored: No flickering if online
    } else {
      _updateStatus(InternetStatus.checking);
    }
  }

  void _onCheckCompleted(bool hasInternet) {
    if (hasInternet) {
      if (value == InternetStatus.disconnected || value == InternetStatus.restoring) {
        onConnectionRestored?.call();
      }
      
      _updateStatus(InternetStatus.connected);
      if (autoRetry) _retryManager.stop();
      
    } else {
      if (value == InternetStatus.connected || value == InternetStatus.checking) {
        onConnectionLost?.call();
      }
      
      _updateStatus(InternetStatus.disconnected);
      if (autoRetry) _retryManager.start();
    }
  }

  void _updateStatus(InternetStatus newStatus) {
    if (value == newStatus) return; 
    
    value = newStatus;
    onStatusChanged?.call(newStatus);
  }

  @override
  void dispose() {
    _lifecycleHandler.stop();
    _retryManager.stop();
    _connectionManager.stop();
    super.dispose();
  }
}