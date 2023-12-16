import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/perf_popup_return.dart';
import 'package:workout_performance_tracker/class/performance_detail.dart';
import 'package:workout_performance_tracker/class/performance_source.dart';
import 'package:workout_performance_tracker/models/model.dart';
import 'package:workout_performance_tracker/providers/exercise.dart';
import 'package:workout_performance_tracker/providers/home.dart';
import 'package:workout_performance_tracker/providers/performance.dart';
import 'package:workout_performance_tracker/providers/result_table.dart';
import 'package:workout_performance_tracker/providers/search.dart';
import 'package:workout_performance_tracker/utils/main.dart';
import 'package:workout_performance_tracker/widgets/home/search_form/exercise_search_field.dart';
import 'package:workout_performance_tracker/widgets/home/search_form/numeric_field.dart';
import 'package:workout_performance_tracker/widgets/home/search_results.dart';
import 'package:workout_performance_tracker/widgets/perf_popup.dart';
import 'package:workout_performance_tracker/widgets/loading_backdrop.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<PerformanceDetail> _results = [];

  late PerformanceSource _data;
  int _sortColumnIndex = 3;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _updateTableData();
  }

  void _onRowTap(PerformanceDetail data) async {
    final result = await showDialog<PerfPopupReturn>(
      context: context,
      builder: (BuildContext context) {
        return PerfPopup(data: data);
      },
    );

    if (result == null) {
      return;
    }

    final perf = result.data;

    if (perf == null) {
      return;
    }

    final resultTableNotifier = ref.read(resultTableProvider.notifier);

    resultTableNotifier.updateResults(perf, result.deleted);
    resultTableNotifier.onTableSort();
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

  @override
  Widget build(BuildContext context) {
    final homeNotifier = ref.watch(homeProvider.notifier);
    final resultTableState = ref.watch(resultTableProvider);

    final searchState = ref.watch(searchProvider);
    final exerciseNameController = searchState.exerciseNameController;
    final setsController = searchState.setsController;
    final repsController = searchState.repsController;
    final weightController = searchState.weightController;

    final homeState = ref.watch(homeProvider);

    final List<Exercise> exercises = ref.watch(exerciseProvider).exercises;
    final exerciseNotifier = ref.read(exerciseProvider.notifier);
    final performanceNotifier = ref.read(performanceProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    return SizedBox(
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
                    controller: exerciseNameController,
                    data: exercises,
                  ),
                  Row(
                    children: [
                      NumericField(
                        controller: setsController,
                        label: "Sets",
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: false,
                        ),
                      ),
                      const SizedBox(width: 32.0),
                      NumericField(
                        controller: repsController,
                        label: "Reps",
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: false,
                        ),
                      ),
                      const SizedBox(width: 32.0),
                      NumericField(
                        controller: weightController,
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
                      _results.clear();

                      homeNotifier.setLoading(true);
                      resultTableState.results.clear();

                      scaffoldMessenger.hideCurrentSnackBar();
                      final exerciseName = exerciseNameController.text.trim();

                      if (exerciseName.isEmpty) {
                        showSnackBar(
                          scaffoldMessenger,
                          theme,
                          "Please enter an exercise name",
                          isError: true,
                        );

                        homeNotifier.setLoading(false);
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

                        homeNotifier.setLoading(false);
                        return;
                      }

                      final performances = await performanceNotifier.search(
                        exerciseId: exercise.id,
                        reps: repsController.text.trim(),
                        sets: setsController.text.trim(),
                        weight: weightController.text.trim(),
                        orderBy: "created_at:DESC",
                      );

                      if (performances.isEmpty) {
                        showSnackBar(
                          scaffoldMessenger,
                          theme,
                          "Nothing found with these filters",
                          isError: true,
                        );

                        homeNotifier.setLoading(false);
                        return;
                      }

                      setState(() {
                        homeNotifier.setLoading(false);
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
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text("Search"),
                  ),
                  const SizedBox(height: 16.0),
                  if (homeState.isLoading) const CircularProgressIndicator(),
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
          if (homeState.isImporting) const LoadingBackdrop(),
        ],
      ),
    );
  }
}
