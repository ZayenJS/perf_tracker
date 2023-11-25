import 'package:workout_performance_tracker/data/exercises.dart';
import 'package:workout_performance_tracker/models/model.dart';
import 'package:workout_performance_tracker/utils/main.dart';

Future loadInitialData() async {
  await Exercise().upsertAll(exercisesData);
  printDebug("EXERCISES LOADED", after: "=");
}
