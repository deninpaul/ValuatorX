import 'package:flutter/material.dart';

// ─── Line ─────────────────────────────────────────────────────────────────────

class CanvasLine {
  int a, b;
  CanvasLine(this.a, this.b);
  CanvasLine copy() => CanvasLine(a, b);
  String get key => a < b ? '$a-$b' : '$b-$a';
}

// ─── Snap result ─────────────────────────────────────────────────────────────

class CanvasSnap {
  final int? pointIdx;
  final int? lineIdx;
  final Offset pos; // stored coords
  const CanvasSnap({required this.pos, this.pointIdx, this.lineIdx});
}

// ─── Undo snapshot ───────────────────────────────────────────────────────────

class CanvasSnapshot {
  final List<Offset> pts;
  final List<CanvasLine> lines;
  final Map<int, String> labels;
  CanvasSnapshot(this.pts, this.lines, this.labels);
}

// ─── View transform ──────────────────────────────────────────────────────────
//
// Always identity — stored coords ARE screen coords.
// Centering and scaling are done by mutating stored coords at the right moments.
//
//   view_px = stored * scale + translate
//   stored  = (view_px − translate) / scale

class VT {
  final double scale;
  final Offset translate;
  const VT(this.scale, this.translate);
  static const identity = VT(1.0, Offset.zero);
}

Offset toView(Offset stored, VT t) => stored * t.scale + t.translate;
Offset toStored(Offset viewPx, VT t) => t.scale == 0 ? viewPx : (viewPx - t.translate) / t.scale;
