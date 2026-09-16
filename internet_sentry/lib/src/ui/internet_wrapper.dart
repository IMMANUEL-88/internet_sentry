import 'package:flutter/material.dart';

import '../core/internet_checker_config.dart';
import '../core/internet_controller.dart';
import 'models/offline_ui.dart';

/// A wrapper that monitors internet connectivity and automatically displays
/// the configured offline UI when the connection is lost.
class InternetWrapper extends StatefulWidget {
  /// The main application widget (typically the Navigator provided by MaterialApp.builder).
  final Widget child;

  /// The UI configuration to display when offline (e.g., OfflineUI.banner()).
  final OfflineUI offlineUI;

  /// An optional external controller. If null, the wrapper manages its own internal controller.
  final InternetController? controller;

  // Optional configurations if using the internal controller
  final bool autoRetry;
  final Duration retryInterval;
  final Duration debounceDuration;
  final InternetCheckerConfig checkerConfig;
  final VoidCallback? onConnectionLost;
  final VoidCallback? onConnectionRestored;

  const InternetWrapper({
    super.key,
    required this.child,
    required this.offlineUI,
    this.controller,
    this.autoRetry = true,
    this.retryInterval = const Duration(seconds: 3),
    this.debounceDuration = const Duration(milliseconds: 500),
    this.checkerConfig = const InternetCheckerConfig(),
    this.onConnectionLost,
    this.onConnectionRestored,
  });

  @override
  State<InternetWrapper> createState() => _InternetWrapperState();
}

class _InternetWrapperState extends State<InternetWrapper> {
  late final InternetController _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    // Use the provided controller, or create an internal one
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _isInternalController = true;
      _controller = InternetController(
        autoRetry: widget.autoRetry,
        retryInterval: widget.retryInterval,
        debounceDuration: widget.debounceDuration,
        config: widget.checkerConfig,
        onConnectionLost: widget.onConnectionLost,
        onConnectionRestored: widget.onConnectionRestored,
      );
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it ourselves
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use a Stack so the offline UI floats securely over the main app.
    // Directionality ensures our UI elements render correctly even if placed extremely high in the widget tree.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // 1. The underlying application
          widget.child,

          // 2. The reactive Offline UI layer
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, status, child) {
              return widget.offlineUI.buildWidget(
                context,
                status,
                _controller,
              );
            },
          ),
        ],
      ),
    );
  }
}