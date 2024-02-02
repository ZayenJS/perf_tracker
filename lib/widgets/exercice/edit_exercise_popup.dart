import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/google.dart';
import 'package:workout_performance_tracker/models/model.dart';
import 'package:workout_performance_tracker/providers/exercise.dart';
import 'package:workout_performance_tracker/providers/settings.dart';
import 'package:workout_performance_tracker/utils/main.dart';

class EditExercisePopup extends ConsumerStatefulWidget {
  final Exercise exercise;

  const EditExercisePopup({super.key, required this.exercise});

  @override
  ConsumerState<EditExercisePopup> createState() => _EditExercisePopupState();
}

class _EditExercisePopupState extends ConsumerState<EditExercisePopup> {
  late TextEditingController _exerciseNameController;

  @override
  void initState() {
    super.initState();

    _exerciseNameController = TextEditingController(text: widget.exercise.name);
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return AlertDialog(
      surfaceTintColor: Colors.white,
      title: const Text('Edit exercise'),
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
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final newExerciseName = _exerciseNameController.text.isEmpty
                ? exercise.name
                : _exerciseNameController.text;

            if (newExerciseName == null || newExerciseName.isEmpty) {
              showSnackBar(
                ScaffoldMessenger.of(context),
                Theme.of(context),
                "Name can't be empty",
              );
              return;
            }

            await ref
                .read(exerciseProvider.notifier)
                .editExercise(exercise.id!, newExerciseName);

            navigator.pop();

            final isBackupEnabled = ref.read(settingsProvider).autoBackup;

            if (!isBackupEnabled) return;

            Google.driveBackupPerformances();
          },
          child: const Text('Edit'),
        ),
      ],
    );
  }
}
