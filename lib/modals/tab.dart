import 'package:flutter/material.dart';

class TabItem {
  final String name;
  final String title;
  final Icon icon;
  final Icon selectedIcon;
  final String? createText;
  final Widget? createPage;
  final ValueChanged<String>? onSearch;
  final Widget child;

  const TabItem({
    required this.name,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    this.createText,
    this.createPage,
    this.onSearch,
    required this.child,
  });
}