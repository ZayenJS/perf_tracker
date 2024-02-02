import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/google.dart';
import 'package:workout_performance_tracker/providers/exercise.dart';
import 'package:workout_performance_tracker/providers/settings.dart';
import 'package:workout_performance_tracker/utils/main.dart';
import 'package:workout_performance_tracker/widgets/exercice/add_exercise_popup.dart';
import 'package:workout_performance_tracker/widgets/exercice/delete_exercise_popup.dart';
import 'package:workout_performance_tracker/widgets/exercice/edit_exercise_popup.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  late TextEditingController _exerciseNameController;

  @override
  void initState() {
    super.initState();

    _exerciseNameController = TextEditingController();
  }

  @override
  void dispose() {
    _exerciseNameController.clear();
    _exerciseNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exerciseProvider).exercises;

    return SingleChildScrollView(
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: const Text('Exercises'),
              trailing: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => WillPopScope(
                      onWillPop: () {
                        _exerciseNameController.clear();
                        return Future.value(true);
                      },
                      child: const AddExercisePopup(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const Divider(),
            if (exercises.isEmpty)
              const ListTile(
                title: Text('No exercises yet'),
              ),
            for (final exercise in exercises)
              ListTile(
                title: Text(exercise.name!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              EditExercisePopup(exercise: exercise),
                        );
                      },
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              DeleteExercisePopup(exercise: exercise),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
