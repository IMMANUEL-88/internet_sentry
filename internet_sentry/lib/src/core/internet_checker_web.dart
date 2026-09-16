// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'internet_checker.dart';
import 'internet_checker_config.dart';

/// Returns the Wasm-compliant HTML/JS implementation for Flutter Web.
InternetReachabilityChecker getPlatformChecker() => _WebInternetChecker();

class _WebInternetChecker implements InternetReachabilityChecker {
  @override
  Future hasInternetAccess(InternetCheckerConfig config) async {
    // Rely on the browser's native navigator line if configured (avoids CORS)
    if (config.useBrowserNavigatorLine) {
      return web.window.navigator.onLine;
    }

    try {
      // Use the modern browser Fetch API
      final options = web.RequestInit(
        method: 'HEAD',
      );

      // fetch returns a JSPromise, so we convert it to a Dart Future
      final response = await web.window
          .fetch(config.testUrl.toJS, options)
          .toDart
          .timeout(config.timeout);

      // response.ok is true for 200-299 status codes
      return response.ok;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}