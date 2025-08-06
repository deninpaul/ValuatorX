import 'package:flutter/material.dart';
import 'package:valuatorx/pages/common/field/tag.dart';
import 'package:valuatorx/utils/common.dart';

class SummaryTile extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final Widget? subtitleInfo;
  final String info;
  final String tag;
  final bool showDivider;
  final Function onTapAction;
  final Widget? additionalInfo;
  final List<Widget>? actions;
  const SummaryTile({
    super.key,
    this.showDivider = true,
    required this.onTapAction,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.info,
    required this.tag,
    this.additionalInfo,
    this.subtitleInfo,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final subtitleInfoKey = GlobalKey();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTapAction(id),
        borderRadius: BorderRadius.circular(24),
        splashColor: colorScheme.surfaceContainer,
        highlightColor: colorScheme.surfaceContainer,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: isMobile(context) ? 21 : 24),
          child: Row(
            spacing: 18,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge!.copyWith(color: colorScheme.onSurface, overflow: TextOverflow.visible),
                      maxLines: isMobile(context) ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final subtitleInfoBox = subtitleInfoKey.currentContext?.findRenderObject() as RenderBox?;
                        final subtitleInfoWidth = subtitleInfoBox?.size.width ?? 0;
                        final maxTextWidth = constraints.maxWidth - (subtitleInfo != null ? (subtitleInfoWidth + 56) : 0);
                        return Row(
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: maxTextWidth),
                              child: Text(
                                subtitle,
                                style: textTheme.bodyMedium!.copyWith(color: theme.hintColor),
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                maxLines: 1,
                              ),
                            ),
                            if (subtitleInfo != null) ...[
                              SizedBox(width: 7),
                              Container(height: 2.5, width: 2.5, decoration: BoxDecoration(shape: BoxShape.circle, color: theme.hintColor)),
                              SizedBox(width: 7),
                              KeyedSubtree(key: subtitleInfoKey, child: subtitleInfo!),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (tag.isNotEmpty && info.isNotEmpty)
                Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(spacing: 4, children: [additionalInfo ?? SizedBox.shrink(), Tag(text: tag)]),
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Text(info, style: textTheme.bodyMedium!.copyWith(color: theme.hintColor)),
                    ),
                  ],
                ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}
