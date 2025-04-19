import 'package:flutter/material.dart';

class NumberedMarker extends StatelessWidget {
  final String text;
  final double size;
  const NumberedMarker({super.key, required this.text, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: 0,
          child: Icon(Icons.location_on, color: colorScheme.secondaryFixedDim, size: size, shadows: [BoxShadow(color: colorScheme.secondary, blurRadius: 1)]),
        ),

        Container(
          width: size / 2,
          height: size / 2,
          decoration: BoxDecoration(
            color: colorScheme.secondaryFixedDim, // Customize the color
            shape: BoxShape.circle,
          ),
        ),

        Positioned(
          top: 10,
          child: SizedBox(
            width: size * 0.36,
            height: size * 0.36,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurface)),
            ),
          ),
        ),
      ],
    );
  }
}
