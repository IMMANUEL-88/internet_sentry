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
    disconnectedMessage: 'Oops! No Internet Connection',
    disconnectedColor: Colors.redAccent,
    backOnlineColor: Colors.green,
    backOnlineMessage: "Internet is back!",
    showBackOnlineNotification: true,
    textStyle: TextStyle(color: Colors.black),
    iconColor: Colors.yellow,
    iconSize: 24
  );

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // IMPORTANT: Wrap the builder to ensure the UI floats over everything!
      builder: (context, child) {
        return InternetWrapper(
          controller: _controller,
          offlineUI: _currentOfflineUI,
          child: child!,
        );
      },
      home: HomeScreen(controller: _controller, onUIChange: _changeUI),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final InternetController controller;
  // final ValueChanged<OfflineUI> onUIChange;
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
                      disconnectedMessage: "Oops! No Internet Connection",
                    ),
                  ),
                ),
                ActionChip(
                  label: const Text('Floating Toast'),
                  onPressed: () => onUIChange(OfflineUI.toast()),
                ),
                ActionChip(
                  label: const Text('Blocking Overlay'),
                  onPressed: () =>
                      onUIChange(OfflineUI.overlay(blockInteraction: true)),
                ),
                ActionChip(
                  label: const Text('Full Page'),
                  onPressed: () => onUIChange(OfflineUI.page()),
                ),
                ActionChip(
                  label: const Text('Custom UI'),
                  onPressed: () => onUIChange(
                    OfflineUI.custom(
                      builder: (context, status, retry) {
                        return Material(
                          color: Colors.transparent,
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
