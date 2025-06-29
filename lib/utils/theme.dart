import 'package:flutter/material.dart';

ThemeData globalTheme(context) {
  final colorScheme = Theme.of(context).colorScheme;
  double change(context) => 0;

  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    iconTheme: IconThemeData(size: 20 + change(context)),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(iconSize: 20 + change(context))),
    navigationRailTheme: NavigationRailThemeData(
      selectedIconTheme: IconThemeData(size: 20 + change(context)),
      unselectedIconTheme: IconThemeData(size: 20 + change(context)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(size: 20 + change(context)),
      unselectedIconTheme: IconThemeData(size: 20 + change(context)),
      selectedLabelStyle: TextStyle(fontSize: 13 + change(context)),
      unselectedLabelStyle: TextStyle(fontSize: 13 + change(context)),
    ),
    tabBarTheme: TabBarThemeData(
      unselectedLabelStyle: TextStyle(fontSize: 12 + change(context), fontWeight: FontWeight.w500),
      labelStyle: TextStyle(fontSize: 12 + change(context), fontWeight: FontWeight.w500),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(fontSize: 18 + change(context)),
      bodyLarge: TextStyle(fontSize: 15 + change(context)),
      bodyMedium: TextStyle(fontSize: 13 + change(context)),
      bodySmall: TextStyle(fontSize: 12 + change(context)),
      titleSmall: TextStyle(fontSize: 13 + change(context)),
      labelLarge: TextStyle(fontSize: 13 + change(context)),
      headlineMedium: TextStyle(fontSize: 21 + change(context)),
    ),
    dialogTheme: DialogThemeData(titleTextStyle: TextStyle(fontSize: 17 + change(context), color: colorScheme.onSurface)),
  );
}
