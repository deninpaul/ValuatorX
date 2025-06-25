import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

double get change => kIsWeb ? -1 : 0;

final globalTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  iconTheme: IconThemeData(size: 21 + change),
  iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(iconSize: 21 + change)),
  navigationRailTheme: NavigationRailThemeData(selectedIconTheme: IconThemeData(size: 21 + change), unselectedIconTheme: IconThemeData(size: 21 + change)),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedIconTheme: IconThemeData(size: 21 + change),
    unselectedIconTheme: IconThemeData(size: 21 + change),
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(fontSize: 17 + change),
    bodyLarge: TextStyle(fontSize: 15 + change),
    bodyMedium: TextStyle(fontSize: 13 + change),
    titleSmall: TextStyle(fontSize: 13 + change),
    labelLarge: TextStyle(fontSize: 13 + change),
    headlineMedium: TextStyle(fontSize: 21 + change),
  ),
);
