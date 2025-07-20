import 'package:flutter/material.dart';
import 'package:valuatorx/pages/common/field/tag.dart';
import 'package:valuatorx/utils/common.dart';

class SummaryTile extends StatelessWidget {
  final String id;
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
                      Text(
                        title,
                        style: textTheme.bodyLarge!.copyWith(color: colorScheme.onSurface, overflow: TextOverflow.visible),
                        maxLines: isMobile(context) ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                      Text(subtitle, style: textTheme.bodyMedium!.copyWith(color: theme.hintColor)),
                    ],
                  ),
                ),
                Column(
                  spacing: 7,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Tag(text: tag),
                    Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Text(info, style: textTheme.bodyMedium!.copyWith(color: theme.hintColor)),
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
