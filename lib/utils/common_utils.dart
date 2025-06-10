import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:valuatorx/modals/valuation.dart';

final headerTheme = TextStyle(fontSize: 19);

defaultTransition(Color color, {SharedAxisTransitionType orientation = SharedAxisTransitionType.horizontal}) {
  return (child, animation, secondaryAnimation) => SharedAxisTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    transitionType: orientation,
    fillColor: color,
    child: child,
  );
}

bool equal(Map a, Map b) {
  final Map aCopy = Map.of(a)..remove(Valuation.STATUS);
  final Map bCopy = Map.of(b)..remove(Valuation.STATUS);
  const eq = DeepCollectionEquality();
  return eq.equals(aCopy, bCopy);
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
