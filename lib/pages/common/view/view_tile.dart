import 'package:flutter/material.dart';

class ViewTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Function({String fieldName, int fieldTab})? onPressed;
  final int tabIndex;

  const ViewTile({super.key, required this.title, required this.value, this.icon, this.tabIndex = 0, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final valueFormated = value.trim().isEmpty ? "-" : value;

    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => onPressed != null ? onPressed!(fieldName: title, fieldTab: tabIndex) : () {},
        splashColor: colorScheme.surfaceContainerHigh,
        highlightColor: colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 18, 24, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon != null ? Padding(padding: const EdgeInsets.only(top: 14, right: 24), child: Icon(icon)) : SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 7,
                  children: [
                    Text(title, style: textTheme.bodySmall!.copyWith(color: theme.hintColor)),
                    SelectableText(valueFormated, style: textTheme.bodyLarge!.copyWith(height: 1.55)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
