import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class SummaryTile extends StatelessWidget {
  final int id;
  final String title;
  final String subtitle;
  final String info;
  final String tag;
  final bool showDivider;
  final Function onTapAction;
  const SummaryTile({
    super.key,
    this.showDivider = true,
    required this.onTapAction,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.info,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final labelColor = colorScheme.onSurface.withAlpha(160);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: textTheme.bodyLarge),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: textTheme.bodyLarge!.copyWith(color: labelColor)),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(info, style: textTheme.bodyMedium!.copyWith(color: labelColor)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.surfaceContainerHigh,
                  ),
                  child: Center(child: Text(tag, style: textTheme.bodyMedium)),
                ),
              ],
            ),
          ],
        ),
        onTap: () => onTapAction(id),
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}
