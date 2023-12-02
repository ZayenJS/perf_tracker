import 'package:flutter/material.dart';
import 'package:workout_performance_tracker/widgets/home/header_popup_menu.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Perf Tracker"),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      actions: const [
        HeaderPopupMenu(),
      ],
    );
  }
}
