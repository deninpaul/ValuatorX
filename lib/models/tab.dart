import 'package:flutter/material.dart';

class TabItem {
  final String name;
  final String title;
  final Icon icon;
  final Icon selectedIcon;
  final Widget child;

  const TabItem({
    required this.name,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.child,
  });
}