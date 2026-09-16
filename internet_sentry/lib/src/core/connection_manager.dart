import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'internet_checker.dart';
import 'internet_checker_config.dart';

class ConnectionManager {
  final Connectivity _connectivity = Connectivity();
  final InternetReachabilityChecker _checker = InternetReachabilityChecker();
  
  final InternetCheckerConfig config;
  final Duration debounceDuration;
  final void Function(bool isManual) onCheckInitiated;
  final void Function(bool hasInternet) onCheckCompleted;

  Timer? _debounceTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isChecking = false;

  ConnectionManager({
    required this.config,
    required this.debounceDuration,
    required this.onCheckInitiated,
    required this.onCheckCompleted,
  });

  void start() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleNetworkChange(results);
    });
  }

  void stop() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
  }

  Future checkNow({bool isManual = false}) async {
    _debounceTimer?.cancel();
    await _performCheck(isManual: isManual);
  }

  void _handleNetworkChange(List results) {
    if (results.contains(ConnectivityResult.none) && results.length == 1) {
      _debounceTimer?.cancel();
      onCheckCompleted(false);
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () => _performCheck(isManual: false));
  }

  Future _performCheck({bool isManual = false}) async {
    if (_isChecking) return;
    
    _isChecking = true;
    onCheckInitiated(isManual);

    final hasInternet = await _checker.hasInternetAccess(config);
    
    _isChecking = false;
    onCheckCompleted(hasInternet);
  }
}