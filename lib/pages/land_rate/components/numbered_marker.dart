import 'package:flutter/material.dart';

class NumberedMarker extends StatelessWidget {
  final String text;
  const NumberedMarker({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(right: 0, child: Icon(Icons.location_on, color: colorScheme.primary, size: 48)),
        Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: colorScheme.primary, // Customize the color
              shape: BoxShape.circle,
            ),
          ),
        
        Positioned(
          top: 12,
          child: SizedBox(
              width: 18,
              height: 18,
              child: FittedBox(fit: BoxFit.scaleDown, child: Text(text,textAlign: TextAlign.center, style: TextStyle(backgroundColor: colorScheme.primary, color: colorScheme.onSecondary))),
            ),
        ),
        
      ],
    );
  }
}
