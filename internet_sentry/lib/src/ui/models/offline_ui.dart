import 'package:flutter/widgets.dart';

import '../../core/internet_controller.dart';
import '../../core/internet_status.dart';
import '../components/banner_ui.dart';
import '../components/overlay_ui.dart';
import '../components/page_ui.dart';
import '../components/toast_ui.dart';

/// Positions available for the floating toast UI.
enum ToastPosition { top, center, bottom }

/// Signature for custom offline UI builders.
typedef OfflineWidgetBuilder =
    Widget Function(
      BuildContext context,
      InternetStatus status,
      VoidCallback retry,
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
    double? iconSize
  }) = BannerOfflineUI;

  factory OfflineUI.toast({
    String message,
    ToastPosition position,
    EdgeInsetsGeometry margin,
    BorderRadiusGeometry borderRadius,
    Color? backgroundColor,
    TextStyle? textStyle,
    Duration animationDuration,
  }) = ToastOfflineUI;

  factory OfflineUI.overlay({
    String message,
    bool showRetryButton,
    bool blockInteraction,
    double opacity,
    double blur,
    Color? backgroundColor,
    TextStyle? textStyle,
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
  }) = PageOfflineUI;

  /// Allows complete customization of the offline UI.
  factory OfflineUI.custom({required OfflineWidgetBuilder builder}) =
      CustomOfflineUI;

  /// Internal method used by the wrapper to render the configured UI.
  Widget buildWidget(
    BuildContext context,
    InternetStatus status,
    InternetController controller,
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
  });

  @override
  Widget buildWidget(
    BuildContext context,
    InternetStatus status,
    InternetController controller,
  ) {
    return BannerWidget(status: status, config: this);
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

  const ToastOfflineUI({
    this.message = 'No internet connection',
    this.position = ToastPosition.bottom,
    this.margin = const EdgeInsets.all(24.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.backgroundColor,
    this.textStyle,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget buildWidget(
    BuildContext context,
    InternetStatus status,
    InternetController controller,
  ) {
    return ToastWidget(status: status, config: this);
  }
}

// --- OVERLAY CONFIG ---
class OverlayOfflineUI extends OfflineUI {
  final String message;
  final bool showRetryButton;
  final bool blockInteraction;
  final double opacity;
  final double blur;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const OverlayOfflineUI({
    this.message = 'No internet connection',
    this.showRetryButton = true,
    this.blockInteraction = false,
    this.opacity = 0.7,
    this.blur = 2.0,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget buildWidget(
    BuildContext context,
    InternetStatus status,
    InternetController controller,
  ) {
    return OverlayWidget(status: status, config: this, controller: controller);
  }
}

// --- PAGE CONFIG (NEW) ---
class PageOfflineUI extends OfflineUI {
  final String title;
  final String message;
  final bool showRetryButton;
  final Widget? customIcon;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;

  const PageOfflineUI({
    this.title = 'You are offline',
    this.message = 'Please check your internet connection.',
    this.showRetryButton = true,
    this.customIcon,
    this.backgroundColor,
    this.titleStyle,
    this.messageStyle,
  });

  @override
  Widget buildWidget(
    BuildContext context,
    InternetStatus status,
    InternetController controller,
  ) {
    return PageWidget(status: status, config: this, controller: controller);
  }
}

// --- CUSTOM CONFIG (NEW) ---
class CustomOfflineUI extends OfflineUI {
  final OfflineWidgetBuilder builder;

  const CustomOfflineUI({required this.builder});

  @override
  Widget buildWidget(
    BuildContext context,
    InternetStatus status,
    InternetController controller,
  ) {
    // We simply execute the user's builder function, passing the required parameters.
    return builder(context, status, () => controller.retry());
  }
}
