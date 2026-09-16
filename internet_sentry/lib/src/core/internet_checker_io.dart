import 'dart:async';
import 'dart:io';
import 'internet_checker.dart';
import 'internet_checker_config.dart';

/// Returns the native dart:io implementation for Mobile and Desktop.
InternetReachabilityChecker getPlatformChecker() => _IoInternetChecker();

class _IoInternetChecker implements InternetReachabilityChecker {
  @override
  Future hasInternetAccess(InternetCheckerConfig config) async {
    try {
      final client = HttpClient();
      // Enforce the timeout at the connection level
      client.connectionTimeout = config.timeout;
      
      final request = await client.getUrl(Uri.parse(config.testUrl));
      final response = await request.close();
      
      // We consider 200-299 standard successes. 
      // Google's generate_204 returns 204.
      return response.statusCode >= 200 && response.statusCode < 300;
    } on SocketException catch (_) {
      // DNS resolution failed or no network route
      return false;
    } on TimeoutException catch (_) {
      // Request took too long
      return false;
    } catch (_) {
      // Any other SSL/HTTP error
      return false;
    }
  }
}