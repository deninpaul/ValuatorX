import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

List baseMapLayers(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return [
    Container(color: colorScheme.surface),
    TileLayer(
      urlTemplate: 'https://api.maptiler.com/maps/bright-v2/{z}/{x}/{y}.png?key=cnscXQAGGIRCXm0KVoTo',
      userAgentPackageName: 'com.example.valuatorx',
      tileProvider: CancellableNetworkTileProvider(),
    ),
  ];
}

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
