import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/google.dart';
import 'package:workout_performance_tracker/class/perf_popup_return.dart';
import 'package:workout_performance_tracker/class/performance_detail.dart';
import 'package:workout_performance_tracker/providers/performance.dart';
import 'package:workout_performance_tracker/providers/settings.dart';
import 'package:workout_performance_tracker/utils/main.dart';

class DeletePerfButton extends ConsumerWidget {
  final PerformanceDetail Function() latestData;

  const DeletePerfButton({super.key, required this.latestData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: theme.colorScheme.onError,
        backgroundColor: theme.colorScheme.error,
      ),
      onPressed: () async {
        final confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            surfaceTintColor: Colors.white,
            title: const Text('Delete performance'),
            content: const Text(
              'Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  navigator.pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  navigator.pop(true);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (!confirmDelete) return;

        final data = latestData();

        if (data.id == null) {
          showSnackBar(
            scaffoldMessenger,
            theme,
            "Error: No ID provided",
            isError: true,
          );

          throw Exception("No ID provided");
        }

        final isDeleted =
            await ref.read(performanceProvider.notifier).deletePerf(data.id!);

        if (isDeleted) {
          showSnackBar(
            scaffoldMessenger,
            theme,
            "Performance successfully deleted",
          );

          final isBackupEnabled = ref.read(settingsProvider).autoBackup;

          if (!isBackupEnabled) {
            return;
          }

          Google.driveBackupPerformances();
        } else {
          showSnackBar(
            scaffoldMessenger,
            theme,
            "An error occured while deleting performance",
            isError: true,
          );
        }

        navigator.pop(
          PerfPopupReturn(
            data: data,
            deleted: isDeleted,
          ),
        );
      },
      child: const Text("Delete"),
    );
  }
}
