import 'package:flutter/material.dart';

class LinkTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData? icon;
  final VoidCallback onPressed;
  final double width;

  const LinkTile({super.key, required this.title, this.subTitle = "", this.icon, required this.onPressed, this.width = 80});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      spacing: 15,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null)
          Material(
            borderRadius: BorderRadius.circular(26),
            color: colorScheme.primaryContainer,
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: onPressed,
              child: Padding(padding: const EdgeInsets.all(14), child: Icon(icon, color: colorScheme.primary, size: 21)),
            ),
          ),
        GestureDetector(
          onTap: onPressed,
          child: Text(title, style: textTheme.bodyMedium, overflow: TextOverflow.ellipsis, maxLines: 2, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
