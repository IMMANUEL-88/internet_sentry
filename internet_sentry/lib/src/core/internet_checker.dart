import 'internet_checker_config.dart';

// Conditionally import based on JS Interop (Supports both JS and Wasm compilers)
import 'internet_checker_io.dart'
    if (dart.library.js_interop) 'internet_checker_web.dart';

/// Abstract interface for cross-platform internet reachability checking.
abstract class InternetReachabilityChecker {
  /// Checks if the provided [config.testUrl] can be reached.
  Future hasInternetAccess(InternetCheckerConfig config);

  /// Factory constructor that returns the platform-specific implementation.
  factory InternetReachabilityChecker() => getPlatformChecker();
}