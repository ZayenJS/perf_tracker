import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/models/model.dart';
import 'package:workout_performance_tracker/utils/main.dart';

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

    exercises = exercises.map((e) {
      e.name = e.name!
          .split(' ')
          .map((e) => e[0].toUpperCase() + e.substring(1))
          .join(' ');

      return e;
    }).toList();

    state = ExerciseState(
      exercises: exercises,
    );
  }

  Future<Exercise?> addExercise(String name) async {
    final exercise = Exercise(
      name: name.trim().toLowerCase(),
      created_at: DateTime.now(),
    );

    final id = await exercise.save();

    if (id != null) {
      exercise.id = id;

      exercise.name = exercise.name!
          .split(' ')
          .map((e) => e[0].toUpperCase() + e.substring(1))
          .join(' ');

      state = ExerciseState(
        exercises: [...state.exercises, exercise],
      );

      return exercise;
    }

    return null;
  }

  Future<int> getExerciceId(String name) async {
    final exercise = await Exercise()
        .select()
        .name
        .equals(name.trim().toLowerCase())
        .toSingle();

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
          parameterValue: name.trim().toLowerCase(),
        )
        .toSingle();

    return exercise;
  }

  Future deleteExercise(int id) async {
    final result = await Exercise().select().id.equals(id).delete(true);

    if (!result.success) {
      return;
    }

    final updatedExercises = [...state.exercises];
    updatedExercises.removeWhere((e) => e.id == id);

    state = ExerciseState(
      exercises: updatedExercises,
    );
  }

  Future editExercise(int id, String name) async {
    final exercise = await Exercise().select().id.equals(id).toSingle();

    if (exercise == null) {
      return;
    }

    exercise.name = name;
    await exercise.save();

    final updatedExercises = [...state.exercises];
    final index = updatedExercises.indexWhere((e) => e.id == id);
    updatedExercises[index] = exercise;

    state = ExerciseState(
      exercises: updatedExercises,
    );
  }
}

final exerciseProvider = StateNotifierProvider<ExerciseNotifier, ExerciseState>(
  (ref) => ExerciseNotifier(),
);
