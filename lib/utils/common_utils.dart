import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

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
