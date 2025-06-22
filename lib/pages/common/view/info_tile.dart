import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final bool iconOnly;
  final IconData? icon;

  const InfoTile({super.key, this.title = "", this.value = "", this.icon, this.iconOnly = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final valueFormated = value.trim().isEmpty ? "-" : value;

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(28)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: !iconOnly ? colorScheme.primaryContainer : Colors.transparent),
              padding: !iconOnly ? EdgeInsets.all(8) : EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              child: Icon(icon, color: colorScheme.primary),
            ),
          if (!iconOnly)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Text(
                      valueFormated,
                      style: textTheme.titleLarge!.copyWith(color: colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(title, style: textTheme.bodyLarge!.copyWith(color: theme.hintColor), overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
