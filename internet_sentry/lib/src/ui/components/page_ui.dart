import 'package:flutter/material.dart';

import '../../core/internet_controller.dart';
import '../../core/internet_status.dart';
import '../models/offline_ui.dart';

class PageWidget extends StatefulWidget {
  final InternetStatus status;
  final PageOfflineUI config;
  final InternetController controller;
  final Widget child;

  const PageWidget({
    super.key,
    required this.status,
    required this.config,
    required this.controller,
    required this.child,
  });

  @override
  State<PageWidget> createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
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
        widget.config.backgroundColor ?? theme.scaffoldBackgroundColor;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isVisible,
            child: AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: bgColor,
                child: SafeArea(
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Custom icon or default oversized Wi-Fi off icon
                            widget.config.customIcon ??
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
                              widget.config.title,
                              textAlign: TextAlign.center,
                              style:
                                  widget.config.titleStyle ??
                                  theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),

                            // Message
                            Text(
                              widget.config.message,
                              textAlign: TextAlign.center,
                              style:
                                  widget.config.messageStyle ??
                                  theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                            ),
                            const SizedBox(height: 32),

                            // Retry Button
                            if (widget.config.showRetryButton)
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: isChecking ? null : _handleRetry,
                                  style: widget.config.buttonStyle,
                                  icon: const Icon(Icons.refresh),
                                  label: Text(
                                    'Try Again',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
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
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
