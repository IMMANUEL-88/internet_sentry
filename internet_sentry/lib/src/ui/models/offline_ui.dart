import 'package:flutter/material.dart';
import '../../core/internet_controller.dart';
import '../../core/internet_status.dart';
import '../components/banner_ui.dart';
import '../components/overlay_ui.dart';
import '../components/page_ui.dart';
import '../components/toast_ui.dart';

/// Positions available for the floating toast UI.
enum ToastPosition {
  top,
  center,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Signature for custom offline UI builders.
typedef OfflineWidgetBuilder =
    Widget Function(
      BuildContext context,
      InternetStatus status,
      VoidCallback retry,
      // Widget child,
    );

/// Base configuration class for defining how the offline UI should look and behave.
abstract class OfflineUI {
  const OfflineUI();

  factory OfflineUI.banner({
    String disconnectedMessage,
    String restoringMessage,
    String backOnlineMessage,
    Color? disconnectedColor,
    Color? restoringColor,
    Color? backOnlineColor,
    TextStyle? textStyle,
    Duration animationDuration,
    bool showBackOnlineNotification,
    Color? iconColor,
    double? iconSize,
    bool pushDown,
  }) = BannerOfflineUI;

  factory OfflineUI.toast({
    String message,
    ToastPosition position,
    EdgeInsetsGeometry margin,
    BorderRadiusGeometry borderRadius,
    Color? backgroundColor,
    TextStyle? textStyle,
    Duration animationDuration,
    Color? iconColor,
    double? iconSize,
  }) = ToastOfflineUI;

  factory OfflineUI.overlay({
    String message,
    bool showRetryButton,
    double opacity,
    double blur,
    Color? backgroundColor,
    TextStyle? textStyle,
    Color? iconColor,
    double? iconSize,
    ButtonStyle? buttonStyle,
    String? retryFailedMessage,
    Color? retryFailedMessageColor,
  }) = OverlayOfflineUI;

  /// Displays a full-screen offline page that hides the underlying application.
  factory OfflineUI.page({
    String title,
    String message,
    bool showRetryButton,
    Widget? customIcon,
    Color? backgroundColor,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    ButtonStyle? buttonStyle,
    String? retryFailedMessage,
    Color? retryFailedMessageColor,
  }) = PageOfflineUI;

  /// Allows complete customization of the offline UI.
  factory OfflineUI.custom({
    required OfflineWidgetBuilder builder,
    Color? backgroundColor,
  }) = CustomOfflineUI;

  /// Internal method used by the wrapper to render the configured UI.
  Widget buildWidget(
    BuildContext context,
    InternetStatus status,
    InternetController controller,
    Widget child,
  );
}

// --- BANNER CONFIG ---
class BannerOfflineUI extends OfflineUI {
  final String disconnectedMessage;
  final String restoringMessage;
  final String backOnlineMessage;
  final Color? disconnectedColor;
  final Color? restoringColor;
  final Color? backOnlineColor;
  final TextStyle? textStyle;
  final Duration animationDuration;
  final bool showBackOnlineNotification;
  final Color? iconColor;
  final double? iconSize;
  final bool pushDown;

  const BannerOfflineUI({
    this.disconnectedMessage = 'No internet connection',
    this.restoringMessage = 'Trying to reconnect...',
    this.backOnlineMessage = 'Back online',
    this.disconnectedColor,
    this.restoringColor,
    this.backOnlineColor,
    this.textStyle,
    this.animationDuration = const Duration(milliseconds: 400),
    this.showBackOnlineNotification = true,
    this.iconColor,
    this.iconSize,
    this.pushDown = false,
  });

  @override
  Widget buildWidget(
    BuildContext context,
    InternetStatus status,
    InternetController controller,
    Widget child,
  ) {
    return BannerWidget(status: status, config: this, child: child);
  }
}

// --- TOAST CONFIG ---
class ToastOfflineUI extends OfflineUI {
  final String message;
  final ToastPosition position;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Duration animationDuration;
  final Color? iconColor;
  final double? iconSize;

  const ToastOfflineUI({
    this.message = 'No internet connection',
    this.position = ToastPosition.bottom,
    this.margin = const EdgeInsets.all(24.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.backgroundColor,
    this.textStyle,
    this.animationDuration = const Duration(milliseconds: 300),
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget buildWidget(
    BuildContext context,
    InternetStatus status,
    InternetController controller,
    Widget child,
  ) {
    return ToastWidget(status: status, config: this, child: child);
  }
}

// --- OVERLAY CONFIG ---
class OverlayOfflineUI extends OfflineUI {
  final String message;
  final bool showRetryButton;
  final String? retryFailedMessage;
  final double opacity;
  final double blur;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double? iconSize;
  final ButtonStyle? buttonStyle;
  final Color? retryFailedMessageColor;

  const OverlayOfflineUI({
    this.message = 'No internet connection',
    this.showRetryButton = true,
    this.retryFailedMessage,
    this.opacity = 0.7,
    this.blur = 2.0,
    this.backgroundColor,
    this.textStyle,
    this.iconColor,
    this.iconSize,
    this.buttonStyle,
    this.retryFailedMessageColor,
  });

  @override
  Widget buildWidget(
    BuildContext context,
    InternetStatus status,
    InternetController controller,
    Widget child,
  ) {
    return OverlayWidget(
      status: status,
      config: this,
      controller: controller,
      child: child,
    );
  }
}

// --- PAGE CONFIG (NEW) ---
class PageOfflineUI extends OfflineUI {
  final String title;
  final String message;
  final bool showRetryButton;
  final String? retryFailedMessage;
  final Widget? customIcon;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final ButtonStyle? buttonStyle;
  final Color? retryFailedMessageColor;

  const PageOfflineUI({
    this.title = 'You are offline',
    this.message = 'Please check your internet connection.',
    this.showRetryButton = true,
    this.retryFailedMessage,
    this.customIcon,
    this.backgroundColor,
    this.titleStyle,
    this.messageStyle,
    this.buttonStyle,
    this.retryFailedMessageColor,
  });

  @override
  Widget buildWidget(
    BuildContext context,
    InternetStatus status,
    InternetController controller,
    Widget child,
  ) {
    return PageWidget(
      status: status,
      config: this,
      controller: controller,
      child: child,
    );
  }
}

// --- CUSTOM CONFIG (NEW) ---
class CustomOfflineUI extends OfflineUI {
  final OfflineWidgetBuilder builder;
  final Duration animationDuration;
  final Color? backgroundColor;

  const CustomOfflineUI({
    required this.builder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.backgroundColor,
  });

  @override
  Widget buildWidget(
    BuildContext context,
    InternetStatus status,
    InternetController controller,
    Widget child,
  ) {
    final isVisible = status != InternetStatus.connected;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isVisible,
            child: AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: animationDuration,
              child: Material(
                color: backgroundColor ?? Colors.transparent,
                child: builder(context, status, () => controller.retry()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
