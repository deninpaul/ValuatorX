import 'package:flutter/material.dart';

class ViewTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Function onPressed;
  final int tabIndex;

  const ViewTile({super.key, required this.title, required this.value, this.icon, this.tabIndex = 0, this.onPressed = _defaultOnPressed});

  static void _defaultOnPressed() {}

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final labelColor = colorScheme.onSurface.withAlpha(160);
    final valueFormated = value.trim().isEmpty ? "-" : value;

    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => onPressed(fieldName: title, fieldTab: tabIndex),
        splashColor: colorScheme.surfaceContainerHigh,
        highlightColor: colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 24, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon != null ? Padding(padding: const EdgeInsets.only(top: 16, right: 24), child: Icon(icon)) : SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    Text(title, style: textTheme.bodyMedium!.copyWith(color: labelColor)),
                    SelectableText(valueFormated, style: textTheme.bodyLarge),
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
