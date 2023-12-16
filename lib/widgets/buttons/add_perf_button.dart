import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/google.dart';
import 'package:workout_performance_tracker/class/perf_popup_return.dart';
import 'package:workout_performance_tracker/class/performance_detail.dart';
import 'package:workout_performance_tracker/models/model.dart';
import 'package:workout_performance_tracker/models/performance.dart';
import 'package:workout_performance_tracker/providers/exercise.dart';
import 'package:workout_performance_tracker/providers/performance.dart';
import 'package:workout_performance_tracker/providers/settings.dart';
import 'package:workout_performance_tracker/utils/main.dart';

class AddPerfButton extends ConsumerWidget {
  final PerformanceDetail Function() latestData;
  final Function()? onPressed;

  const AddPerfButton({
    super.key,
    required this.latestData,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final exerciseNotifier = ref.read(exerciseProvider.notifier);
    final performanceNotifier = ref.read(performanceProvider.notifier);

    final settings = ref.read(settingsProvider);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      onPressed: onPressed ??
          () async {
            try {
              final data = latestData();

              if (data.name.isEmpty) {
                throw "Exercise name is required";
              }

              final exerciceId =
                  await exerciseNotifier.getExerciceId(data.name);

              final performance = Performance(
                exercise_id: exerciceId,
                reps: data.reps,
                sets: data.sets,
                weight: data.weight,
                created_at: data.date,
              );

              await performanceNotifier.addPerf(performance);
              ref.read(exerciseProvider.notifier).load();

              navigator.pop(
                PerfPopupReturn(
                  data: PerformanceDetail(
                    id: performance.id,
                    name: data.name,
                    reps: performance.reps!,
                    sets: performance.sets!,
                    weight: performance.weight!,
                    date: performance.created_at!,
                  ),
                  deleted: false,
                ),
              );

              showSnackBar(
                scaffoldMessenger,
                theme,
                "Performance added",
              );

              if (!settings.autoBackup) {
                return;
              }

              final csvData = await AppPerformance.formatForCsv();
              Google.driveBackup(csvData);
            } catch (e) {
              if (e is String) {
                showSnackBar(
                  scaffoldMessenger,
                  theme,
                  e,
                  isError: true,
                );
              }
            }
          },
      child: const Text("Add"),
    );
  }
}
