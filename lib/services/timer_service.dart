import 'dart:async';

/// Reusable countdown timer.
/// Used by WorkoutController for both duration-exercise and rest timers.
class TimerService {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  bool get isRunning => _timer != null && _timer!.isActive;
  Duration get remaining => _remaining;

  void start({
    required Duration duration,
    required void Function(Duration remaining) onTick,
    required void Function() onDone,
  }) {
    cancel();
    _remaining = duration;
    onTick(_remaining);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remaining -= const Duration(seconds: 1);
      if (_remaining <= Duration.zero) {
        _remaining = Duration.zero;
        cancel();
        onTick(_remaining);
        onDone();
      } else {
        onTick(_remaining);
      }
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _remaining = Duration.zero;
  }

  void dispose() => cancel();
}
