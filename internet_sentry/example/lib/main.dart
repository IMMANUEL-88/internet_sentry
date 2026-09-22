import 'package:flutter/material.dart';
import 'package:internet_sentry/internet_sentry.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // We manage the controller ourselves in the example so we can show its state on screen.
  final InternetController _controller = InternetController(
    debounceDuration: const Duration(milliseconds: 500),
  );

  // Default to the Banner UI
  OfflineUI _currentOfflineUI = OfflineUI.banner(
    pushDown: true,
    disconnectedMessage: 'Oops! No Internet Connection',
    disconnectedColor: Colors.redAccent,
    backOnlineColor: Colors.green,
    backOnlineMessage: "Internet is back!",
    showBackOnlineNotification: true,
    textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    iconColor: Colors.white,
    iconSize: 24,
    animationDuration: Duration(milliseconds: 700)
  );

  // OfflineUI _currentOfflineUI = OfflineUI.toast(
  //   message: "You're offline",
  //   backgroundColor: Colors.redAccent,
  //   position: ToastPosition.bottom,
  //   borderRadius: BorderRadius.circular(12.0),
  //   margin: EdgeInsetsGeometry.all(12),
  //   textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //   animationDuration: Duration(milliseconds: 400),
  //   iconColor: Colors.white,
  //   iconSize: 24,
  // );

  // OfflineUI _currentOfflineUI = OfflineUI.overlay(
  //   backgroundColor: Colors.black54,
  //   blur: 2,
  //   message: "No Internet Connection",
  //   textStyle: TextStyle(color: Colors.white, fontSize: 20),
  //   showRetryButton: true,
  //   // opacity: 0
  //   iconColor: Colors.white,
  //   iconSize: 80,
  //   buttonStyle: ElevatedButton.styleFrom(
  //     backgroundColor: Colors.black,
  //     foregroundColor: Colors.yellow,
  //     textStyle: const TextStyle(fontWeight: FontWeight.bold),
  //   ),
  // );

  // OfflineUI _currentOfflineUI = OfflineUI.page(
  //   backgroundColor: Colors.white,
  //   customIcon: Image.asset(
  //     'assets/dash-fainting.gif',
  //     width: 150,
  //   ),
  //   title: "New Offline Page",
  //   titleStyle: TextStyle(
  //     fontSize: 28,
  //     fontWeight: FontWeight.bold,
  //     color: Colors.black,
  //   ),
  //   message: "You are currently offline. Please check your internet connection.",
  //   messageStyle: TextStyle(
  //     fontSize: 18,
  //     color: Colors.grey[700],
  //   ),
  //   showRetryButton: true,
  //   buttonStyle: ElevatedButton.styleFrom(
  //     backgroundColor: Colors.blue,
  //     foregroundColor: Colors.white,
  //   ),
  // );

  // OfflineUI _currentOfflineUI = OfflineUI.custom(
  //   builder: (context, status, retry) {
  //     return Align(
  //       alignment: Alignment.bottomRight,
  //       child: Container(
  //         width: 200,
  //         margin: const EdgeInsets.all(32),
  //         decoration: BoxDecoration(
  //           color: Colors.red,
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Row(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Icon(Icons.wifi_off, size: 24, color: Colors.white),
  //               const SizedBox(width: 8),
  //               Text(
  //                 "No Internet Connection",
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   },
  //   backgroundColor: Colors.white70
  // );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeUI(OfflineUI newUI) {
    setState(() {
      _currentOfflineUI = newUI;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internet Sentry Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return InternetWrapper(
          controller: _controller,
          offlineUI: _currentOfflineUI,
          restoredSnackbarMessage: "Woohoo! We are back online!",
          restoredSnackbarColor: Colors.teal,
          restoredSnackbarTextStyle: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          child: child!,
        );
      },
      home: HomeScreen(controller: _controller, onUIChange: _changeUI),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final InternetController controller;
  final void Function(OfflineUI) onUIChange;

  const HomeScreen({
    super.key,
    required this.controller,
    required this.onUIChange,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet Sentry Playground'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display Current Network Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Current Status',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder(
                      valueListenable: controller,
                      builder: (context, status, child) {
                        Color statusColor = Colors.grey;
                        String statusText = 'Disconnected';

                        switch (status) {
                          case InternetStatus.connected:
                            statusColor = Colors.green;
                            statusText = 'Connected';
                            break;
                          case InternetStatus.disconnected:
                            statusColor = Colors.red;
                            statusText = 'Disconnected';
                            break;
                          case InternetStatus.checking:
                          case InternetStatus.restoring:
                            statusColor = Colors.orange;
                            statusText = 'Checking/Restoring...';
                            break;
                        }

                        return Chip(
                          backgroundColor: statusColor.withValues(alpha: 0.2),
                          label: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Controls to switch UI Modes
            const Text(
              'Select Offline UI Mode:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionChip(
                  label: const Text('Top Banner'),
                  onPressed: () => onUIChange(
                    OfflineUI.banner(
                      pushDown: true,
                      disconnectedMessage: 'Oops! No Internet Connection',
                      disconnectedColor: Colors.redAccent,
                      backOnlineColor: Colors.green,
                      backOnlineMessage: "Internet is back!",
                      showBackOnlineNotification: true,
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      iconColor: Colors.white,
                      iconSize: 24,
                    ),
                  ),
                ),
                ActionChip(
                  label: const Text('Floating Toast'),
                  onPressed: () => onUIChange(
                    OfflineUI.toast(
                      message: "You're offline",
                      backgroundColor: Colors.redAccent,
                      position: ToastPosition.bottom,
                      borderRadius: BorderRadius.circular(12.0),
                      margin: EdgeInsetsGeometry.all(12),
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      animationDuration: Duration(milliseconds: 400),
                      iconColor: Colors.white,
                      iconSize: 24,
                    ),
                  ),
                ),
                ActionChip(
                  label: const Text('Blocking Overlay'),
                  onPressed: () => onUIChange(
                    OfflineUI.overlay(
                      backgroundColor: Colors.black54,
                      retryFailedMessage: "check your settings.",
                      retryFailedMessageColor: Colors.white,
                    ),
                  ),
                ),
                ActionChip(
                  label: const Text('Full Page'),
                  onPressed: () => onUIChange(
                    OfflineUI.page(
                      backgroundColor: Colors.black54,
                      retryFailedMessage: "check your settings.",
                      retryFailedMessageColor: Colors.white,
                    ),
                  ),
                ),
                ActionChip(
                  label: const Text('Custom UI'),
                  onPressed: () => onUIChange(
                    OfflineUI.custom(
                      builder: (context, status, retry) {
                        if (status == InternetStatus.connected)
                          return const SizedBox.shrink();

                        return Positioned.fill(
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.5),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.wifi_off, size: 80),
                                  Text(
                                    "No Internet",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Manual Test Button
            ElevatedButton.icon(
              onPressed: () {
                // Manually trigger a reachability check
                controller.retry();
              },
              icon: const Icon(Icons.radar),
              label: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Force Connectivity Check'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Turn off your Wi-Fi/Data in the emulator or on your phone to see the UI react instantly!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
