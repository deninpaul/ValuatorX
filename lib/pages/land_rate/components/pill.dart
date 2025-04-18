import 'package:flutter/material.dart';

class Pill extends StatelessWidget {
  final Color color;
  const Pill({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Container(
        width: 48,
        height: 4,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
