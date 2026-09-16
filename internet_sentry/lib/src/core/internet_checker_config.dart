/// Configuration for the underlying internet reachability engine.
class InternetCheckerConfig {
  /// The URL to ping to verify actual internet reachability.
  /// Defaults to Google's highly-optimized 204 No Content endpoint.
  final String testUrl;

  /// The maximum duration to wait for a reachability response.
  final Duration timeout;

  /// If true, Web platforms will use `window.navigator.onLine` instead of HTTP.
  /// This avoids CORS issues if you don't control the `testUrl` endpoint.
  final bool useBrowserNavigatorLine;

  const InternetCheckerConfig({
    this.testUrl = 'https://clients3.google.com/generate_204',
    this.timeout = const Duration(seconds: 5),
    this.useBrowserNavigatorLine = true,
  });
}