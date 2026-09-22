import 'package:flutter/material.dart';

import '../../core/internet_status.dart';
import '../models/offline_ui.dart';

class ToastWidget extends StatefulWidget {
  final InternetStatus status;
  final ToastOfflineUI config;
  final Widget child;

  const ToastWidget({
    super.key,
    required this.status,
    required this.config,
    required this.child,
  });

  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // If the widget is created while already offline, trigger the animation immediately!
    if (widget.status != InternetStatus.connected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _isVisible = true);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant ToastWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      setState(() {
        _isVisible = widget.status != InternetStatus.connected;
      });
    }
  }

  Alignment _getAlignment() {
    switch (widget.config.position) {
      case ToastPosition.top:
        return Alignment.topCenter;
      case ToastPosition.center:
        return Alignment.center;
      case ToastPosition.bottom:
        return Alignment.bottomCenter;
      case ToastPosition.topLeft:
        return Alignment.topLeft;
      case ToastPosition.topRight:
        return Alignment.topRight;
      case ToastPosition.bottomLeft:
        return Alignment.bottomLeft;
      case ToastPosition.bottomRight:
        return Alignment.bottomRight;
    }
  }

  Offset _getHiddenOffset() {
    switch (widget.config.position) {
      case ToastPosition.top:
        return const Offset(0, -1.0);
      case ToastPosition.center:
        return const Offset(0, 0.5);
      case ToastPosition.bottom:
        return const Offset(0, 1.0);
      case ToastPosition.topLeft:
        return const Offset(-1.0, -1.0);
      case ToastPosition.topRight:
        return const Offset(1.0, -1.0);
      case ToastPosition.bottomLeft:
        return const Offset(-1.0, 1.0);
      case ToastPosition.bottomRight:
        return const Offset(1.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.config.backgroundColor ?? const Color(0xFF323232);
    final iconColor = widget.config.iconColor ?? Colors.white;
    final iconSize = widget.config.iconSize ?? 20.0;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: SafeArea(
            child: IgnorePointer(
              ignoring: !_isVisible,
              child: Align(
                alignment: _getAlignment(),
                child: AnimatedSlide(
                  offset: _isVisible ? Offset.zero : _getHiddenOffset(),
                  duration: widget.config.animationDuration,
                  curve: Curves.easeOutBack, // Gives a satisfying spring/pop effect
                  child: AnimatedOpacity(
                    opacity: _isVisible ? 1.0 : 0.0,
                    duration: widget.config.animationDuration,
                    curve: Curves.easeInOut,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        margin: widget.config.margin,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: widget.config.borderRadius,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              color: iconColor,
                              size: iconSize,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                widget.config.message,
                                style: widget.config.textStyle ??
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
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