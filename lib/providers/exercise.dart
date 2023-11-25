import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_tracker/models/model.dart';

class ExerciseState {
  final List<Exercise> exercises;

  ExerciseState({
    required this.exercises,
  });
}

class ExerciseNotifier extends StateNotifier<ExerciseState> {
  ExerciseNotifier()
      : super(ExerciseState(
          exercises: [],
        ));

  Future load() async {
    List<Exercise> exercises = await Exercise().select().toList(preload: true);

    state = ExerciseState(
      exercises: exercises,
    );
  }

  Future<Exercise?> addExercise(String name) async {
    final exercise = Exercise(
      name: name,
      created_at: DateTime.now(),
    );

    final id = await exercise.save();

    if (id != null) {
      exercise.id = id;

      return exercise;
    }

    return null;
  }

  Future<int> getExerciceId(String name) async {
    final exercise = await Exercise().select().name.equals(name).toSingle();

    if (exercise == null) {
      final newExercise = await addExercise(name);
      return newExercise!.id!;
    }

    return exercise.id!;
  }

  Future<Exercise?> getByName(String name) async {
    final exercise = await Exercise()
        .select()
        .where(
          'name = ?',
          parameterValue: name,
        )
        .toSingle();

    return exercise;
  }
}

final exerciseProvider = StateNotifierProvider<ExerciseNotifier, ExerciseState>(
  (ref) => ExerciseNotifier(),
);
