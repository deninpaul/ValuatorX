import 'package:flutter/material.dart';

class ClusterIcon extends StatelessWidget {
  const ClusterIcon({super.key, required this.text});

  final int text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surfaceContainer,
        border: Border.all(
          width: 8,
          strokeAlign: BorderSide.strokeAlignOutside,
          color: colorScheme.primary.withAlpha(64),
        ),
      ),
      alignment: Alignment.center,
      child: Text(text.toString(), style: TextStyle(color: colorScheme.onSurfaceVariant)),
    );
  }
}
