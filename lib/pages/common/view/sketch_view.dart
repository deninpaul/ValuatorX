import 'package:flutter/material.dart';
import 'package:valuatorx/pages/common/sketch/sketch_canvas.dart';

class SketchView extends StatelessWidget {
  final String title;
  final String value;
  final Function({String fieldName, int fieldTab})? onPressed;
  final int tabIndex;
  const SketchView({super.key, required this.title, required this.value, this.tabIndex = 0, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: Material(
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                SketchCanvas(value: value, readOnly: true),
                Positioned.fill(
                  child: InkWell(
                    onTap: () => onPressed?.call(fieldName: title, fieldTab: tabIndex),
                    splashColor: colorScheme.surfaceContainerHigh,
                    highlightColor: colorScheme.surfaceContainerHigh,
                    hoverColor: colorScheme.surfaceContainerLow,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
