import 'package:flutter/material.dart';

class TabItem {
  final String name;
  final String title;
  final Icon icon;
  final Icon selectedIcon;
  final String? createText;
  final VoidCallback? onCreate;
  final ValueChanged<String>? onSearch;
  final Widget child;

  const TabItem({
    required this.name,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    this.createText,
    this.onCreate,
    this.onSearch,
    required this.child,
  });
}