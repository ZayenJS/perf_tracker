import 'package:flutter/material.dart';

class ResetPerfButton extends StatelessWidget {
  final Function() onPressed;

  const ResetPerfButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(surfaceTintColor: Colors.white),
      onPressed: onPressed,
      child: const Text("Reset"),
    );
  }
}
