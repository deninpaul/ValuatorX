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
  late Map<String, String> _labels; // lineKey → measurement text
  late List<CanvasTextLabel> _textLabels; // free-floating canvas text
  late CanvasSnapshot _initial;
  late String _encodedValue;

  // ── History ───────────────────────────────────────────────────────────────────

  final List<CanvasSnapshot> _history = [];

  // ── Layout ────────────────────────────────────────────────────────────────────

  Size _canvasSize = Size.zero;
  bool _initialCentered = false;
  bool _layoutCallbackScheduled = false;
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
  int? _movingTextLabelIdx; // text label being dragged in move mode
  final Set<int> _sel = {};
  bool _isDraggingSel = false;
  bool _panOnPt = false;
  bool _panOnTextLabel = false;
  Offset? _anchorPx, _anchorStored;
  Map<int, Offset> _startPos = {};
  Rect? _selRect;

  // ── Shared ────────────────────────────────────────────────────────────────────

  // Highlighted text label (move drag or write tap)
  int? _activeTextLabel;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadValue(widget.value);
  }

  @override
  void didUpdateWidget(SketchCanvas old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value && widget.value != _encodedValue) {
      setState(() => _loadValue(widget.value));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    _textLabels = d.textLabels;
    _encodedValue = value;
    _initial = _snapshot();
    _initialCentered = false;
    _history.clear();
    _sel.clear();
    _dragStart = _dragEnd = null;
    _activeTextLabel = null;
    _movingTextLabelIdx = null;
  }

  // ── Layout ────────────────────────────────────────────────────────────────────

  void _applyInitialLayout(Size size) {
    if (_initialCentered || size == Size.zero || _pts.isEmpty) return;
    setState(() {
      applyLayout(_pts, size, textLabels: _textLabels);
      _initialCentered = true;
    });
  }

  // ── History ───────────────────────────────────────────────────────────────────

  CanvasSnapshot _snapshot() =>
      CanvasSnapshot(List.of(_pts), _lines.map((l) => l.copy()).toList(), Map.of(_labels), _textLabels.map((t) => t.copy()).toList());

  void _push() => _history.add(_snapshot());

  void _notify() {
    _encodedValue = encodeCanvas(_pts, _lines, _labels, _textLabels);
    widget.onChanged(_encodedValue);
  }

  void _undo() {
    if (_history.isEmpty) return;
    final s = _history.removeLast();
    setState(() {
      _pts = s.pts;
      _lines = s.lines;
      _labels = s.labels;
      _textLabels = s.textLabels;
      _sel.clear();
      _activeTextLabel = null;
      _movingTextLabelIdx = null;
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
      _textLabels = _initial.textLabels.map((t) => t.copy()).toList();
      _sel.clear();
      _activeTextLabel = null;
      _movingTextLabelIdx = null;
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

    if (_cancelDraw) {
      _clearDrawState();
      return;
    }

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
  //
  // Priority on pan-start: text label > point > selection rect.
  // _push() is called HERE (before mutation) so undo always captures pre-move state.

  void _onMoveStart(DragStartDetails d) {
    final posPx = d.localPosition;

    // 1. Hit-test floating text labels first.
    final tlIdx = hitTextLabel(_textLabels, posPx, _vt);
    if (tlIdx != null) {
      _push(); // snapshot before mutation
      setState(() {
        _movingTextLabelIdx = tlIdx;
        _activeTextLabel = tlIdx;
        _panOnTextLabel = true;
        _sel.clear();
        _selRect = null;
      });
      return;
    }

    // 2. Hit-test geometry points.
    final idx = nearestPt(_pts, posPx, _vt, kHitR);
    if (idx != null) {
      _push(); // snapshot before mutation
      setState(() {
        _panOnPt = true;
        _panOnTextLabel = false;
        if (_sel.contains(idx) && _sel.length > 1) {
          _isDraggingSel = true;
          _anchorPx = posPx;
          _anchorStored = toStored(posPx, _vt);
          _startPos = {for (final i in _sel) i: _pts[i]};
        } else {
          _isDraggingSel = false;
          _sel.clear();
          _movingIdx = _hoverIdx = idx;
          _selRect = null;
        }
      });
      return;
    }

    // 3. Start a rubber-band selection rect.
    setState(() {
      _panOnPt = false;
      _panOnTextLabel = false;
      _sel.clear();
      _anchorPx = posPx;
      _selRect = Rect.fromPoints(posPx, posPx);
    });
  }

  void _onMoveUpdate(DragUpdateDetails d) {
    final posPx = d.localPosition;

    // Drag a floating text label.
    if (_panOnTextLabel && _movingTextLabelIdx != null) {
      setState(() {
        _textLabels[_movingTextLabelIdx!].pos = toStored(clampToCanvas(posPx, _canvasSize), _vt);
      });
      return;
    }

    // Drag a multi-selection.
    if (_isDraggingSel) {
      final delta = toStored(posPx, _vt) - _anchorStored!;
      setState(() {
        for (final i in _sel) {
          _pts[i] = clampToCanvas(_startPos[i]! + delta, _canvasSize);
        }
      });
      return;
    }

    // Drag a single point.
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

    // Rubber-band selection rect.
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
    // Merge points if dragged close enough.
    if (_movingIdx != null && _mergeTarget != null) {
      _mergePoints(_movingIdx!, _mergeTarget!);
    }

    setState(() {
      _movingIdx = _hoverIdx = _mergeTarget = null;
      _movingTextLabelIdx = null;
      _activeTextLabel = null;
      _isDraggingSel = _panOnPt = _panOnTextLabel = false;
      _anchorPx = _anchorStored = null;
      _startPos = {};
      _selRect = null;
    });
    _notify();
  }

  void _mergePoints(int from, int into) {
    // Labels are keyed by canonical string — they survive point index shifts
    // automatically because we rebuild keys via pruneOrphanPoints.
    // But we must also remap keys when we renumber [from] → [into] here.
    setState(() {
      // Redirect lines.
      for (final l in _lines) {
        if (l.a == from) l.a = into;
        if (l.b == from) l.b = into;
      }
      _lines.removeWhere((l) => l.a == l.b);
      final seen = <String>{};
      _lines.removeWhere((l) => !seen.add(l.key));

      // Remove the merged-away point; renumber all references.
      _pts.removeAt(from);
      for (final l in _lines) {
        if (l.a > from) l.a--;
        if (l.b > from) l.b--;
      }

      // Rebuild label keys with same shift logic as pruneOrphanPoints.
      final rebuilt = <String, String>{};
      for (final e in _labels.entries) {
        final parts = e.key.split('-');
        if (parts.length != 2) continue;
        int a = int.parse(parts[0]);
        int b = int.parse(parts[1]);
        if (a == from || b == from) continue; // the merged-away point's lines are gone
        if (a > from) a--;
        if (b > from) b--;
        rebuilt[a < b ? '$a-$b' : '$b-$a'] = e.value;
      }
      _labels
        ..clear()
        ..addAll(rebuilt);

      pruneOrphanPoints(_pts, _lines, _labels, _sel);
    });
  }

  void _onMoveTap(TapUpDetails d) {
    final posPx = d.localPosition;

    // Tap a point → toggle selection.
    final ptIdx = nearestPt(_pts, posPx, _vt, kHitR);
    if (ptIdx != null) {
      setState(() => _sel.contains(ptIdx) ? _sel.remove(ptIdx) : _sel.add(ptIdx));
      return;
    }

    setState(() => _sel.clear());
  }

  // ── Write gestures ────────────────────────────────────────────────────────────
  //
  // Tap a line      → measurement dialog
  // Tap a text label → edit dialog
  // Tap empty space → place new floating text label

  void _onWriteTap(TapUpDetails d) {
    final posPx = d.localPosition;

    // 1. Existing floating text label → edit.
    final tlIdx = hitTextLabel(_textLabels, posPx, _vt);
    if (tlIdx != null) {
      setState(() => _activeTextLabel = tlIdx);
      _showTextLabelDialog(tlIdx);
      return;
    }

    // 2. Line → measurement.
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
      _showMeasurementDialog(hitLine);
      return;
    }

    // 3. Empty space → place placeholder immediately, then open dialog.
    _placeNewTextLabel(toStored(clampToCanvas(posPx, _canvasSize), _vt));
  }

  // ── Text label helpers ────────────────────────────────────────────────────────

  void _placeNewTextLabel(Offset pos) {
    // Insert a placeholder right now — position is locked before keyboard opens.
    _push();
    final newIdx = _textLabels.length;
    setState(() {
      _textLabels.add(CanvasTextLabel(pos: pos, text: '…'));
      _activeTextLabel = newIdx;
    });
    _notify();

    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Add label'),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'e.g. Ground Floor', border: OutlineInputBorder()),
              onSubmitted: (_) {
                _finaliseNewTextLabel(newIdx, ctrl.text.trim());
                Navigator.of(ctx).pop();
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Cancel → remove the placeholder entirely (undo the _push above).
                  _undo();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  _finaliseNewTextLabel(newIdx, ctrl.text.trim());
                  Navigator.of(ctx).pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
    ).then((_) {
      if (mounted) setState(() => _activeTextLabel = null);
    });
  }

  void _finaliseNewTextLabel(int idx, String text) {
    if (idx >= _textLabels.length) return;
    if (text.isEmpty) {
      // Empty input — remove placeholder (undo restores pre-placeholder state).
      _undo();
    } else {
      // Overwrite placeholder text in-place; no extra history entry needed.
      setState(() => _textLabels[idx].text = text);
      _notify();
    }
  }

  void _showTextLabelDialog(int idx) {
    final existing = _textLabels[idx].text;
    final ctrl = TextEditingController(text: existing);
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Edit label'),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'e.g. Ground Floor', border: OutlineInputBorder()),
              onSubmitted: (_) {
                _commitTextLabel(idx, ctrl.text.trim());
                Navigator.of(ctx).pop();
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _push();
                  setState(() => _textLabels.removeAt(idx));
                  _notify();
                  Navigator.of(ctx).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
                child: const Text('Remove'),
              ),
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  _commitTextLabel(idx, ctrl.text.trim());
                  Navigator.of(ctx).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    ).then((_) {
      if (mounted) setState(() => _activeTextLabel = null);
    });
  }

  void _commitTextLabel(int idx, String text) {
    _push();
    if (text.isEmpty) {
      setState(() => _textLabels.removeAt(idx));
    } else {
      setState(() => _textLabels[idx].text = text);
    }
    _notify();
  }

  // ── Measurement label helpers ─────────────────────────────────────────────────

  void _showMeasurementDialog(int lineListIdx) {
    final lineKey = _lines[lineListIdx].key;
    final existing = _labels[lineKey] ?? '';
    final ctrl = TextEditingController(text: existing);
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(existing.isEmpty ? 'Add measurement' : 'Edit measurement'),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'e.g. 3.5 m', border: OutlineInputBorder()),
              onSubmitted: (_) {
                _commitMeasurementLabel(lineKey, ctrl.text.trim());
                Navigator.of(ctx).pop();
              },
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              if (existing.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _commitMeasurementLabel(lineKey, '');
                    Navigator.of(ctx).pop();
                  },
                  style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
                  child: const Text('Remove'),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                  FilledButton(
                    onPressed: () {
                      _commitMeasurementLabel(lineKey, ctrl.text.trim());
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  void _commitMeasurementLabel(String lineKey, String text) {
    _push();
    setState(() => text.isEmpty ? _labels.remove(lineKey) : _labels[lineKey] = text);
    _notify();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDrawMode = !widget.readOnly && _mode == SketchCanvasMode.draw;
    final isMoveMode = !widget.readOnly && _mode == SketchCanvasMode.move;
    final isWriteMode = !widget.readOnly && _mode == SketchCanvasMode.write;

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
                    applyLayout(_pts, size, textLabels: _textLabels);
                    _initialCentered = true;
                  } else if (_canvasSize != Size.zero && _pts.isNotEmpty) {
                    applyLayout(_pts, size, textLabels: _textLabels);
                  }
                  _canvasSize = size;
                });
              });
            }

            return GestureDetector(
              onPanStart:
                  widget.readOnly
                      ? null
                      : isDrawMode
                      ? _onDrawStart
                      : isMoveMode
                      ? _onMoveStart
                      : null,
              onPanUpdate:
                  widget.readOnly
                      ? null
                      : isDrawMode
                      ? _onDrawUpdate
                      : isMoveMode
                      ? _onMoveUpdate
                      : null,
              onPanEnd:
                  widget.readOnly
                      ? null
                      : isDrawMode
                      ? _onDrawEnd
                      : isMoveMode
                      ? _onMoveEnd
                      : null,
              onTapUp:
                  widget.readOnly
                      ? null
                      : isMoveMode
                      ? _onMoveTap
                      : isWriteMode
                      ? _onWriteTap
                      : null,
              child: CustomPaint(
                painter: CanvasPainter(
                  pts: _pts,
                  lines: _lines,
                  labels: _labels,
                  textLabels: _textLabels,
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
                  activeTextLabel: _activeTextLabel,
                ),
                child: const SizedBox.expand(),
              ),
            );
          },
        ),
        if (_pts.isEmpty && _textLabels.isEmpty)
          Center(
            child: Text(
              widget.readOnly ? 'No Land Sketch' : 'Drag on canvas to start drawing',
              style: theme.textTheme.bodyLarge!.copyWith(color: theme.hintColor),
            ),
          ),
        if (!widget.readOnly)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(64)),
              child: SegmentedButton(
                segments: const [
                  ButtonSegment(value: SketchCanvasMode.draw, icon: Icon(Icons.edit_outlined), label: Text('Draw')),
                  ButtonSegment(value: SketchCanvasMode.move, icon: Icon(Icons.open_with), label: Text('Move')),
                  ButtonSegment(value: SketchCanvasMode.write, icon: Icon(Icons.text_fields_outlined), label: Text('Write')),
                ],
                selected: {_mode},
                onSelectionChanged:
                    (s) => setState(() {
                      _mode = s.first;
                      _dragStart = _dragEnd = null;
                      _sel.clear();
                      _activeTextLabel = null;
                      _movingTextLabelIdx = null;
                    }),
              ),
            ),
          ),

        if (!widget.readOnly)
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(64)),
              child: Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(tooltip: 'Undo', icon: const Icon(Icons.undo), onPressed: _history.isNotEmpty ? _undo : null),
                  IconButton(tooltip: 'Reset', icon: const Icon(Icons.restart_alt), onPressed: _reset),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
