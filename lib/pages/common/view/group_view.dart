import 'package:flutter/material.dart';

final double minWidth = 160;

class GroupViewWrapper extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final double spacing;
  final EdgeInsetsGeometry contentPadding;

  const GroupViewWrapper({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.contentPadding = const EdgeInsets.only(left: 32),
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.only(bottom: 18, right: 15),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        spacing: spacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 24),
            child: Row(spacing: 20, children: [Icon(icon), Text(title, style: textTheme.bodyLarge)]),
          ),
          ...children.map((child) => Padding(padding: contentPadding, child: child)),
        ],
      ),
    );
  }
}
