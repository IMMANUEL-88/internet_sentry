import 'package:flutter/material.dart';
import '../core/internet_status.dart';
import '../core/internet_checker_config.dart';
import '../core/internet_controller.dart';
import 'models/offline_ui.dart';

class InternetWrapper extends StatefulWidget {
  final Widget child;
  final OfflineUI offlineUI;
  final InternetController? controller;
  final bool autoRetry;
  final Duration retryInterval;
  final Duration debounceDuration;
  final InternetCheckerConfig checkerConfig;
  final bool showRestoredSnackbar;
  final String restoredSnackbarMessage;
  final Color restoredSnackbarColor;
  final TextStyle? restoredSnackbarTextStyle;
  final SnackBar? customRestoredSnackbar;
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
    this.showRestoredSnackbar = true,
    this.restoredSnackbarMessage = 'Internet restored!',
    this.restoredSnackbarColor = Colors.green,
    this.restoredSnackbarTextStyle,
    this.customRestoredSnackbar,
    this.onConnectionLost,
    this.onConnectionRestored,
  });

  @override
  State<InternetWrapper> createState() => _InternetWrapperState();
}

class _InternetWrapperState extends State<InternetWrapper> {
  late final InternetController _controller;
  bool _isInternalController = false;
  InternetStatus _previousStatus = InternetStatus.connected;

  @override
  void initState() {
    super.initState();
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

    _previousStatus = _controller.value;
    _controller.addListener(_onStatusChanged);
  }

  void _onStatusChanged() {
    final status = _controller.value;

    if (status == InternetStatus.connected &&
        (_previousStatus == InternetStatus.disconnected ||
            _previousStatus == InternetStatus.restoring)) {
      if (widget.showRestoredSnackbar && mounted) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.clearSnackBars();
        if (widget.customRestoredSnackbar != null) {
          messenger?.showSnackBar(widget.customRestoredSnackbar!);
        } else {
          messenger?.showSnackBar(
            SnackBar(
              content: Text(
                widget.restoredSnackbarMessage,
                style:
                    widget.restoredSnackbarTextStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              backgroundColor: widget.restoredSnackbarColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
    _previousStatus = status;
  }

  @override
  void dispose() {
    _controller.removeListener(_onStatusChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ValueListenableBuilder<InternetStatus>(
        valueListenable: _controller,
        child: widget.child,
        builder: (context, status, child) {
          return widget.offlineUI.buildWidget(
            context,
            status,
            _controller,
            child!,
          );
        },
      ),
    );
  }
}