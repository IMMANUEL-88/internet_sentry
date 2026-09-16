/// Represents the current state of internet connectivity.
enum InternetStatus {
  /// The device has an active network connection and internet is reachable.
  connected,

  /// The device has no network connection, or the internet is unreachable.
  disconnected,

  /// An initial or standard check is actively running.
  checking,

  /// A check is actively running after a disconnected state (trying to reconnect).
  restoring,
}