import 'package:flutter/material.dart';
import 'package:valuatorx/pages/common/sketch/utils/constants.dart';
import 'package:valuatorx/pages/common/sketch/utils/models.dart';

class CanvasPainter extends CustomPainter {
  final List<Offset> pts;
  final List<CanvasLine> lines;
  final Map<int, String> labels;
  final VT vt;
  final ColorScheme cs;

  // Draw state
  final Offset? dragStart;
  final Offset? dragEnd;
  final bool cancelDraw;
  final CanvasSnap? endSnap;

  // Move state
  final int? activePoint;
  final int? mergeTarget;
  final Set<int> selected;
  final Rect? selRect;

  const CanvasPainter({
    required this.pts,
    required this.lines,
    required this.labels,
    required this.vt,
    required this.cs,
    this.dragStart,
    this.dragEnd,
    this.cancelDraw = false,
    this.endSnap,
    this.activePoint,
    this.mergeTarget,
    this.selected = const {},
    this.selRect,
  });

  Offset _v(Offset s) => toView(s, vt);

  Paint _stroke(Color c, double w) =>
      Paint()
        ..color = c
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

  Paint _fill(Color c) =>
      Paint()
        ..color = c
        ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    _drawLines(canvas);
    _drawGhostLine(canvas);
    _drawLineSnapIndicator(canvas);
    _drawSelectionRect(canvas);
    _drawPoints(canvas);
    _drawDragStartIndicator(canvas);
    _drawLabels(canvas);
  }

  void _drawLines(Canvas canvas) {
    final p = _stroke(cs.primary, 3);
    for (final l in lines) {
      canvas.drawLine(_v(pts[l.a]), _v(pts[l.b]), p);
    }
  }

  void _drawGhostLine(Canvas canvas) {
    if (dragStart == null || dragEnd == null) return;
    canvas.drawLine(_v(dragStart!), _v(dragEnd!), _stroke(cs.primary.withValues(alpha: .35), 2.5));
  }

  void _drawLineSnapIndicator(Canvas canvas) {
    if (endSnap?.pointIdx != null || endSnap == null) return;
    final p = _v(endSnap!.pos);
    canvas.drawCircle(p, kPointR + 5, _fill(cs.secondary.withValues(alpha: 0.25)));
    canvas.drawCircle(p, kPointR + 5, _stroke(cs.secondary, 2));
    canvas.drawCircle(p, kPointR, _fill(cs.secondary));
  }

  void _drawSelectionRect(Canvas canvas) {
    if (selRect == null) return;
    canvas.drawRect(selRect!, _fill(cs.primary.withValues(alpha: 0.08)));
    canvas.drawRect(selRect!, _stroke(cs.primary.withValues(alpha: 0.5), 1.5));
  }

  void _drawPoints(Canvas canvas) {
    for (int i = 0; i < pts.length; i++) {
      final isMerge = i == mergeTarget;
      final isSnap = i == endSnap?.pointIdx;
      final isSel = selected.contains(i);
      final isActive = i == activePoint;
      final p = _v(pts[i]);

      // Halo rings
      final halo =
          isMerge
              ? cs.error
              : isSnap
              ? cs.secondary
              : null;
      if (halo != null) {
        canvas.drawCircle(p, kPointR + 7, _fill(halo.withValues(alpha: 0.25)));
        canvas.drawCircle(p, kPointR + 7, _stroke(halo, 2));
      }

      // Fill
      canvas.drawCircle(
        p,
        kPointR,
        _fill(
          isMerge
              ? cs.error.withValues(alpha: 0.15)
              : isSnap
              ? cs.secondary.withValues(alpha: 0.25)
              : isSel
              ? cs.primary.withValues(alpha: 0.25)
              : isActive
              ? cs.secondary
              : cs.surface,
        ),
      );

      // Border
      canvas.drawCircle(
        p,
        kPointR,
        _stroke(isMerge || isSnap || isActive ? (isMerge ? cs.error : cs.secondary) : cs.primary, (isSel || isSnap) ? 3.0 : 2.5),
      );
    }
  }

  void _drawDragStartIndicator(Canvas canvas) {
    if (dragStart == null) return;
    final p = _v(dragStart!);
    if (cancelDraw) {
      canvas.drawCircle(p, kPointR + 7, _fill(cs.error.withValues(alpha: .25)));
      canvas.drawCircle(p, kPointR + 7, _stroke(cs.error, 2));
      canvas.drawCircle(p, kPointR, _fill(cs.error.withValues(alpha: .15)));
      canvas.drawCircle(p, kPointR, _stroke(cs.error, 2));
    } else {
      canvas.drawCircle(p, kPointR, _fill(cs.primary.withValues(alpha: .5)));
    }
  }

  void _drawLabels(Canvas canvas) {
    for (final e in labels.entries) {
      if (e.key >= lines.length) continue;
      final l = lines[e.key];
      if (l.a >= pts.length || l.b >= pts.length) continue;
      final mid = (_v(pts[l.a]) + _v(pts[l.b])) / 2;
      final tp = TextPainter(
        text: TextSpan(text: e.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        textDirection: TextDirection.ltr,
      )..layout();
      const pad = 4.0;
      final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: mid, width: tp.width + pad * 2, height: tp.height + pad * 2),
        const Radius.circular(4),
      );
      canvas.drawRRect(rr, _fill(cs.surface));
      canvas.drawRRect(rr, _stroke(cs.primary.withValues(alpha: 0.4), 1));
      tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(CanvasPainter old) => true;
}
