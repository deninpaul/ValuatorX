import 'package:flutter/material.dart';

// ─── Line ─────────────────────────────────────────────────────────────────────

class CanvasLine {
  int a, b;
  CanvasLine(this.a, this.b);
  CanvasLine copy() => CanvasLine(a, b);

  /// Canonical key stable regardless of which endpoint is [a] or [b].
  String get key => a < b ? '$a-$b' : '$b-$a';
}

// ─── Snap result ─────────────────────────────────────────────────────────────

class CanvasSnap {
  final int? pointIdx;
  final int? lineIdx;
  final Offset pos; // stored coords
  const CanvasSnap({required this.pos, this.pointIdx, this.lineIdx});
}

// ─── Free-floating text label ─────────────────────────────────────────────────
//
// [pos] is stored coords (same coordinate space as pts).

class CanvasTextLabel {
  Offset pos;
  String text;
  CanvasTextLabel({required this.pos, required this.text});
  CanvasTextLabel copy() => CanvasTextLabel(pos: pos, text: text);
}

// ─── Undo snapshot ───────────────────────────────────────────────────────────
//
// [labels] is keyed by CanvasLine.key (e.g. "3-7"), NOT by line list index.
// This makes measurement labels immune to line reordering / removal.

class CanvasSnapshot {
  final List<Offset> pts;
  final List<CanvasLine> lines;
  final Map<String, String> labels; // lineKey → measurement text
  final List<CanvasTextLabel> textLabels;
  CanvasSnapshot(this.pts, this.lines, this.labels, this.textLabels);
}

// ─── View transform ──────────────────────────────────────────────────────────

class VT {
  final double scale;
  final Offset translate;
  const VT(this.scale, this.translate);
  static const identity = VT(1.0, Offset.zero);
}

Offset toView(Offset stored, VT t) => stored * t.scale + t.translate;
Offset toStored(Offset viewPx, VT t) => t.scale == 0 ? viewPx : (viewPx - t.translate) / t.scale;
