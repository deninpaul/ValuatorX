import 'package:flutter/material.dart';
import 'package:valuatorx/utils/common.dart';

class DraftDialog extends StatelessWidget {
  final VoidCallback onLoad;
  final VoidCallback onCancel;
  const DraftDialog({super.key, required this.onLoad, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final padding = isMobile(context) ?  EdgeInsets.fromLTRB(16, 20, 16, 4) : isDesktop(context) ? EdgeInsets.fromLTRB(240, 20, 240, 4) : EdgeInsets.fromLTRB(48, 20, 48, 4);

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
