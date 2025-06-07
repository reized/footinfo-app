import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectorService {
  static const double _shakeThreshold = 2.7;
  static const int _shakeCooldownMs = 1000;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;

  Function()? _onShakeDetected;
  Function(double)? _onAccelerationUpdate;

  bool _isListening = false;

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

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _onShakeDetected = null;
    _onAccelerationUpdate = null;
    _isListening = false;
    print('ShakeDetector: Stopped listening for shakes');
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final double acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    final double movementAcceleration = (acceleration - 9.8).abs();

    _onAccelerationUpdate?.call(movementAcceleration);

    if (movementAcceleration > _shakeThreshold) {
      print(
        'ShakeDetector: Shake detected! Acceleration: $movementAcceleration (threshold: $_shakeThreshold)',
      );
      _handleShakeDetected();
    }
  }

  void _handleShakeDetected() {
    final DateTime now = DateTime.now();

    if (_lastShakeTime != null) {
      final int timeDifference =
          now.millisecondsSinceEpoch - _lastShakeTime!.millisecondsSinceEpoch;

      if (timeDifference < _shakeCooldownMs) {
        print('ShakeDetector: Shake ignored due to cooldown');
        return;
      }
    }

    _lastShakeTime = now;
    print('ShakeDetector: Shake event triggered!');

    _onShakeDetected?.call();
  }

  void _onAccelerometerError(dynamic error) {
    print('ShakeDetector: Accelerometer error: $error');
  }

  bool get isListening => _isListening;

  double get threshold => _shakeThreshold;

  void dispose() {
    stopListening();
  }
}

class ShakeDetector {
  static final ShakeDetector _instance = ShakeDetector._internal();
  factory ShakeDetector() => _instance;
  ShakeDetector._internal();

  final ShakeDetectorService _service = ShakeDetectorService();

  void startListening({
    required Function() onShakeDetected,
    Function(double)? onAccelerationUpdate,
  }) {
    _service.startListening(
      onShakeDetected: onShakeDetected,
      onAccelerationUpdate: onAccelerationUpdate,
    );
  }

  void stopListening() {
    _service.stopListening();
  }

  bool get isListening => _service.isListening;

  double get threshold => _service.threshold;

  void dispose() {
    _service.dispose();
  }
}
