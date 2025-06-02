import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectorService {
  static const double _shakeThreshold = 2.7;
  static const int _shakeCooldownMs = 1000; // 1 second cooldown

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;

  // Callbacks
  Function()? _onShakeDetected;

  bool _isListening = false;

  /// Start listening for shake gestures
  void startListening({required Function() onShakeDetected}) {
    if (_isListening) return;

    _onShakeDetected = onShakeDetected;
    _isListening = true;

    _accelerometerSubscription = accelerometerEvents.listen(
      _onAccelerometerEvent,
      onError: _onAccelerometerError,
      cancelOnError: false,
    );
  }

  /// Stop listening for shake gestures
  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _onShakeDetected = null;
    _isListening = false;
  }

  /// Handle accelerometer events
  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Calculate the magnitude of acceleration
    final double acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Detect shake based on threshold
    if (acceleration > _shakeThreshold) {
      _handleShakeDetected();
    }
  }

  /// Handle shake detection with cooldown
  void _handleShakeDetected() {
    final DateTime now = DateTime.now();

    // Check cooldown period
    if (_lastShakeTime != null) {
      final int timeDifference =
          now.millisecondsSinceEpoch - _lastShakeTime!.millisecondsSinceEpoch;

      if (timeDifference < _shakeCooldownMs) {
        return; // Still in cooldown period
      }
    }

    _lastShakeTime = now;

    // Trigger callback
    _onShakeDetected?.call();
  }

  /// Handle accelerometer errors
  void _onAccelerometerError(dynamic error) {
    print('Accelerometer error: $error');
    // You might want to show a user-friendly error message here
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Dispose resources
  void dispose() {
    stopListening();
  }
}

/// Singleton instance for global access
class ShakeDetector {
  static final ShakeDetector _instance = ShakeDetector._internal();
  factory ShakeDetector() => _instance;
  ShakeDetector._internal();

  final ShakeDetectorService _service = ShakeDetectorService();

  /// Start listening for shakes
  void startListening({required Function() onShakeDetected}) {
    _service.startListening(onShakeDetected: onShakeDetected);
  }

  /// Stop listening for shakes
  void stopListening() {
    _service.stopListening();
  }

  /// Check if listening
  bool get isListening => _service.isListening;

  /// Dispose
  void dispose() {
    _service.dispose();
  }
}
