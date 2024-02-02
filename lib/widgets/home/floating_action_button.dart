import 'package:flutter/material.dart';
import 'package:workout_performance_tracker/class/perf_popup_return.dart';
import 'package:workout_performance_tracker/class/performance_detail.dart';
import 'package:workout_performance_tracker/utils/main.dart';
import 'package:workout_performance_tracker/widgets/perf_popup.dart';

class HomeFloatingActionButton extends StatelessWidget {
  final void Function(PerformanceDetail perf) updateSearchResults;

  const HomeFloatingActionButton({
    super.key,
    required this.updateSearchResults,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      icon: const Icon(Icons.add),
      onPressed: () async {
        final result = await showDialog<PerfPopupReturn>(
          context: context,
          builder: (BuildContext context) {
            return const PerfPopup();
          },
        );

        if (result == null) {
          return;
        }

        final newPerf = result.data;

        if (newPerf == null) {
          return;
        }

        updateSearchResults(newPerf);
      },
    );
  }
}
