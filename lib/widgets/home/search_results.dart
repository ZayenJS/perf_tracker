import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:workout_performance_tracker/class/performance_detail.dart';
import 'package:workout_performance_tracker/class/performance_source.dart';

class SearchResults extends StatelessWidget {
  final List<PerformanceDetail> results;
  final bool sortAscending;
  final int sortColumnIndex;
  final void Function(PerformanceDetail data) onRowTap;
  final void Function(int columnIndex, bool ascending) onSort;

  const SearchResults({
    super.key,
    required this.results,
    required this.sortAscending,
    required this.sortColumnIndex,
    required this.onRowTap,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.46),
      child: PaginatedDataTable2(
        sortAscending: sortAscending,
        sortColumnIndex: sortColumnIndex,
        columnSpacing: 0.0,
        source: PerformanceSource(
          data: results,
          onTap: onRowTap,
        ),
        autoRowsToHeight: true,
        renderEmptyRowsInTheEnd: false,
        rowsPerPage: 10,
        availableRowsPerPage: const [10, 20, 50],
        columns: [
          DataColumn2(
            fixedWidth: 55.0,
            onSort: onSort,
            label: const Text("Sets"),
          ),
          DataColumn2(
            fixedWidth: 65,
            onSort: onSort,
            label: const Text("Reps"),
          ),
          DataColumn2(
            fixedWidth: 75.0,
            onSort: onSort,
            label: const Text("Weight"),
          ),
          DataColumn2(
            size: ColumnSize.L,
            onSort: onSort,
            label: const Text("Date"),
          ),
        ],
      ),
    );
  }
}
