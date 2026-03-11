import 'dart:async';

/// Debounce utility class
class Debounce {
  final Duration delay;
  Timer? _timer;

  Debounce({this.delay = const Duration(milliseconds: 500)});

  /// Call the function after delay
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel the debounce
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose the debounce
  void dispose() {
    _timer?.cancel();
  }
}
