import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/internet_status.dart';
import '../models/offline_ui.dart';

/// The internal widget responsible for rendering and animating the top banner.
class BannerWidget extends StatefulWidget {
  final InternetStatus status;
  final BannerOfflineUI config;
  final Widget child;

  const BannerWidget({
    super.key,
    required this.status,
    required this.config,
    required this.child,
  });

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  bool _isVisible = false;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    if (widget.status != InternetStatus.connected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _isVisible = true);
        }
      });
    }
  }

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

    Widget bannerContent = Material(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  style:
                      widget.config.textStyle ??
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
    );

    if (widget.config.pushDown) {
      return Column(
        children: [
          AnimatedSize(
            duration: widget.config.animationDuration,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isVisible
                ? bannerContent
                : const SizedBox(width: double.infinity, height: 0),
          ),
          Expanded(child: widget.child),
        ],
      );
    }

    return Stack(
      children: [
        widget.child,
        AnimatedPositioned(
          duration: widget.config.animationDuration,
          curve: Curves.easeInOut,
          top: _isVisible ? 0 : -150,
          left: 0,
          right: 0,
          child: bannerContent,
        ),
      ],
    );
  }
}