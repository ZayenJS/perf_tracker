import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_tracker/models/model.dart';

enum PerformanceType { none }

class PerformanceState {
  final String? exerciceName;
  final int? reps;
  final int? sets;
  final double? weight;
  final DateTime? date;

  PerformanceState({
    this.exerciceName,
    this.reps,
    this.sets,
    this.weight,
    this.date,
  });

  PerformanceState createImmutable({
    exerciceName,
    reps,
    sets,
    weight,
    date,
  }) {
    return PerformanceState(
      exerciceName: exerciceName == PerformanceType.none
          ? null
          : exerciceName ?? this.exerciceName,
      reps: reps == PerformanceType.none ? null : reps ?? this.reps,
      sets: sets == PerformanceType.none ? null : sets ?? this.sets,
      weight: weight == PerformanceType.none ? null : weight ?? this.weight,
      date: date == PerformanceType.none ? null : date ?? this.date,
    );
  }
}

class PerformanceNotifier extends StateNotifier<PerformanceState> {
  PerformanceNotifier()
      : super(
          PerformanceState(
            exerciceName: null,
            reps: null,
            sets: null,
            weight: null,
          ),
        );

  bool _isIncomplete() {
    if (state.reps == null) return true;
    if (state.sets == null) return true;
    if (state.weight == null) return true;
    if (state.date == null) return true;

    return false;
  }

  Future addPerf() async {
    if (_isIncomplete()) {
      throw "A value is missing to register a new perf";
    }

    Exercise? exercise = await Exercise()
        .select()
        .where("name = ?", parameterValue: state.exerciceName)
        .toSingle();

    int? exerciseId = exercise?.id;

    if (exercise == null) {
      exercise = Exercise(
        name: state.exerciceName,
        created_at: state.date,
      );
      exerciseId = await exercise.save();
    }

    if (exerciseId == null) {
      throw "An error occured while saving data.";
    }

    final performance = Performance(
      exercise_id: exerciseId,
      reps: state.reps,
      sets: state.sets,
      weight: state.weight,
      created_at: state.date,
    );

    await performance.save();
  }

  void changeExerciseName(String? value) {
    state = state.createImmutable(exerciceName: value ?? PerformanceType.none);
  }

  void changeReps(int? value) {
    state = state.createImmutable(reps: value ?? PerformanceType.none);
  }

  void changeSets(int? value) {
    state = state.createImmutable(sets: value ?? PerformanceType.none);
  }

  void changeWeight(double? value) {
    state = state.createImmutable(weight: value ?? PerformanceType.none);
  }

  void changeDate(DateTime? value) {
    state = state.createImmutable(date: value ?? PerformanceType.none);
  }

  void reset() {
    state = PerformanceState(
      exerciceName: null,
      reps: null,
      sets: null,
      weight: null,
      date: null,
    );
  }
}

final performanceProvider =
    StateNotifierProvider<PerformanceNotifier, PerformanceState>(
  (ref) => PerformanceNotifier(),
);
