import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:valuatorx/utils/common.dart';
import 'package:vector_math/vector_math.dart' as vector;


class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  double? _heading;

  @override
  void initState() {
    super.initState();
    // Listen to compass events
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      FlutterCompass.events?.listen((CompassEvent event) {
        setState(() {
          _heading = event.heading;
        });
      });
    }
  }

  // Helper function to convert heading in degrees to a cardinal direction string
  String _getDirection(double? heading) {
    if (heading == null) return '';
    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    return directions[((heading % 360) / 45).round()];
  }

  @override
  Widget build(BuildContext context) {
    final heading = _heading;
    final headingInDegrees = "${heading?.round() ?? "N/A"}";
    final direction = _getDirection(heading);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final  size = isMobile(context) ? 280.0 : 320.0;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: AppBar(toolbarHeight: 80, title: Text("Compass", style: headerTheme), backgroundColor: colorScheme.surfaceContainer),
      body: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(20,0,20,48),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(28)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                '$headingInDegrees°$direction',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: colorScheme.primary),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: colorScheme.primary, size: 48),
            SizedBox(height: 20),
            Transform.rotate(
              angle: (heading != null) ? vector.radians(-heading) : 0,
              child: CustomPaint(size: Size( size, size), painter: CompassPainter(theme)),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  final ThemeData theme;
  const CompassPainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final colorScheme = theme.colorScheme;

    final outerCirclePaint =
        Paint()
          ..color = colorScheme.surfaceContainerHighest
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12;

    final circlePaint =
        Paint()
          ..color = colorScheme.surfaceContainerLow
          ..style = PaintingStyle.fill;

    final arcPaint =
        Paint()
          ..color = colorScheme.primary
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 14;

    final indicatorDotPaint =
        Paint()
          ..color = colorScheme.primary
          ..style = PaintingStyle.fill;

    final centerCrossPaint =
        Paint()
          ..color = colorScheme.primaryContainer
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, outerCirclePaint);
    canvas.drawCircle(center, radius, circlePaint);

    final arcRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(arcRect, vector.radians(225), vector.radians(90), false, arcPaint);

    final dotOffset = Offset(center.dx, center.dy - radius);
    canvas.drawCircle(dotOffset, 5, indicatorDotPaint);

    canvas.drawLine(Offset(center.dx - 10, center.dy), Offset(center.dx + 10, center.dy), centerCrossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 10), Offset(center.dx, center.dy + 10), centerCrossPaint);

    const directions = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};

    for (int i = 0; i < 360; i += 45) {
      final angle = vector.radians(i.toDouble());
      final isDirection = directions.containsKey(i);
      final label = isDirection ? directions[i]! : i.toString();
      final textStyle = TextStyle(
        color: isDirection ? theme.hintColor : colorScheme.onSurfaceVariant,
        fontSize: isDirection ? 28 : 16,
        fontWeight: isDirection ? FontWeight.normal : FontWeight.w300,
      );

      final textPainter = TextPainter(text: TextSpan(text: label, style: textStyle), textDirection: TextDirection.ltr)..layout();

      final labelRadius = (radius - 2.5) * (isDirection ? 0.75 : 0.85);
      final x = center.dx + labelRadius * math.cos(angle - math.pi / 2);
      final y = center.dy + labelRadius * math.sin(angle - math.pi / 2) + 2;
      final labelPosition = Offset(x, y);

      canvas.save();
      canvas.translate(labelPosition.dx, labelPosition.dy);
      canvas.rotate(angle);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // The rotation is handled by Transform.rotate, so the painter itself doesn't need to repaint.
  }
}
