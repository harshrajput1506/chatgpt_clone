import 'package:flutter/material.dart';

class OptionsMenu extends StatelessWidget {
  final Widget child;
  final List<Widget> menuItems;
  final MenuController menuController;
  final Offset? alignmentOffset;
  const OptionsMenu({
    super.key,
    required this.child,
    this.menuItems = const [],
    required this.menuController,
    this.alignmentOffset,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: menuItems,
      controller: menuController,
      alignmentOffset: alignmentOffset,
      consumeOutsideTap: true,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainer,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: child,
    );
  }
}
