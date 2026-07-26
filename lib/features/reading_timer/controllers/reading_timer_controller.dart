import 'dart:async';

import 'package:get/get.dart';

enum StandaloneTimerState { idle, running, paused, stopped }

class ReadingTimerController extends GetxController {
  final timerState = StandaloneTimerState.idle.obs;
  final elapsedSeconds = 0.obs;

  Timer? _tick;
  DateTime? _startedAt;
  int _accumulated = 0;

  void start() {
    if (timerState.value == StandaloneTimerState.running) return;
    if (timerState.value == StandaloneTimerState.idle ||
        timerState.value == StandaloneTimerState.stopped) {
      _accumulated = 0;
      elapsedSeconds.value = 0;
    }
    _startedAt = DateTime.now();
    timerState.value = StandaloneTimerState.running;
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final running = DateTime.now().difference(_startedAt!).inSeconds;
      elapsedSeconds.value = _accumulated + running;
    });
  }

  void pause() {
    if (timerState.value != StandaloneTimerState.running) return;
    _accumulated = elapsedSeconds.value;
    _startedAt = null;
    _tick?.cancel();
    timerState.value = StandaloneTimerState.paused;
  }

  void stop() {
    if (timerState.value == StandaloneTimerState.running &&
        _startedAt != null) {
      _accumulated = elapsedSeconds.value;
    }
    _tick?.cancel();
    timerState.value = StandaloneTimerState.stopped;
  }

  void reset() {
    _tick?.cancel();
    _startedAt = null;
    _accumulated = 0;
    elapsedSeconds.value = 0;
    timerState.value = StandaloneTimerState.idle;
  }

  @override
  void onClose() {
    _tick?.cancel();
    super.onClose();
  }
}
