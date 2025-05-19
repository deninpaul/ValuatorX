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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTapAction(id),
        borderRadius: BorderRadius.circular(24),
        splashColor: colorScheme.surfaceContainer,
        highlightColor: colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: Row(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.bodyLarge),
                      Text(subtitle, style: textTheme.bodyLarge!.copyWith(color: labelColor)),
                    ],
                  ),
                ),
                Column(
                  spacing: 6,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(info, style: textTheme.bodyMedium!.copyWith(color: labelColor)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: colorScheme.surfaceContainerHigh,
                      ),
                      child: Text(tag, style: textTheme.bodyMedium),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
