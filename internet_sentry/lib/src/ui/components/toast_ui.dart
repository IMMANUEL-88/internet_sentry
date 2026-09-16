import 'package:flutter/material.dart';
import '../../core/internet_status.dart';
import '../models/offline_ui.dart';

class ToastWidget extends StatelessWidget {
  final InternetStatus status;
  final ToastOfflineUI config;

  const ToastWidget({
    super.key,
    required this.status,
    required this.config,
  });

  Alignment _getAlignment() {
    switch (config.position) {
      case ToastPosition.top:
        return Alignment.topCenter;
      case ToastPosition.center:
        return Alignment.center;
      case ToastPosition.bottom:
        return Alignment.bottomCenter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = status != InternetStatus.connected;
    
    // Default to a dark, neutral color for toasts
    final bgColor = config.backgroundColor ?? const Color(0xFF323232);

    return Positioned.fill(
      child: SafeArea(
        child: IgnorePointer(
          ignoring: !isVisible, // Don't block touches when hidden
          child: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: config.animationDuration,
            curve: Curves.easeInOut,
            child: Align(
              alignment: _getAlignment(),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: config.margin,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: config.borderRadius,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Keep toast wrapped tightly to content
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          config.message,
                          style: config.textStyle ??
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
    );
  }
}