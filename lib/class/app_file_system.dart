import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:perf_tracker/class/performance_detail.dart';
import 'package:perf_tracker/models/model.dart';
import 'package:perf_tracker/utils/main.dart';

class AppFileSystem {
  static Future<File?> pickCSVFileToImport() async {
    final filePath = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ['csv'],
      dialogTitle: "Select a CSV file",
      type: FileType.custom,
    );
    if (filePath == null) {
      return null;
    }

    return File(filePath.files.single.path!);
  }

  static Future<String?> pickDirectory() async {
    return FilePicker.platform.getDirectoryPath();
  }

  static Future import(
    File file,
    ScaffoldMessengerState scaffoldMessenger,
    ThemeData theme,
  ) async {
    const converter = CsvToListConverter();
    final csvData = await file.readAsString();
    final convertedData = converter.convert(csvData);

    final data = convertedData
        .sublist(1) // first row is header
        .map((e) => PerformanceDetail.fromList(e))
        .toList();

    for (final item in data) {
      Exercise? exercise =
          await Exercise().select().name.equals(item.name.trim()).toSingle();

      if (exercise == null) {
        exercise = Exercise();
        exercise.name = item.name.trim();
        exercise.created_at = DateTime.now();
        await exercise.save(ignoreBatch: false);
      }

      Performance? performance = await Performance()
          .select()
          .sets
          .equals(item.sets)
          .and
          .reps
          .equals(item.reps)
          .and
          .weight
          .equals(item.weight)
          .and
          .created_at
          .equals(item.date)
          .toSingle();

      if (performance != null) {
        performance.exercise_id = exercise.id;
        await performance.save(ignoreBatch: false);
        continue;
      }

      final newPerformance = Performance();
      newPerformance.sets = item.sets;
      newPerformance.reps = item.reps;
      newPerformance.weight = item.weight;
      newPerformance.exercise_id = exercise.id;
      newPerformance.created_at = item.date;
      await newPerformance.save(ignoreBatch: false);
    }

    showSnackBar(scaffoldMessenger, theme, "Data imported successfully!");
  }

  static Future export(
    ScaffoldMessengerState scaffoldMessenger,
    ThemeData theme, {
    String? fileName,
    required selectedDirectory,
  }) async {
    if (selectedDirectory == null) {
      // User canceled the picker
      return;
    }

    final finalFileName = fileName ??
        "perf_tracker_export_${DateTime.now().millisecondsSinceEpoch}";
    final file = File("$selectedDirectory/$finalFileName.csv");
    final performances = await Performance().select().toList(preload: true);
    final data = performances
        .map(
            (e) => [e.plExercise!.name, e.sets, e.reps, e.weight, e.created_at])
        .toList();

    ListToCsvConverter converter = const ListToCsvConverter();
    final csvData = converter.convert([
      ["name", "sets", "reps", "weight", "created_at"],
      ...data
    ]);

    await file.writeAsString(csvData);

    showSnackBar(
      scaffoldMessenger,
      theme,
      "Exported to $selectedDirectory/$finalFileName.csv",
    );
  }
}
