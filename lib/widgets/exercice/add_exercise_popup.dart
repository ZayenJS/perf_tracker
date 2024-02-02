import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/google.dart';
import 'package:workout_performance_tracker/models/model.dart';
import 'package:workout_performance_tracker/providers/exercise.dart';
import 'package:workout_performance_tracker/providers/settings.dart';
import 'package:workout_performance_tracker/utils/main.dart';

class AddExercisePopup extends ConsumerStatefulWidget {
  const AddExercisePopup({super.key});

  @override
  ConsumerState<AddExercisePopup> createState() => _AddExercisePopupState();
}

class _AddExercisePopupState extends ConsumerState<AddExercisePopup> {
  final TextEditingController _exerciseNameController =
      TextEditingController(text: '');

  @override
  void dispose() {
    _exerciseNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.white,
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
              final scaffoldMessenger = ScaffoldMessenger.of(context);
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

            final isBackupEnabled = ref.read(settingsProvider).autoBackup;

            if (!isBackupEnabled) return;

            Google.driveBackupPerformances();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
