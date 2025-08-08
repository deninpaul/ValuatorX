import 'package:flutter/material.dart';

class ClusterIcon extends StatelessWidget {
  final int text;
  final Color fill;
  final Color stroke;
  const ClusterIcon({super.key, required this.text, required this.fill, required this.stroke});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(width: 8, strokeAlign: BorderSide.strokeAlignOutside, color: stroke.withAlpha(64)),
      ),
      alignment: Alignment.center,
      child: Text(text.toString(), style: TextStyle(color: colorScheme.onSurfaceVariant)),
    );
  }
}
