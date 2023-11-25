import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:perf_tracker/class/performance_detail.dart';
import 'package:perf_tracker/models/model.dart';
import 'package:perf_tracker/providers/exercise.dart';
import 'package:perf_tracker/widgets/buttons/add_perf_button.dart';
import 'package:perf_tracker/widgets/buttons/delete_perf_button.dart';
import 'package:perf_tracker/widgets/buttons/reset_perf_button.dart';
import 'package:perf_tracker/widgets/buttons/update_perf_button.dart';
import 'package:perf_tracker/widgets/home/search_form/numeric_field.dart';
import 'package:searchfield/searchfield.dart';

class PerfPopup extends ConsumerStatefulWidget {
  final PerformanceDetail? data;

  const PerfPopup({Key? key, this.data}) : super(key: key);

  @override
  ConsumerState<PerfPopup> createState() => _PerfPopupState();
}

class _PerfPopupState extends ConsumerState<PerfPopup> {
  final now = DateTime.now();
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  late DateTime _selectedDate;
  late bool _isInUpdateMode;

  void _setInitialValues() {
    _exerciseNameController.text = widget.data?.name ?? "";
    _setsController.text = widget.data?.sets.toString() ?? "";
    _repsController.text = widget.data?.reps.toString() ?? "";
    _weightController.text = widget.data?.weight.toString() ?? "";
    _selectedDate = widget.data?.date ?? now;

    _isInUpdateMode = widget.data != null;
  }

  @override
  void initState() {
    super.initState();

    _setInitialValues();
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Exercise> exercises = ref.watch(exerciseProvider).exercises;

    return AlertDialog(
      title: Text("${(widget.data != null ? "Update" : "Add")} performance"),
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
                  enabled: _isInUpdateMode ? false : null,
                  suggestions: exercises
                      .map(
                        (e) => SearchFieldListItem<Exercise>(
                          e.name!.trim(),
                          item: e,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(e.name!.trim()),
                          ),
                        ),
                      )
                      .toList(),
                ),
                NumericField(
                  controller: _setsController,
                  label: "Sets",
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: false,
                  ),
                  wrappWithExpanded: false,
                ),
                NumericField(
                  controller: _repsController,
                  label: "Reps",
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: false,
                  ),
                  wrappWithExpanded: false,
                ),
                NumericField(
                  controller: _weightController,
                  label: "Weight",
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  wrappWithExpanded: false,
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
      actions: _buildActions(),
    );
  }

  List<Widget> _buildActions() {
    final actions = _isInUpdateMode
        ? [
            const DeletePerfButton(),
            UpdatePerfButton(
              latestData: () => PerformanceDetail(
                id: widget.data?.id,
                name: _exerciseNameController.text.trim(),
                sets: int.tryParse(_setsController.text.trim()) ?? 0,
                reps: int.tryParse(_repsController.text.trim()) ?? 0,
                weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
                date: _selectedDate,
              ),
            ),
          ]
        : [
            ResetPerfButton(onPressed: () {
              setState(() {
                _exerciseNameController.clear();
                _setsController.clear();
                _repsController.clear();
                _weightController.clear();
                _selectedDate = now;
              });
            }),
            AddPerfButton(
              latestData: () => PerformanceDetail(
                name: _exerciseNameController.text.trim(),
                sets: int.tryParse(_setsController.text.trim()) ?? 0,
                reps: int.tryParse(_repsController.text.trim()) ?? 0,
                weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
                date: _selectedDate,
              ),
            )
          ];

    return actions;
  }
}
