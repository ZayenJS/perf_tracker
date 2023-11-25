import 'package:flutter/material.dart';

class NumericField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final bool wrappWithExpanded;

  const NumericField({
    super.key,
    required this.controller,
    required this.label,
    required this.keyboardType,
    this.wrappWithExpanded = true,
  });

  Widget _buildTextField() {
    return TextField(
      controller: controller,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      decoration: InputDecoration(
        label: Text(label),
      ),
      keyboardType: keyboardType,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (wrappWithExpanded) {
      return Expanded(
        child: _buildTextField(),
      );
    } else {
      return _buildTextField();
    }
  }
}
