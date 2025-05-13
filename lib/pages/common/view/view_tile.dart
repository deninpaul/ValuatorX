import 'package:flutter/material.dart';

class ViewTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;

  const ViewTile({super.key, required this.title, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final labelColor = colorScheme.onSurface.withAlpha(160);
    final valueFormated = value.trim().isEmpty ? "-" : value;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon != null
              ? Padding(padding: const EdgeInsets.only(top: 16, right: 24), child: Icon(icon))
              : SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(valueFormated, style: textTheme.bodyLarge),
              Text(title, style: textTheme.bodyMedium!.copyWith(color: labelColor)),
            ],
          ),
        ],
      ),
    );
  }
}
