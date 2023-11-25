import 'package:flutter/material.dart';
import 'package:workout_performance_tracker/widgets/app_popup_menu_button.dart';

class HeaderPopupMenu extends StatelessWidget {
  final void Function(ScaffoldMessengerState, ThemeData) importFile;
  final void Function(ScaffoldMessengerState, ThemeData) exportFile;

  const HeaderPopupMenu({
    super.key,
    required this.importFile,
    required this.exportFile,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    return AppPopupMenuButton(
      onSelected: null,
      iconData: Icons.settings,
      children: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: "import",
          onTap: () => importFile(scaffoldMessenger, theme),
          child: const ListTile(
            leading: Icon(Icons.download_rounded),
            title: Text("Import"),
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: "export",
          onTap: () => exportFile(scaffoldMessenger, theme),
          child: const ListTile(
            leading: Icon(Icons.upload_rounded),
            title: Text("Export"),
          ),
        ),
      ],
    );
  }
}
