import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/internet_status.dart';
import '../models/offline_ui.dart';

/// The internal widget responsible for rendering and animating the top banner.
class BannerWidget extends StatefulWidget {
  final InternetStatus status;
  final BannerOfflineUI config;

  const BannerWidget({
    super.key,
    required this.status,
    required this.config,
  });

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  bool _isVisible = false;
  Timer? _dismissTimer;

  @override
  void didUpdateWidget(covariant BannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.status != oldWidget.status) {
      _handleStatusChange(widget.status);
    }
  }

  void _handleStatusChange(InternetStatus status) {
    _dismissTimer?.cancel();

    if (status == InternetStatus.connected) {
      if (widget.config.showBackOnlineNotification && _isVisible) {
        // Leave it visible to show "Back online", then dismiss after 2 seconds
        _dismissTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isVisible = false);
          }
        });
      } else {
        setState(() => _isVisible = false);
      }
    } else {
      setState(() => _isVisible = true);
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Default colors if none are provided
    final theme = Theme.of(context);
    final errorColor = widget.config.disconnectedColor ?? theme.colorScheme.error;
    final warningColor = widget.config.restoringColor ?? Colors.orange;
    final successColor = widget.config.backOnlineColor ?? Colors.green;

    Color backgroundColor;
    String message;
    IconData iconData;

    switch (widget.status) {
      case InternetStatus.disconnected:
        backgroundColor = errorColor;
        message = widget.config.disconnectedMessage;
        iconData = Icons.wifi_off;
        break;
      case InternetStatus.checking:
      case InternetStatus.restoring:
        backgroundColor = warningColor;
        message = widget.config.restoringMessage;
        iconData = Icons.loop;
        break;
      case InternetStatus.connected:
        backgroundColor = successColor;
        message = widget.config.backOnlineMessage;
        iconData = Icons.wifi;
        break;
    }

    return AnimatedPositioned(
      duration: widget.config.animationDuration,
      curve: Curves.easeInOut,
      top: _isVisible ? 0 : -150, // Slide off screen when hidden
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  color: widget.config.iconColor ?? Colors.white,
                  size: widget.config.iconSize ?? 20,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    message,
                    style: widget.config.textStyle ??
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}