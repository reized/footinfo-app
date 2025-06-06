import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectorService {
  // Lowered threshold for easier detection
  static const double _shakeThreshold = 2.7; // Was 2.7, now 1.8
  static const int _shakeCooldownMs = 1000; // 1 second cooldown

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;

  // Callbacks
  Function()? _onShakeDetected;
  Function(double)? _onAccelerationUpdate; // For debugging

  bool _isListening = false;

  /// Start listening for shake gestures
  void startListening({
    required Function() onShakeDetected,
    Function(double)? onAccelerationUpdate,
  }) {
    if (_isListening) return;

    _onShakeDetected = onShakeDetected;
    _onAccelerationUpdate = onAccelerationUpdate;
    _isListening = true;

    print(
      'ShakeDetector: Starting to listen for shakes (threshold: $_shakeThreshold)',
    );

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
    _onAccelerationUpdate = null;
    _isListening = false;
    print('ShakeDetector: Stopped listening for shakes');
  }

  /// Handle accelerometer events
  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Calculate the magnitude of acceleration
    final double acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Subtract gravity (approximately 9.8) to get device movement
    final double movementAcceleration = (acceleration - 9.8).abs();

    // Debug callback
    _onAccelerationUpdate?.call(movementAcceleration);

    // Detect shake based on threshold
    if (movementAcceleration > _shakeThreshold) {
      print(
        'ShakeDetector: Shake detected! Acceleration: $movementAcceleration (threshold: $_shakeThreshold)',
      );
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
        print('ShakeDetector: Shake ignored due to cooldown');
        return; // Still in cooldown period
      }
    }

    _lastShakeTime = now;
    print('ShakeDetector: Shake event triggered!');

    // Trigger callback
    _onShakeDetected?.call();
  }

  /// Handle accelerometer errors
  void _onAccelerometerError(dynamic error) {
    print('ShakeDetector: Accelerometer error: $error');
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Get current threshold
  double get threshold => _shakeThreshold;

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
  void startListening({
    required Function() onShakeDetected,
    Function(double)? onAccelerationUpdate,
  }) {
    _service.startListening(
      onShakeDetected: onShakeDetected,
      onAccelerationUpdate: onAccelerationUpdate,
    );
  }

  /// Stop listening for shakes
  void stopListening() {
    _service.stopListening();
  }

  /// Check if listening
  bool get isListening => _service.isListening;

  /// Get threshold
  double get threshold => _service.threshold;

  /// Dispose
  void dispose() {
    _service.dispose();
  }
}
