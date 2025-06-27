import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:valuatorx/utils/common.dart';

double change(context) => kIsWeb || isMobile(context) ? -1 : 0;

ThemeData globalTheme(context) => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  iconTheme: IconThemeData(size: 21 + change(context)),
  iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(iconSize: 21 + change(context))),
  navigationRailTheme: NavigationRailThemeData(
    selectedIconTheme: IconThemeData(size: 21 + change(context)),
    unselectedIconTheme: IconThemeData(size: 21 + change(context)),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedIconTheme: IconThemeData(size: 21 + change(context)),
    unselectedIconTheme: IconThemeData(size: 21 + change(context)),
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(fontSize: 17 + change(context)),
    bodyLarge: TextStyle(fontSize: 15 + change(context)),
    bodyMedium: TextStyle(fontSize: 13 + change(context)),
    titleSmall: TextStyle(fontSize: 13 + change(context)),
    labelLarge: TextStyle(fontSize: 13 + change(context)),
    headlineMedium: TextStyle(fontSize: 21 + change(context)),
  ),
);
