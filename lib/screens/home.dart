import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workout_performance_tracker/class/app_file_system.dart';
import 'package:workout_performance_tracker/class/performance_detail.dart';
import 'package:workout_performance_tracker/class/performance_source.dart';
import 'package:workout_performance_tracker/models/model.dart';
import 'package:workout_performance_tracker/providers/exercise.dart';
import 'package:workout_performance_tracker/providers/performance.dart';
import 'package:workout_performance_tracker/utils/main.dart';
import 'package:workout_performance_tracker/widgets/home/header_popup_menu.dart';
import 'package:workout_performance_tracker/widgets/home/search_form/exercise_search_field.dart';
import 'package:workout_performance_tracker/widgets/home/search_form/numeric_field.dart';
import 'package:workout_performance_tracker/widgets/home/search_results.dart';
import 'package:workout_performance_tracker/widgets/perf_popup.dart';
import 'package:workout_performance_tracker/widgets/file_name_dialog.dart';
import 'package:workout_performance_tracker/widgets/loading_backdrop.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final List<PerformanceDetail> _results = [];
  bool _isLoading = false;
  bool _isImporting = false;

  late PerformanceSource _data;
  int _sortColumnIndex = 3;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _updateTableData();
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onRowTap(PerformanceDetail data) async {
    final updatedPerf = await showDialog<PerformanceDetail>(
      context: context,
      builder: (BuildContext context) {
        return PerfPopup(data: data);
      },
    );

    if (updatedPerf == null) {
      return;
    }

    setState(() {
      // replace the old performance with the updated one
      final oldPerfIndex = _results.indexWhere((p) => p.id == updatedPerf.id);
      _results[oldPerfIndex] = updatedPerf;

      _updateTableData();
      _onSort(_sortColumnIndex, _sortAscending);
    });
  }

  void _updateTableData() {
    _data = PerformanceSource(data: _results, onTap: _onRowTap);
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      if (columnIndex == 3) {
        _data.sortDate(
          (PerformanceDetail p) => p.date,
          ascending,
        );
      } else {
        _data.sortNumeric<num>(
          (PerformanceDetail p) {
            switch (columnIndex) {
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
          ascending,
        );
      }
    });
  }

  void importFile(
      ScaffoldMessengerState scaffoldMessenger, ThemeData theme) async {
    final file = await AppFileSystem.pickCSVFileToImport();

    if (file == null) {
      return;
    }

    try {
      setState(() {
        _isImporting = true;
      });

      // wait at least 500ms to show the loading backdrop
      await Future.delayed(const Duration(milliseconds: 500));

      await AppFileSystem.import(file, scaffoldMessenger, theme);
      ref.read(exerciseProvider.notifier).load();
    } catch (e) {
      showSnackBar(
        scaffoldMessenger,
        theme,
        "Something went wrong while importing the file",
        isError: true,
      );
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  void exportFile(
    ScaffoldMessengerState scaffoldMessenger,
    ThemeData theme,
  ) async {
    try {
      final fileName = await showDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          return FileNameDialog(
            initial:
                "workout_performance_tracker_export_${DateTime.now().millisecondsSinceEpoch}",
          );
        },
      );

      if (fileName == null) {
        return;
      }

      final selectedDirectory = await AppFileSystem.pickDirectory();

      if (selectedDirectory == null) {
        return;
      }

      setState(() {
        _isImporting = true;
      });
      // wait at least 500ms to show the loading backdrop
      await Future.delayed(const Duration(milliseconds: 500));
      await AppFileSystem.export(
        scaffoldMessenger,
        theme,
        fileName: fileName,
        selectedDirectory: selectedDirectory,
      );
    } catch (e) {
      showSnackBar(
        scaffoldMessenger,
        theme,
        "Something went wrong while exporting the file",
        isError: true,
      );
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Exercise> exercises = ref.watch(exerciseProvider).exercises;
    final exerciseNotifier = ref.read(exerciseProvider.notifier);
    final performanceNotifier = ref.read(performanceProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perf Tracker"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          HeaderPopupMenu(
            importFile: importFile,
            exportFile: exportFile,
          ),
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExerciseSearchField(
                      controller: _exerciseNameController,
                      data: exercises,
                    ),
                    Row(
                      children: [
                        NumericField(
                          controller: _setsController,
                          label: "Sets",
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: false,
                          ),
                        ),
                        const SizedBox(width: 32.0),
                        NumericField(
                          controller: _repsController,
                          label: "Reps",
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: false,
                          ),
                        ),
                        const SizedBox(width: 32.0),
                        NumericField(
                          controller: _weightController,
                          label: "Weight",
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                          _results.clear();
                        });

                        scaffoldMessenger.hideCurrentSnackBar();
                        final exerciseName =
                            _exerciseNameController.text.trim();

                        if (exerciseName.isEmpty) {
                          showSnackBar(
                            scaffoldMessenger,
                            theme,
                            "Please enter an exercise name",
                            isError: true,
                          );

                          setState(() {
                            _isLoading = false;
                          });
                          return;
                        }

                        await Future.delayed(const Duration(seconds: 1));

                        final exercise = await exerciseNotifier.getByName(
                          exerciseName,
                        );

                        if (exercise == null) {
                          showSnackBar(
                            scaffoldMessenger,
                            theme,
                            "Nothing found for this exercise",
                            isError: true,
                          );

                          setState(() {
                            _isLoading = false;
                          });
                          return;
                        }

                        final performances = await performanceNotifier.search(
                          exerciseId: exercise.id,
                          reps: _repsController.text.trim(),
                          sets: _setsController.text.trim(),
                          weight: _weightController.text.trim(),
                          orderBy: "created_at:DESC",
                        );

                        if (performances.isEmpty) {
                          showSnackBar(
                            scaffoldMessenger,
                            theme,
                            "Nothing found with these filters",
                            isError: true,
                          );

                          setState(() {
                            _isLoading = false;
                          });
                          return;
                        }

                        setState(() {
                          _isLoading = false;
                          _results.addAll(
                            PerformanceDetail.forExercise(
                              exercise.name!,
                              performances,
                            ),
                          );
                          _updateTableData();
                          _sortAscending = false;
                          _sortColumnIndex = 3;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text("Search"),
                    ),
                    const SizedBox(height: 16.0),
                    if (_isLoading) const CircularProgressIndicator(),
                    if (_results.isNotEmpty)
                      SearchResults(
                        results: _results,
                        sortAscending: _sortAscending,
                        sortColumnIndex: _sortColumnIndex,
                        onRowTap: _onRowTap,
                        onSort: _onSort,
                      ),
                  ],
                ),
              ),
            ),
            if (_isImporting) const LoadingBackdrop(),
          ],
        ),
      ),
      floatingActionButton: _isImporting
          ? null
          : IconButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              icon: const Icon(Icons.add),
              onPressed: () async {
                final newPerf = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const PerfPopup();
                  },
                );

                if (newPerf == null) {
                  return;
                }

                setState(() {
                  _results.add(newPerf);
                  _updateTableData();
                  _onSort(_sortColumnIndex, _sortAscending);
                });
              },
            ),
    );
  }
}
