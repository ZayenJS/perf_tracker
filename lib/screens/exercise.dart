import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/google.dart';
import 'package:workout_performance_tracker/providers/exercise.dart';
import 'package:workout_performance_tracker/providers/settings.dart';
import 'package:workout_performance_tracker/utils/main.dart';

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
                      child: AlertDialog(
                        title: const Text('Add exercise'),
                        content: TextField(
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Exercise name',
                          ),
                          controller: _exerciseNameController,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              _exerciseNameController.clear();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (_exerciseNameController.text.isEmpty) {
                                final scaffoldMessenger =
                                    ScaffoldMessenger.of(context);
                                final theme = Theme.of(context);

                                showSnackBar(
                                  scaffoldMessenger,
                                  theme,
                                  "Exercise name can't be empty",
                                  isError: true,
                                );

                                return;
                              }

                              final navigator = Navigator.of(context);

                              await ref
                                  .read(exerciseProvider.notifier)
                                  .addExercise(_exerciseNameController.text);

                              _exerciseNameController.clear();
                              navigator.pop();

                              final isBackupEnabled =
                                  ref.read(settingsProvider).autoBackup;

                              if (!isBackupEnabled) return;

                              Google.driveBackupPerformances();
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
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
                trailing: IconButton(
                  icon: const Icon(Icons.delete,
                      color: Color.fromARGB(255, 202, 66, 56)),
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              surfaceTintColor: Colors.white,
                              title: const Text('Delete exercise'),
                              content: const Text(
                                'All performances related to this exercise will be deleted as well, are you sure?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final navigator = Navigator.of(context);

                                    await ref
                                        .read(exerciseProvider.notifier)
                                        .deleteExercise(exercise.id!);

                                    navigator.pop();

                                    final isBackupEnabled =
                                        ref.read(settingsProvider).autoBackup;

                                    if (!isBackupEnabled) return;

                                    Google.driveBackupPerformances();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
