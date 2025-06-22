import 'package:flutter/material.dart';
import 'package:valuatorx/utils/common.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const ActionButton({super.key, required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final texTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      width: isMobile(context) ? 100 : 108,
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            style: IconButton.styleFrom(backgroundColor: colorScheme.secondaryContainer, padding: EdgeInsets.all(12)),
            onPressed: onPressed,
            icon: Icon(icon),
          ),
          Text(label, style: texTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
