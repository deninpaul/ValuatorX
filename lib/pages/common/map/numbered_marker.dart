import 'package:flutter/material.dart';

class NumberedMarker extends StatelessWidget {
  final String text;

  const NumberedMarker({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      child: CustomPaint(
        painter: _PinPainter(
          text: text,
          color: colorScheme.secondaryFixedDim,
          textColor: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  final String text;
  final Color color;
  final Color textColor;

  _PinPainter({
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2.4);
    final radius = size.width * 0.25;

    // Draw the circle (head of the pin)
    canvas.drawCircle(center, radius, paint);

    // Draw the tail
    final tailPath = Path();
    tailPath.moveTo(center.dx - radius *1.8 / 2, center.dy + radius / 2);
    tailPath.lineTo(center.dx + radius * 1.8/ 2, center.dy + radius / 2);
    tailPath.lineTo(center.dx, size.height);
    tailPath.close();
    canvas.drawPath(tailPath, paint);

    // Draw the number
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: radius * 0.8,
          color: textColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2 + 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _PinPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.color != color || oldDelegate.textColor != textColor;
  }
}
