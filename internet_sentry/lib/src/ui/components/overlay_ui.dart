import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/internet_controller.dart';
import '../../core/internet_status.dart';
import '../models/offline_ui.dart';

class OverlayWidget extends StatelessWidget {
  final InternetStatus status;
  final OverlayOfflineUI config;
  final InternetController controller;

  const OverlayWidget({
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
    final bgColor =
        config.backgroundColor ??
        theme.scaffoldBackgroundColor.withValues(alpha: config.opacity);

    Widget overlayContent = AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (config.blur > 0)
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: config.blur,
                sigmaY: config.blur,
              ),
              child: const SizedBox.expand(),
            ),

          Container(color: bgColor),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    config.message,
                    textAlign: TextAlign.center,
                    style: config.textStyle ?? theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 32),
                  if (config.showRetryButton)
                    ElevatedButton.icon(
                      onPressed: isChecking ? null : () => controller.retry(),
                      icon: isChecking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(isChecking ? 'Checking...' : 'Try Again'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Positioned.fill(
      child: config.blockInteraction
          ? AbsorbPointer(
              absorbing: isVisible,
              child: overlayContent,
            )
          : IgnorePointer(
              ignoring: !isVisible,
              child: overlayContent,
            ),
    );
  }
}
