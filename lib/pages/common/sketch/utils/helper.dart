import 'dart:math';
import 'package:flutter/material.dart';
import 'package:valuatorx/pages/common/sketch/utils/constants.dart';
import 'package:valuatorx/pages/common/sketch/utils/models.dart';

// ─── Bounds clamping ─────────────────────────────────────────────────────────

/// Clamps [p] so the point circle stays fully inside the canvas bounds.
Offset clampToCanvas(Offset p, Size size) => Offset(p.dx.clamp(kPointR, size.width - kPointR), p.dy.clamp(kPointR, size.height - kPointR));

// ─── Angle snap ──────────────────────────────────────────────────────────────

Offset snapAngle(Offset startPx, Offset endPx) {
  final d = endPx - startPx;
  final len = d.distance;
  if (len == 0) return endPx;
  final deg = atan2(d.dy, d.dx) * 180 / pi;
  for (final s in [0.0, 45.0, 90.0, 135.0, 180.0, -135.0, -90.0, -45.0]) {
    if ((deg - s).abs() % 360 < kSnapDeg) {
      final rad = s * pi / 180;
      return startPx + Offset(cos(rad) * len, sin(rad) * len);
    }
  }
  return endPx;
}

// ─── Segment geometry ────────────────────────────────────────────────────────

Offset closestOnSeg(Offset a, Offset b, Offset p) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return a;
  return a + ab * ((p - a).dx * ab.dx + (p - a).dy * ab.dy).clamp(0.0, len2) / len2;
}

// ─── Hit testing (all in view-px) ────────────────────────────────────────────

int? nearestPt(List<Offset> pts, Offset posPx, VT t, double radius, {int? exclude}) {
  int? best;
  double bestD = radius;
  for (int i = 0; i < pts.length; i++) {
    if (i == exclude) continue;
    final d = (toView(pts[i], t) - posPx).distance;
    if (d < bestD) {
      bestD = d;
      best = i;
    }
  }
  return best;
}

CanvasSnap? snapToLine(List<Offset> pts, List<CanvasLine> lines, Offset posPx, VT t, int? exclPt) {
  int? bestIdx;
  Offset? bestPx;
  double bestD = kLineSnapR;
  for (int i = 0; i < lines.length; i++) {
    final l = lines[i];
    if (exclPt != null && (l.a == exclPt || l.b == exclPt)) continue;
    final cp = closestOnSeg(toView(pts[l.a], t), toView(pts[l.b], t), posPx);
    final d = (cp - posPx).distance;
    if (d < bestD) {
      bestD = d;
      bestIdx = i;
      bestPx = cp;
    }
  }
  return bestIdx != null ? CanvasSnap(pos: toStored(bestPx!, t), lineIdx: bestIdx) : null;
}

// ─── Move-point snapping ─────────────────────────────────────────────────────
//
// Input: rawPx in view-px. Returns stored coords.

Offset snapMovedPt(int idx, Offset rawPx, List<Offset> pts, List<CanvasLine> lines, VT t) {
  double sx = rawPx.dx, sy = rawPx.dy;
  double bx = kSnapR * 1.5, by = kSnapR * 1.5;

  final candidates = [
    for (final l in lines)
      if (l.a == idx) toView(pts[l.b], t) else if (l.b == idx) toView(pts[l.a], t),
    for (int i = 0; i < pts.length; i++)
      if (i != idx) toView(pts[i], t),
  ];

  for (final o in candidates) {
    if ((o.dx - rawPx.dx).abs() < bx) {
      bx = (o.dx - rawPx.dx).abs();
      sx = o.dx;
    }
    if ((o.dy - rawPx.dy).abs() < by) {
      by = (o.dy - rawPx.dy).abs();
      sy = o.dy;
    }
  }

  // Diagonal angle snap when no axis snap fired
  if (bx >= kSnapR * 1.5 && by >= kSnapR * 1.5) {
    for (final l in lines) {
      final n =
          l.a == idx
              ? l.b
              : l.b == idx
              ? l.a
              : null;
      if (n == null) continue;
      final c = snapAngle(toView(pts[n], t), rawPx);
      if ((c - rawPx).distance < kSnapR * 1.5) return toStored(c, t);
    }
  }

  // Line snap
  final ls = snapToLine(pts, lines, Offset(sx, sy), t, idx);
  if (ls != null) return ls.pos;

  return toStored(Offset(sx, sy), t);
}

// ─── Layout helpers ──────────────────────────────────────────────────────────

