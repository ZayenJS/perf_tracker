import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/google.dart';
import 'package:workout_performance_tracker/models/model.dart';
import 'package:workout_performance_tracker/providers/exercise.dart';
import 'package:workout_performance_tracker/providers/settings.dart';

class DeleteExercisePopup extends ConsumerWidget {
  final Exercise exercise;

  const DeleteExercisePopup({super.key, required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
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

            final isBackupEnabled = ref.read(settingsProvider).autoBackup;

            if (!isBackupEnabled) return;

            Google.driveBackupPerformances();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
