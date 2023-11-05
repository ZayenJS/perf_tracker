import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:perf_tracker/class/page_transition.dart';
import 'package:perf_tracker/models/model.dart';
import 'package:perf_tracker/providers/exercise.dart';
import 'package:perf_tracker/utils/main.dart';
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
  final TextEditingController _weightController = TextEditingController();

  String? _result = null;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final List<Exercise> exercises = ref.watch(exerciseProvider).exercises;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perf Tracker"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: const [],
      ),
      body: SingleChildScrollView(
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
          TextField(
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
          TextField(
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
          TextField(
            controller: _weightController,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: const InputDecoration(
              label: Text("Weight"),
            ),
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });

              final exercise = await Exercise()
                  .select()
                  .where(
                    'name = ?',
                    parameterValue: _exerciseNameController.text,
                  )
                  .toSingle();

              if (exercise == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Nothing found for this exercise"),
                  ),
                );

                setState(() {
                  _isLoading = false;
                  _result = null;
                });
                return;
              }

              final performance = await Performance()
                  .select()
                  .where(
                    "exercise_id = ?",
                    parameterValue: exercise.id,
                  )
                  .and
                  .where(
                    "reps = ?",
                    parameterValue: _repsController.text,
                  )
                  .and
                  .where(
                    "sets = ?",
                    parameterValue: _setsController.text,
                  )
                  .and
                  .where(
                    "weight = ?",
                    parameterValue: _weightController.text,
                  )
                  .toSingle();

              if (performance == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Nothing found for this exercise"),
                  ),
                );

                setState(() {
                  _isLoading = false;
                  _result = null;
                });
                return;
              }

              setState(() {
                _isLoading = false;
                _result =
                    "Last time done: ${DateFormat('dd/MM/yyyy').format(performance.created_at!)}";
              });
            },
            child: const Text("Search"),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          if (_result != null) Text(_result.toString())
        ],
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
