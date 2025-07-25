import 'package:flutter/material.dart';

class HorizontalTransition extends StatefulWidget {
  final bool visible;
  final bool reverse;
  final Duration duration;
  final Widget child;
  final bool destroyOnHide;

  const HorizontalTransition({
    super.key,
    required this.visible,
    this.reverse = false,
    this.destroyOnHide = false,
    this.duration = const Duration(milliseconds: 300),
    required this.child,
  });

  @override
  State<HorizontalTransition> createState() => _HorizontalTransitionState();
}

class _HorizontalTransitionState extends State<HorizontalTransition> {
  bool _shouldRender = false;
  bool _animatingIn = false;

  @override
  void initState() {
    super.initState();
    if (widget.visible) _shouldRender = true;
  }

  @override
  void didUpdateWidget(covariant HorizontalTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !_shouldRender) {
      setState(() {
        _shouldRender = true;
        _animatingIn = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _animatingIn = false);
      });
    }

    if (!widget.visible && _shouldRender && widget.destroyOnHide) {
      Future.delayed(widget.duration, () {
        if (mounted && !widget.visible) {
          setState(() => _shouldRender = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldRender) return const SizedBox.shrink();
    final direction = widget.reverse ? -1.0 : 1.0;
    final slideDistance = 16.0 / MediaQuery.of(context).size.width;
    final offset = widget.visible ? Offset.zero : Offset(slideDistance * direction, 0);
    final effectiveOffset = _animatingIn ? Offset(slideDistance * direction, 0) : offset;
    final effectiveOpacity = _animatingIn ? 0.0 : (widget.visible ? 1.0 : 0.0);

    return AnimatedSlide(
      offset: effectiveOffset,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: IgnorePointer(
        ignoring: !widget.visible,
        child: AnimatedOpacity(
          opacity: effectiveOpacity,
          duration: widget.duration - Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}
