import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:workout_performance_tracker/class/app_file_system.dart';
import 'package:workout_performance_tracker/class/google.dart';
import 'package:workout_performance_tracker/models/performance.dart';
import 'package:workout_performance_tracker/providers/exercise.dart';
import 'package:workout_performance_tracker/providers/home.dart';
import 'package:workout_performance_tracker/providers/settings.dart';
import 'package:workout_performance_tracker/providers/user.dart';
import 'package:workout_performance_tracker/utils/main.dart';
import 'package:workout_performance_tracker/widgets/app_popup_menu_button.dart';
import 'package:workout_performance_tracker/widgets/file_name_dialog.dart';

class HeaderPopupMenu extends ConsumerWidget {
  const HeaderPopupMenu({super.key});

  void importFile(
    WidgetRef ref,
    ScaffoldMessengerState scaffoldMessenger,
    ThemeData theme,
  ) async {
    final file = await AppFileSystem.pickCSVFileToImport();
    printDebug(file, before: "=");
    if (file == null) {
      return;
    }

    final homeNotifier = ref.read(homeProvider.notifier);

    try {
      homeNotifier.setImporting(true);

      // wait at least 500ms to show the loading backdrop
      await Future.delayed(const Duration(milliseconds: 500));

      await AppFileSystem.import(file, scaffoldMessenger, theme);
      ref.read(exerciseProvider.notifier).load();
    } catch (e) {
      showSnackBar(
        scaffoldMessenger,
        theme,
        "Something went wrong while importing the file",
        isError: true,
      );
    } finally {
      homeNotifier.setImporting(false);
    }
  }

  void exportFile(
    BuildContext context,
    WidgetRef ref,
    ScaffoldMessengerState scaffoldMessenger,
    ThemeData theme,
  ) async {
    final homeNotifier = ref.read(homeProvider.notifier);

    try {
      final fileName = await showDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          return FileNameDialog(
            initial:
                "workout_performance_tracker_export_${DateTime.now().millisecondsSinceEpoch}",
          );
        },
      );

      if (fileName == null) {
        return;
      }

      final selectedDirectory = await AppFileSystem.pickDirectory();

      if (selectedDirectory == null) {
        return;
      }

      homeNotifier.setImporting(true);
      // wait at least 500ms to show the loading backdrop
      await Future.delayed(const Duration(milliseconds: 500));

      final data = await AppPerformance.formatForCsv();

      await AppFileSystem.export(
        scaffoldMessenger,
        theme,
        fileName: fileName,
        selectedDirectory: selectedDirectory,
        data: data,
      );

      final isBackupEnabled = ref.read(settingsProvider).autoBackup;

      if (!isBackupEnabled) {
        return;
      }

      Google.driveBackup(data);
    } catch (e) {
      showSnackBar(
        scaffoldMessenger,
        theme,
        "Something went wrong while exporting the file",
        isError: true,
      );
    } finally {
      homeNotifier.setImporting(false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    return AppPopupMenuButton(
      onSelected: null,
      iconData: Icons.settings,
      children: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: "import",
          onTap: () => importFile(ref, scaffoldMessenger, theme),
          child: const ListTile(
            leading: Icon(Icons.download_rounded),
            title: Text("Import"),
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: "export",
          onTap: () => exportFile(context, ref, scaffoldMessenger, theme),
          child: const ListTile(
            leading: Icon(Icons.upload_rounded),
            title: Text("Export"),
          ),
        ),
      ],
    );
  }
}
