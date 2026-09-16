import 'package:flutter/material.dart';

import '../../core/internet_controller.dart';
import '../../core/internet_status.dart';
import '../models/offline_ui.dart';

class PageWidget extends StatelessWidget {
  final InternetStatus status;
  final PageOfflineUI config;
  final InternetController controller;

  const PageWidget({
    super.key,
    required this.status,
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isVisible = status != InternetStatus.connected;
    final isChecking =
        status == InternetStatus.checking || status == InternetStatus.restoring;
    final theme = Theme.of(context);

    // Default to a solid background color based on the app's theme
    final bgColor = config.backgroundColor ?? theme.scaffoldBackgroundColor;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !isVisible,
        child: AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: bgColor, // Solid background to completely hide the app
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Custom icon or default oversized Wi-Fi off icon
                      config.customIcon ??
                          Icon(
                            Icons.cloud_off,
                            size: 100,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                      const SizedBox(height: 32),
      
                      // Title
                      Text(
                        config.title,
                        textAlign: TextAlign.center,
                        style:
                            config.titleStyle ??
                            theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
      
                      // Message
                      Text(
                        config.message,
                        textAlign: TextAlign.center,
                        style:
                            config.messageStyle ??
                            theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                      ),
                      const SizedBox(height: 48),
      
                      // Retry Button
                      if (config.showRetryButton)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: isChecking
                                ? null
                                : () => controller.retry(),
                            icon: isChecking
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh),
                            label: Text(
                              isChecking ? 'Checking connection...' : 'Try Again',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
