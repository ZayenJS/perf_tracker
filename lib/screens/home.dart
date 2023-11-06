import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:perf_tracker/class/performance_detail.dart';
import 'package:perf_tracker/models/model.dart';
import 'package:perf_tracker/providers/exercise.dart';
import 'package:perf_tracker/widgets/add_perf_popup.dart';
import 'package:searchfield/searchfield.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  final List<PerformanceDetail> _results = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final List<Exercise> exercises = ref.watch(exerciseProvider).exercises;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perf Tracker"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: const [],
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SearchField<Exercise>(
              controller: _exerciseNameController,
              searchInputDecoration: const InputDecoration(
                label: Text("Exercise"),
              ),
              suggestions: exercises
                  .map(
                    (e) => SearchFieldListItem<Exercise>(
                      e.name!,
                      item: e,
                      // Use child to show Custom Widgets in the suggestions
                      // defaults to Text widget
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(e.name!),
                      ),
                    ),
                  )
                  .toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _setsController,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    decoration: const InputDecoration(
                      label: Text("Sets"),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: false,
                    ),
                  ),
                ),
                const SizedBox(width: 32.0),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    decoration: const InputDecoration(
                      label: Text("Reps"),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: false,
                    ),
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

                await Future.delayed(const Duration(seconds: 1));

                final exercise = await Exercise()
                    .select()
                    .where(
                      'name = ?',
                      parameterValue: _exerciseNameController.text,
                    )
                    .toSingle();

                if (exercise == null) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text("Nothing found for this exercise"),
                    ),
                  );

                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }

                PerformanceFilterBuilder queryBuilder =
                    Performance().select().where(
                          "exercise_id = ?",
                          parameterValue: exercise.id,
                        );

                if (_repsController.text != "") {
                  queryBuilder = queryBuilder.and.where(
                    "reps = ?",
                    parameterValue: _repsController.text,
                  );
                }

                if (_setsController.text != "") {
                  queryBuilder = queryBuilder.and.where(
                    "sets = ?",
                    parameterValue: _setsController.text,
                  );
                }

                final performances =
                    await queryBuilder.orderByDesc("created_at").toList();

                if (performances.isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text("Nothing found with these filters"),
                    ),
                  );

                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }

                setState(() {
                  _isLoading = false;
                  _results.addAll(
                    performances
                        .map(
                          (e) => PerformanceDetail(
                            exerciseName: exercise.name!,
                            sets: e.sets!,
                            reps: e.reps!,
                            weight: e.weight!,
                            date: e.created_at!,
                          ),
                        )
                        .toList(),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text("Search"),
            ),
            const SizedBox(height: 16.0),
            if (_isLoading) const CircularProgressIndicator(),
            if (_results.isNotEmpty)
              Table(
                border: TableBorder.all(),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(2),
                },
                children: [
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TableCell(
                          child: Text(
                            "Sets",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Text(
                          "Reps",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TableCell(
                        child: Text(
                          "Weight",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TableCell(
                        child: Text(
                          "Date",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  ..._results.map(
                    (e) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TableCell(
                            child: Text(
                              e.sets.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        TableCell(
                          child: Text(
                            e.reps.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        TableCell(
                          child: Text(
                            e.weight.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        TableCell(
                          child: Text(
                            DateFormat('dd MMM yyyy').format(e.date),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      )),
      floatingActionButton: IconButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        icon: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddPerfPopup();
            },
          );
        },
      ),
    );
  }
}
