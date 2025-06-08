import 'package:flutter/material.dart';

class DraftDialog extends StatelessWidget {
  final EdgeInsets padding;
  final VoidCallback onLoad;
  final VoidCallback onCancel;
  const DraftDialog({super.key, this.padding = const EdgeInsets.all(0), required this.onLoad, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: padding,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        decoration: BoxDecoration(color: colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(40)),
        child: Row(
          children: [
            Expanded(child: Text("You have unsaved changes", style: textTheme.bodyMedium)),
            TextButton(onPressed: onLoad, child: Text("Load changes")),
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
              child: Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}
