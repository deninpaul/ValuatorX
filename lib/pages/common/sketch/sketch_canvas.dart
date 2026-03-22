import 'package:flutter/material.dart';
import 'package:valuatorx/pages/common/sketch/utils/constants.dart';
import 'package:valuatorx/pages/common/sketch/utils/helper.dart';
import 'package:valuatorx/pages/common/sketch/utils/models.dart';
import 'package:valuatorx/pages/common/sketch/utils/painter.dart';

class SketchCanvas extends StatefulWidget {
  final String value;
  final bool readOnly;
  final ValueChanged<String> onChanged;

  const SketchCanvas({super.key, this.value = '', this.readOnly = false, this.onChanged = _noop});

  static void _noop(String _) {}

  @override
  State<SketchCanvas> createState() => _SketchCanvasState();
}

class _SketchCanvasState extends State<SketchCanvas> {
  // ── Canvas data ───────────────────────────────────────────────────────────────

  late List<Offset> _pts;
  late List<CanvasLine> _lines;
  late Map<int, String> _labels;
  late CanvasSnapshot _initial;

  // Cached encoding — lets didUpdateWidget distinguish external from internal changes
  // without calling encodeCanvas on every rebuild.
  late String _encodedValue;

  // ── History ───────────────────────────────────────────────────────────────────

  final List<CanvasSnapshot> _history = [];

  // ── Layout ────────────────────────────────────────────────────────────────────

  Size _canvasSize = Size.zero;
  bool _initialCentered = false;
  bool _layoutCallbackScheduled = false;

  // VT is always identity — stored coords ARE screen coords.
  static const VT _vt = VT.identity;

  // ── UI mode ───────────────────────────────────────────────────────────────────

  SketchCanvasMode _mode = SketchCanvasMode.draw;

  // ── Draw state ────────────────────────────────────────────────────────────────

  Offset? _dragStart, _dragEnd;
  int? _startPtIdx;
  bool _cancelDraw = false;
  bool _hasMovedAway = false;
  CanvasSnap? _endSnap;

  // ── Move state ────────────────────────────────────────────────────────────────

