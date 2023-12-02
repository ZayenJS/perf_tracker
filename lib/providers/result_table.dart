import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/performance_detail.dart';
import 'package:workout_performance_tracker/class/performance_source.dart';

class ResultTableState {
  final int sortColumnIndex;
  final bool sortAscending;
  final List<PerformanceDetail> results;
  final PerformanceSource data;

  ResultTableState({
    required this.results,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.data,
  });
}

class ResultTableNotifier extends StateNotifier<ResultTableState> {
  ResultTableNotifier()
      : super(
          ResultTableState(
            results: [],
            sortColumnIndex: 3,
            sortAscending: false,
            data: PerformanceSource(
              data: [],
              onTap: (PerformanceDetail data) {},
            ),
          ),
        );

  void updateTableData(void Function(PerformanceDetail data) onTap) {
    PerformanceSource(data: state.results, onTap: onTap);
  }

  void updateResults(PerformanceDetail perf, bool isDeleted) {
    if (state.results.isEmpty) {
      return;
    }

    final resultsCopy = [...state.results];

    if (isDeleted) {
      resultsCopy.removeWhere((p) => p.id == perf.id);
    } else {
      final index = resultsCopy.indexWhere((p) => p.id == perf.id);
      resultsCopy[index] = perf;
    }

    state = ResultTableState(
      data: state.data,
      results: resultsCopy,
      sortColumnIndex: state.sortColumnIndex,
      sortAscending: state.sortAscending,
    );

    updateTableData(state.data.onTap);
  }

  void onTableSort({int? columnIndex, bool? ascending}) {
    final sortColumnIndex = columnIndex ?? state.sortColumnIndex;
    final sortAscending = ascending ?? state.sortAscending;

    state = ResultTableState(
      data: state.data,
      results: state.results,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
    );

    if (sortColumnIndex == 3) {
      state.data.sortDate(
        (PerformanceDetail p) => p.date,
        sortAscending,
      );
    } else {
      state.data.sortNumeric<num>(
        (PerformanceDetail p) {
          switch (sortColumnIndex) {
            case 0:
              return p.sets;
            case 1:
              return p.reps;
            case 2:
              return p.weight;
            default:
              return p.sets;
          }
        },
        sortAscending,
      );
    }
  }
}

final resultTableProvider =
    StateNotifierProvider<ResultTableNotifier, ResultTableState>(
  (ref) => ResultTableNotifier(),
);
