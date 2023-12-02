import 'package:flutter/material.dart';
import 'package:workout_performance_tracker/class/perf_popup_return.dart';
import 'package:workout_performance_tracker/widgets/perf_popup.dart';

class HomeFloatingActionButton extends StatelessWidget {
  const HomeFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
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

        // setState(() {
        //   _results.add(newPerf);
        //   _updateTableData();
        //   _onSort(_sortColumnIndex, _sortAscending);
        // });
      },
    );
  }
}
