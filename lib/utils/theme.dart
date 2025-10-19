import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData theme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    iconTheme: IconThemeData(size: 21),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(iconSize: 21)),
    navigationRailTheme: NavigationRailThemeData(selectedIconTheme: IconThemeData(size: 21), unselectedIconTheme: IconThemeData(size: 21)),
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: colorScheme.surfaceContainer,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: colorScheme.surfaceContainer,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(size: 21),
      unselectedIconTheme: IconThemeData(size: 21),
      selectedLabelStyle: TextStyle(fontSize: 13),
      unselectedLabelStyle: TextStyle(fontSize: 13),
    ),
    tabBarTheme: TabBarThemeData(
      unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(fontSize: 18),
      bodyLarge: TextStyle(fontSize: 15),
      bodyMedium: TextStyle(fontSize: 13),
      bodySmall: TextStyle(fontSize: 12),
      titleSmall: TextStyle(fontSize: 13),
      labelLarge: TextStyle(fontSize: 13),
      headlineMedium: TextStyle(fontSize: 21),
    ),
    dialogTheme: DialogThemeData(titleTextStyle: TextStyle(fontSize: 17, color: colorScheme.onSurface)),
  );
}
