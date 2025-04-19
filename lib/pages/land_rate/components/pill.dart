import 'package:flutter/material.dart';

class Pill extends StatelessWidget {
  final Color color;
  const Pill({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        width: 32,
        height: 4,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
