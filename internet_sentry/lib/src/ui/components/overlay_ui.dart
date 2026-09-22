import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/internet_controller.dart';
import '../../core/internet_status.dart';
import '../models/offline_ui.dart';

class OverlayWidget extends StatefulWidget {
  final InternetStatus status;
  final OverlayOfflineUI config;
  final InternetController controller;
  final Widget child;

  const OverlayWidget({
    super.key,
    required this.status,
    required this.config,
    required this.controller,
    required this.child,
  });

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  bool _showError = false;

  Future<void> _handleRetry() async {
    setState(() => _showError = false);

    final success = await widget.controller.retry();

    if (!mounted) return;

    if (!success) {
      setState(() => _showError = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showError = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = widget.status != InternetStatus.connected;
    final isChecking =
        widget.status == InternetStatus.checking ||
        widget.status == InternetStatus.restoring;
    final theme = Theme.of(context);
    final bgColor =
        widget.config.backgroundColor ??
        theme.scaffoldBackgroundColor.withValues(alpha: widget.config.opacity);

    Widget overlayContent = AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.config.blur > 0)
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.config.blur,
                sigmaY: widget.config.blur,
              ),
              child: const SizedBox.expand(),
            ),

          Container(color: bgColor),

          Center(
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: widget.config.iconSize ?? 64,
                      color:
                          widget.config.iconColor ??
                          theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.config.message,
                      textAlign: TextAlign.center,
                      style:
                          widget.config.textStyle ?? theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (widget.config.showRetryButton)
                      ElevatedButton.icon(
                        onPressed: isChecking ? null : _handleRetry,
                        style: widget.config.buttonStyle,
                        icon: const Icon(Icons.refresh),
                        label: Text('Try Again'),
                      ),

                    AnimatedOpacity(
                      opacity: _showError && !isChecking ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          widget.config.retryFailedMessage ?? "Still offline. Please check your settings.",
                          style: TextStyle(
                            color: widget.config.retryFailedMessageColor ?? Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(ignoring: !isVisible, child: overlayContent),
        ),
      ],
    );
  }
}
