import 'package:flutter/material.dart';

class FileNameDialog extends StatefulWidget {
  final String initial;

  const FileNameDialog({super.key, required this.initial});

  @override
  State<FileNameDialog> createState() => _FileNameDialogState();
}

class _FileNameDialogState extends State<FileNameDialog> {
  final TextEditingController _filenameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _filenameController.text = widget.initial;
  }

  @override
  void dispose() {
    _filenameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.white,
      title: const Text("Export to CSV"),
      content: TextField(
        controller: _filenameController,
        decoration: const InputDecoration(
          labelText: "File name",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_filenameController.text);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