/// Mutates [pts] to scale (if any point overflows) and center the bounding box
/// within [size], keeping [kMargin] padding on all sides.
void applyLayout(List<Offset> pts, Size size) {
  if (pts.isEmpty || size == Size.zero) return;

  final minX = pts.map((p) => p.dx).reduce(min);
  final minY = pts.map((p) => p.dy).reduce(min);
  final maxX = pts.map((p) => p.dx).reduce(max);
  final maxY = pts.map((p) => p.dy).reduce(max);

  final availW = size.width - kMargin * 2;
  final availH = size.height - kMargin * 2;
  final shapeW = maxX - minX;
  final shapeH = maxY - minY;

  // Scale down only if a point actually breaches a boundary
  double s = 1.0;
  final overflows = minX < kMargin || minY < kMargin || maxX > size.width - kMargin || maxY > size.height - kMargin;
  if (overflows) {
    if (shapeW > 0 && shapeW > availW) s = min(s, availW / shapeW);
    if (shapeH > 0 && shapeH > availH) s = min(s, availH / shapeH);
    s = s.clamp(0.01, 1.0);
  }

  // Center the (scaled) bounding box
  final dx = kMargin + (availW - shapeW * s) / 2 - minX * s;
  final dy = kMargin + (availH - shapeH * s) / 2 - minY * s;

  for (int i = 0; i < pts.length; i++) {
    pts[i] = Offset(pts[i].dx * s + dx, pts[i].dy * s + dy);
  }
}

// ─── Orphan cleanup ──────────────────────────────────────────────────────────

/// Removes any point not referenced by at least one line.
/// Mutates [pts], [lines], [labels], and [sel] in place.
void pruneOrphanPoints(List<Offset> pts, List<CanvasLine> lines, Map<int, String> labels, Set<int> sel) {
  final referenced = <int>{};
  for (final l in lines) {
    referenced.add(l.a);
    referenced.add(l.b);
  }

  final orphans = [
    for (int i = pts.length - 1; i >= 0; i--)
      if (!referenced.contains(i)) i,
  ];

  for (final idx in orphans) {
    pts.removeAt(idx);
    labels.remove(idx);

    for (final l in lines) {
      if (l.a > idx) l.a--;
      if (l.b > idx) l.b--;
    }
    final shiftedLabels = <int, String>{};
    for (final e in labels.entries) {
      shiftedLabels[e.key > idx ? e.key - 1 : e.key] = e.value;
    }
    labels
      ..clear()
      ..addAll(shiftedLabels);

    sel.remove(idx);
    final shifted = sel.where((i) => i > idx).toList();
    sel.removeAll(shifted);
    sel.addAll(shifted.map((i) => i - 1));
  }
}

// ─── Encoding ────────────────────────────────────────────────────────────────
//
// Format: "<points>|<lines>|<labels>"
//   points : "x1,y1;x2,y2;..."
//   lines  : "a1-b1;a2-b2;..."
//   labels : "lineIdx:text;..."
//
// Empty canvas → empty string "".

String encodeCanvas(List<Offset> pts, List<CanvasLine> lines, Map<int, String> labels) {
  if (pts.isEmpty) return '';
  final p = pts.map((o) => '${o.dx.toStringAsFixed(2)},${o.dy.toStringAsFixed(2)}').join(';');
  final l = lines.map((l) => '${l.a}-${l.b}').join(';');
  final lb = labels.entries.map((e) => '${e.key}:${e.value}').join(';');
  return '$p|$l|$lb';
}

// ─── Decoding ────────────────────────────────────────────

({List<Offset> pts, List<CanvasLine> lines, Map<int, String> labels}) decodeCanvas(String s) {
  if (s.isEmpty) return (pts: [], lines: [], labels: {});
  final parts = s.split('|');

  final pts =
      parts[0].isNotEmpty
          ? parts[0].split(';').map((p) {
            final xy = p.split(',');
            return Offset(double.parse(xy[0]), double.parse(xy[1]));
          }).toList()
          : <Offset>[];

  final lines =
      (parts.length > 1 && parts[1].isNotEmpty)
          ? parts[1].split(';').map((l) {
            final se = l.split('-');
            return CanvasLine(int.parse(se[0]), int.parse(se[1]));
          }).toList()
          : <CanvasLine>[];

  final labels = <int, String>{};
  if (parts.length > 2 && parts[2].isNotEmpty) {
    for (final e in parts[2].split(';')) {
      final i = e.indexOf(':');
      if (i != -1) labels[int.parse(e.substring(0, i))] = e.substring(i + 1);
    }
  }

  return (pts: pts, lines: lines, labels: labels);
}
