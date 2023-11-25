import 'package:flutter/material.dart';
import 'package:perf_tracker/utils/main.dart';

class DeletePerfButton extends StatelessWidget {
  const DeletePerfButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onError,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
      onPressed: () {
        showSnackBar(
          ScaffoldMessenger.of(context),
          Theme.of(context),
          "Delete button onPressed not implemented",
          isError: true,
        );

        throw UnimplementedError("Delete button onPressed not implemented");
      },
      child: const Text("Delete"),
    );
  }
}