  int? _movingIdx, _hoverIdx, _mergeTarget;
  final Set<int> _sel = {};
  bool _isDraggingSel = false;
  bool _panOnPt = false;
  Offset? _anchorPx, _anchorStored;
  Map<int, Offset> _startPos = {};
  Rect? _selRect;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadValue(widget.value);
  }

  @override
  void didUpdateWidget(SketchCanvas old) {
    super.didUpdateWidget(old);
    // Reload only when value changed from outside, not from our own _notify().
    if (widget.value != old.value && widget.value != _encodedValue) {
      setState(() => _loadValue(widget.value));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Schedule layout after every mount/tab-switch so we never miss the first size.
    if (!_layoutCallbackScheduled) {
      _layoutCallbackScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _layoutCallbackScheduled = false;
        if (mounted) _applyInitialLayout(_canvasSize);
      });
    }
  }

  // ── Data loading ──────────────────────────────────────────────────────────────

  void _loadValue(String value) {
    final d = decodeCanvas(value);
    _pts = d.pts;
    _lines = d.lines;
    _labels = d.labels;
    _encodedValue = value;
    _initial = _snapshot();
    _initialCentered = false;
    _history.clear();
    _sel.clear();
    _dragStart = _dragEnd = null;
  }

  // ── Layout ────────────────────────────────────────────────────────────────────

  void _applyInitialLayout(Size size) {
    if (_initialCentered || size == Size.zero || _pts.isEmpty) return;
    setState(() {
      applyLayout(_pts, size);
      _initialCentered = true;
    });
  }

  // ── History helpers ───────────────────────────────────────────────────────────

  CanvasSnapshot _snapshot() => CanvasSnapshot(List.of(_pts), _lines.map((l) => l.copy()).toList(), Map.of(_labels));

  void _push() => _history.add(_snapshot());

  void _notify() {
    _encodedValue = encodeCanvas(_pts, _lines, _labels);
    widget.onChanged(_encodedValue);
  }

  void _undo() {
    if (_history.isEmpty) return;
    final s = _history.removeLast();
    setState(() {
      _pts = s.pts;
      _lines = s.lines;
      _labels = s.labels;
      _sel.clear();
      _dragStart = null;
      pruneOrphanPoints(_pts, _lines, _labels, _sel);
    });
    _notify();
  }

  void _reset() {
    _push();
    setState(() {
      _pts = List.of(_initial.pts);
      _lines = _initial.lines.map((l) => l.copy()).toList();
      _labels = Map.of(_initial.labels);
      _sel.clear();
      _dragStart = null;
    });
    _notify();
  }

  // ── Draw gestures ─────────────────────────────────────────────────────────────

  void _onDrawStart(DragStartDetails d) {
    final posPx = d.localPosition;
    final snapIdx = nearestPt(_pts, posPx, _vt, kHitR);
    setState(() {
      _startPtIdx = snapIdx;
      _dragStart = snapIdx != null ? _pts[snapIdx] : toStored(clampToCanvas(posPx, _canvasSize), _vt);
      _dragEnd = _dragStart;
      _hasMovedAway = false;
      _endSnap = null;
    });
  }

  void _onDrawUpdate(DragUpdateDetails d) {
    if (_dragStart == null) return;
    final rawPx = d.localPosition;
    final startPx = toView(_dragStart!, _vt);
    final distPx = (rawPx - startPx).distance;

    if (distPx > kHitR * 1.5) _hasMovedAway = true;
    final nearStart = _hasMovedAway && distPx < kHitR;
    final ptSnap = nearStart ? null : nearestPt(_pts, rawPx, _vt, kHitR, exclude: _startPtIdx);
    final lineSnap = (!nearStart && ptSnap == null) ? snapToLine(_pts, _lines, rawPx, _vt, _startPtIdx) : null;

    setState(() {
      _cancelDraw = nearStart;
      _endSnap = ptSnap != null ? CanvasSnap(pos: _pts[ptSnap], pointIdx: ptSnap) : lineSnap;
      _dragEnd =
          nearStart
              ? _dragStart
              : ptSnap != null
              ? _pts[ptSnap]
              : lineSnap != null
              ? lineSnap.pos
              : toStored(clampToCanvas(snapAngle(startPx, rawPx), _canvasSize), _vt);
    });
  }

  void _onDrawEnd(DragEndDetails _) {
    if (_dragStart == null || _dragEnd == null) return;

    // Cancelled by dragging back to origin.
    if (_cancelDraw) {
      _clearDrawState();
      return;
    }

    // Reject lines shorter than the minimum threshold.
    final snap = _endSnap;
    final endPx = snap?.pointIdx != null ? toView(_pts[snap!.pointIdx!], _vt) : toView(_dragEnd!, _vt);
    if ((endPx - toView(_dragStart!, _vt)).distance < kMinLineLen) {
      _clearDrawState();
      return;
    }

    _push();
    setState(() {
      final startIdx = _startPtIdx ?? (_pts..add(_dragStart!)).length - 1;
      int endIdx;

      if (snap?.pointIdx != null && snap!.pointIdx != startIdx) {
        endIdx = snap.pointIdx!;
      } else if (snap?.lineIdx != null) {
        // Split an existing line by inserting a new point on it.
        _pts.add(snap!.pos);
        endIdx = _pts.length - 1;
        final old = _lines[snap.lineIdx!];
        _lines[snap.lineIdx!] = CanvasLine(old.a, endIdx);
        _lines.add(CanvasLine(endIdx, old.b));
      } else {
        _pts.add(clampToCanvas(_dragEnd!, _canvasSize));
        endIdx = _pts.length - 1;
      }

      if (startIdx != endIdx) _lines.add(CanvasLine(startIdx, endIdx));
      _clearDrawState(insideSetState: true);
      pruneOrphanPoints(_pts, _lines, _labels, _sel);
    });
    _notify();
  }

  /// Resets all draw-gesture fields. Pass [insideSetState]=true when already
  /// inside a setState block to avoid a redundant setState call.
  void _clearDrawState({bool insideSetState = false}) {
    void clear() {
      _dragStart = _dragEnd = null;
      _startPtIdx = null;
      _cancelDraw = false;
      _hasMovedAway = false;
      _endSnap = null;
    }

    insideSetState ? clear() : setState(clear);
  }

  // ── Move gestures ─────────────────────────────────────────────────────────────

  void _onMoveStart(DragStartDetails d) {
    final posPx = d.localPosition;
    final idx = nearestPt(_pts, posPx, _vt, kHitR);
    _panOnPt = idx != null;

    setState(() {
      if (idx != null && _sel.contains(idx)) {
        _isDraggingSel = true;
        _anchorStored = toStored(posPx, _vt);
        _startPos = {for (final i in _sel) i: _pts[i]};
        _selRect = null;
      } else if (idx != null) {
        _sel.clear();
        _movingIdx = _hoverIdx = idx;
        _selRect = null;
      } else {
        _sel.clear();
        _anchorPx = posPx;
        _selRect = Rect.fromPoints(posPx, posPx);
      }
    });
  }

  void _onMoveUpdate(DragUpdateDetails d) {
    final posPx = d.localPosition;

    if (_isDraggingSel) {
      final delta = toStored(posPx, _vt) - _anchorStored!;
      setState(() {
        for (final i in _sel) {
          _pts[i] = clampToCanvas(_startPos[i]! + delta, _canvasSize);
        }
      });
      return;
    }

    if (_movingIdx != null) {
      final snapped = clampToCanvas(snapMovedPt(_movingIdx!, posPx, _pts, _lines, _vt), _canvasSize);
      final merge = nearestPt(_pts, toView(snapped, _vt), _vt, kSnapR, exclude: _movingIdx);
      setState(() {
        _pts[_movingIdx!] = snapped;
        _hoverIdx = _movingIdx;
        _mergeTarget = merge;
      });
      return;
    }

    if (!_panOnPt && _anchorPx != null) {
      final rect = Rect.fromPoints(_anchorPx!, posPx);
      setState(() {
        _selRect = rect;
        _sel
          ..clear()
          ..addAll([
            for (int i = 0; i < _pts.length; i++)
              if (rect.contains(toView(_pts[i], _vt))) i,
          ]);
      });
    }
  }

  void _onMoveEnd(DragEndDetails _) {
    if (_movingIdx != null || _isDraggingSel) _push();
    if (_movingIdx != null && _mergeTarget != null) {
      _mergePoints(_movingIdx!, _mergeTarget!);
    }
    setState(() {
      _movingIdx = _hoverIdx = _mergeTarget = null;
      _isDraggingSel = _panOnPt = false;
      _anchorPx = _anchorStored = null;
      _startPos = {};
      _selRect = null;
    });
    _notify();
  }

  void _mergePoints(int from, int into) {
    setState(() {
      for (final l in _lines) {
        if (l.a == from) l.a = into;
        if (l.b == from) l.b = into;
      }
      // Remove self-loops and duplicate lines created by the merge.
      _lines.removeWhere((l) => l.a == l.b);
      final seen = <String>{};
      _lines.removeWhere((l) => !seen.add(l.key));
      // Remove the merged-away point and fix all indices.
      _pts.removeAt(from);
      for (final l in _lines) {
        if (l.a > from) l.a--;
        if (l.b > from) l.b--;
      }
      pruneOrphanPoints(_pts, _lines, _labels, _sel);
    });
  }

  void _onMoveTap(TapUpDetails d) {
    final posPx = d.localPosition;
    final ptIdx = nearestPt(_pts, posPx, _vt, kHitR);

    if (ptIdx != null) {
      setState(() => _sel.contains(ptIdx) ? _sel.remove(ptIdx) : _sel.add(ptIdx));
      return;
    }

    // Hit-test lines for label editing.
    int? hitLine;
    double bestD = 14.0;
    for (int i = 0; i < _lines.length; i++) {
      final dist = (closestOnSeg(toView(_pts[_lines[i].a], _vt), toView(_pts[_lines[i].b], _vt), posPx) - posPx).distance;
      if (dist < bestD) {
        bestD = dist;
        hitLine = i;
      }
    }

    if (hitLine != null) {
      _showLabelDialog(hitLine);
    } else {
      setState(() => _sel.clear());
    }
  }

  // ── Label dialog ──────────────────────────────────────────────────────────────

  void _showLabelDialog(int idx) {
    final existing = _labels[idx] ?? '';
    final ctrl = TextEditingController(text: existing);
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(existing.isEmpty ? 'Add length' : 'Edit length'),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: const InputDecoration(hintText: 'e.g. 3.5', border: OutlineInputBorder()),
              onSubmitted: (_) {
                _commitLabel(idx, ctrl.text.trim());
                Navigator.of(ctx).pop();
              },
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  _commitLabel(idx, ctrl.text.trim());
                  Navigator.of(ctx).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _commitLabel(int idx, String text) {
    _push();
    setState(() => text.isEmpty ? _labels.remove(idx) : _labels[idx] = text);
    _notify();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDrawMode = !widget.readOnly && _mode == SketchCanvasMode.draw;

    return Stack(
      children: [
        LayoutBuilder(
          builder: (ctx, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            if (size != Size.zero && size != _canvasSize) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  if (!_initialCentered && _pts.isNotEmpty) {
                    applyLayout(_pts, size);
                    _initialCentered = true;
                  } else if (_canvasSize != Size.zero && _pts.isNotEmpty) {
                    applyLayout(_pts, size);
                  }
                  _canvasSize = size;
                });
              });
            }

            return GestureDetector(
              onPanStart: widget.readOnly ? null : (isDrawMode ? _onDrawStart : _onMoveStart),
              onPanUpdate: widget.readOnly ? null : (isDrawMode ? _onDrawUpdate : _onMoveUpdate),
              onPanEnd: widget.readOnly ? null : (isDrawMode ? _onDrawEnd : _onMoveEnd),
              onTapUp: (!widget.readOnly && !isDrawMode) ? _onMoveTap : null,
              child: CustomPaint(
                painter: CanvasPainter(
                  pts: _pts,
                  lines: _lines,
                  labels: _labels,
                  vt: _vt,
                  cs: cs,
                  dragStart: isDrawMode ? _dragStart : null,
                  dragEnd: isDrawMode ? _dragEnd : null,
                  cancelDraw: isDrawMode && _cancelDraw,
                  endSnap: isDrawMode ? _endSnap : null,
                  activePoint: isDrawMode ? null : _hoverIdx,
                  mergeTarget: isDrawMode ? null : _mergeTarget,
                  selected: isDrawMode ? const {} : _sel,
                  selRect: isDrawMode ? null : _selRect,
                ),
                child: const SizedBox.expand(),
              ),
            );
          },
        ),
        if (_pts.isEmpty)
          Center(
            child: Text(
              widget.readOnly ? 'No Land Sketch' : 'Drag on canvas to start drawing',
              style: theme.textTheme.bodyLarge!.copyWith(color: theme.hintColor),
            ),
          ),
        if (!widget.readOnly) _buildToolbar(cs),
      ],
    );
  }

  Widget _buildToolbar(ColorScheme cs) => Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(64)),
      child: Wrap(
        spacing: 5,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SegmentedButton<SketchCanvasMode>(
            segments: const [
              ButtonSegment(value: SketchCanvasMode.draw, icon: Icon(Icons.edit_outlined), label: Text('Draw')),
              ButtonSegment(value: SketchCanvasMode.move, icon: Icon(Icons.open_with), label: Text('Move')),
            ],
            selected: {_mode},
            onSelectionChanged:
                (s) => setState(() {
                  _mode = s.first;
                  _dragStart = _dragEnd = null;
                }),
          ),
          const SizedBox(width: 8),
          IconButton(tooltip: 'Undo', icon: const Icon(Icons.undo), onPressed: _history.isNotEmpty ? _undo : null),
          IconButton(tooltip: 'Reset', icon: const Icon(Icons.restart_alt), onPressed: _reset),
        ],
      ),
    ),
  );
}
