import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:perf_tracker/class/performance_detail.dart';

class PerformanceSource extends DataTableSource {
  final List<PerformanceDetail> data;
  final void Function(PerformanceDetail data) onTap;

  PerformanceSource({required this.data, required this.onTap});

  @override
  DataRow getRow(int index) {
    final result = data[index];

    return DataRow2.byIndex(
      onTap: () => onTap(result),
      index: index,
      cells: [
        DataCell(
          Text(result.sets.toString()),
        ),
        DataCell(
          Text(result.reps.toString()),
        ),
        DataCell(
          Text(result.weight.toString()),
        ),
        DataCell(
          Text(DateFormat('dd MMM yyyy').format(result.date)),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;

  void sortString<String>(
      Comparable<String> Function(PerformanceDetail d) getField,
      bool ascending) {
    data.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
  }

  void sortNumeric<num>(
      Comparable<num> Function(PerformanceDetail d) getField, bool ascending) {
    data.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
  }

  void sortDate(
    Comparable<DateTime> Function(PerformanceDetail d) getField,
    bool ascending,
  ) {
    data.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
  }
}
