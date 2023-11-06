import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_tracker/models/model.dart';

enum PerformanceType { none }

class PerformanceState {}

class PerformanceNotifier extends StateNotifier<PerformanceState> {
  PerformanceNotifier()
      : super(
          PerformanceState(),
        );

  Future addPerf(Performance performance) async {
    if (performance.exercise_id == null) {
      throw "Exercise name is required";
    }

    if (performance.sets == null) {
      throw "Sets is required";
    }

    if (performance.reps == null) {
      throw "Reps is required";
    }

    if (performance.weight == null) {
      throw "Weight is required";
    }

    await performance.save();
  }
}

final performanceProvider =
    StateNotifierProvider<PerformanceNotifier, PerformanceState>(
  (ref) => PerformanceNotifier(),
);
