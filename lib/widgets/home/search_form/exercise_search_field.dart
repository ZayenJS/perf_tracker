import 'package:flutter/material.dart';
import 'package:perf_tracker/models/model.dart';
import 'package:searchfield/searchfield.dart';

class ExerciseSearchField extends StatelessWidget {
  final TextEditingController controller;
  final List<Exercise> data;

  const ExerciseSearchField({
    super.key,
    required this.controller,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SearchField<Exercise>(
      controller: controller,
      searchInputDecoration: const InputDecoration(
        label: Text("Exercise"),
      ),
      suggestions: data
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
    );
  }
}
