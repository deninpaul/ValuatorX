import 'package:flutter/material.dart';

final globalTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  iconTheme: IconThemeData(size: 20),
  iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(iconSize: 20)),
  navigationRailTheme: NavigationRailThemeData(selectedIconTheme: IconThemeData(size: 20), unselectedIconTheme: IconThemeData(size: 20)),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedIconTheme: IconThemeData(size: 20),
    unselectedIconTheme: IconThemeData(size: 20),
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(fontSize: 16),
    bodyLarge: TextStyle(fontSize: 14),
    bodyMedium: TextStyle(fontSize: 12),
    titleSmall: TextStyle(fontSize: 12),
    labelLarge: TextStyle(fontSize: 13),
    headlineMedium: TextStyle(fontSize: 20),
  ),
);
