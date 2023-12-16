import 'package:flutter/material.dart';

class AppPopupMenuButton extends StatelessWidget {
  final List<PopupMenuItem> children;
  final IconData? iconData;
  final void Function(dynamic)? onSelected;

  const AppPopupMenuButton({
    super.key,
    required this.children,
    this.iconData,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: const Offset(-20.0, 40.0),
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      itemBuilder: (context) => children,
      onSelected: onSelected,
      icon: Icon(iconData ?? Icons.more_vert_rounded),
    );
  }
}
