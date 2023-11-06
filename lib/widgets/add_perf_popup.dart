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
    final exerciseNotifier = ref.read(exerciseProvider.notifier);
    final performanceNotifier = ref.read(performanceProvider.notifier);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);

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
              _exerciseNameController.clear();
              _setsController.clear();
              _repsController.clear();
              _weightController.clear();
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
              if (_exerciseNameController.text.isEmpty) {
                throw "Exercise name is required";
              }

              final exerciceId = await exerciseNotifier
                  .getExerciceId(_exerciseNameController.text);

              final performance = Performance(
                exercise_id: exerciceId,
                reps: int.tryParse(_repsController.text),
                sets: int.tryParse(_setsController.text),
                weight: double.tryParse(_weightController.text),
                created_at: _selectedDate,
              );

              await performanceNotifier.addPerf(performance);
              ref.read(exerciseProvider.notifier).load();

              navigator.pop();

              showSnackBar(
                scaffoldMessenger,
                theme,
                "Performance added",
              );
            } catch (e) {
              if (e is String) {
                showSnackBar(
                  scaffoldMessenger,
                  theme,
                  e,
                  isError: true,
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
