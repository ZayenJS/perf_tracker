import 'package:perf_tracker/data/exercises.dart';
import 'package:perf_tracker/models/model.dart';
import 'package:perf_tracker/utils/main.dart';

Future loadInitialData() async {
  await Exercise().upsertAll(exercisesData);
  printDebug("EXERCISES LOADED", after: "=");
}
