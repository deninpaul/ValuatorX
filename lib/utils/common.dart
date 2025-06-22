import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

final headerTheme = TextStyle(fontSize: 16);

defaultTransition(Color color, {SharedAxisTransitionType orientation = SharedAxisTransitionType.horizontal}) {
  return (child, animation, secondaryAnimation) => SharedAxisTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    transitionType: orientation,
    fillColor: color,
    child: child,
  );
}

String getExcelColumn(int num) {
  String column = '';
  while (num > 0) {
    int remainder = (num - 1) % 26;
    column = String.fromCharCode(65 + remainder) + column;
    num = (num - 1) ~/ 26;
  }
  return column;
}

bool isMobile(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width < 600;
}

bool isDesktop(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width > 1280;
}

EdgeInsets formPadding(context) => EdgeInsets.symmetric(
  horizontal:
      isMobile(context)
          ? 24
          : isDesktop(context)
          ? 240
          : 48,
  vertical: 32,
);
