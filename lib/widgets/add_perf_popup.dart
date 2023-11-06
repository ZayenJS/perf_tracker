import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:perf_tracker/models/model.dart';
import 'package:perf_tracker/providers/exercise.dart';
import 'package:perf_tracker/providers/performance.dart';
import 'package:perf_tracker/utils/main.dart';
import 'package:searchfield/searchfield.dart';

class AddPerfPopup extends ConsumerStatefulWidget {
  const AddPerfPopup({Key? key}) : super(key: key);

  @override
  ConsumerState<AddPerfPopup> createState() => _AddPerfPopupState();
}

class _AddPerfPopupState extends ConsumerState<AddPerfPopup> {
  final now = DateTime.now();
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = now;
  }

  @override
  Widget build(BuildContext context) {
    final List<Exercise> exercises = ref.watch(exerciseProvider).exercises;
    final performanceNotifier = ref.read(performanceProvider.notifier);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    return AlertDialog(
      surfaceTintColor: Colors.white,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SearchField<Exercise>(
                  controller: _exerciseNameController,
                  searchInputDecoration: const InputDecoration(
                    label: Text("Exercise"),
                  ),
                  onSuggestionTap: (val) {
                    printDebug(val.item, before: ".");
                  },
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
                  onChanged: (value) {
                    performanceNotifier.changeReps(int.tryParse(value));
                  },
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
                  onChanged: (value) =>
                      performanceNotifier.changeWeight(double.tryParse(value)),
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.date_range_rounded),
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                      initialDate: _selectedDate,
                      firstDate: DateTime(now.year - 10),
                      lastDate: now,
                    );

                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  title: Text(DateFormat("dd/MM/yyyy").format(_selectedDate)),
                ),
              ],
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(surfaceTintColor: Colors.white),
          onPressed: () async {
            setState(() {
              performanceNotifier.reset();
              _selectedDate = now;
            });
          },
          child: const Text("Reset"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () async {
            try {
              performanceNotifier
                  .changeExerciseName(_exerciseNameController.text);
              performanceNotifier
                  .changeReps(int.tryParse(_repsController.text));
              performanceNotifier
                  .changeSets(int.tryParse(_setsController.text));
              performanceNotifier
                  .changeWeight(double.tryParse(_weightController.text));
              performanceNotifier.changeDate(_selectedDate);

              await performanceNotifier.addPerf();
              navigator.pop();
              ref.read(exerciseProvider.notifier).load();
            } catch (e) {
              if (e is String) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      e,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
