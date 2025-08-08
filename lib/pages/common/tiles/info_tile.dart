import 'package:flutter/material.dart';
import 'package:valuatorx/utils/common.dart';

class InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;

  const InfoTile({super.key, this.title = "", this.value = "", this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final valueFormated = value.trim().isEmpty ? "-" : value;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile(context) ? 18 : 21, vertical: 18),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(26)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.primaryContainer),
              padding: EdgeInsets.all(8),
              child: Icon(icon, color: colorScheme.primary),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Text(valueFormated, style: textTheme.bodyLarge, overflow: TextOverflow.ellipsis, maxLines: 1),
                  Text(title, style: textTheme.bodyMedium!.copyWith(color: theme.hintColor), overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
