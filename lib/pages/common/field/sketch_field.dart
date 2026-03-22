import 'package:flutter/material.dart';
import 'package:valuatorx/pages/common/sketch/sketch_canvas.dart';

class SketchField extends StatelessWidget {
  final TextEditingController controller;
  const SketchField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(border: Border.all(color: colorScheme.outline, width: 1), borderRadius: BorderRadius.circular(8)),
      child: SketchCanvas(value: controller.text, onChanged: (value) => controller.text = value),
    );
  }
}
