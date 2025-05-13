import 'package:flutter/material.dart';

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
      padding: EdgeInsets.fromLTRB(16, 0, 24, 0),
      width: 110,
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
          Text(label, style: texTheme.bodyLarge, textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}
