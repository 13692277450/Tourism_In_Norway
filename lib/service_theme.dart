// service_theme.dart
import 'package:flutter/material.dart';

class ServiceNeonColors {
  // 霓虹色彩
  static const cyan = Color(0xFF00D4FF);
  static const magenta = Color(0xFFFF2BD6);
  static const lime = Color(0xFFB9FF2B);
  static const amber = Color(0xFFFFC24A);
  static const purple = Color(0xFF9D4EDD);
  static const pink = Color(0xFFFF6B6B);
  
  // 背景色
  static const darkBg = Color(0xFF05060B);
  static const darkSurface = Color(0xFF0D0F19);
  static const lightBg = Color(0xFFF1F6FF);
  static const lightSurface = Colors.white;
  
  // 文字色
  static const darkText = Colors.white;
  static const darkTextSecondary = Color(0xFF8B8B9B);
  static const lightText = Color(0xFF1A1A2E);
  static const lightTextSecondary = Color(0xFF666666);
}

class ServiceTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: ServiceNeonColors.darkBg,
    primaryColor: ServiceNeonColors.cyan,
    colorScheme: const ColorScheme.dark(
      primary: ServiceNeonColors.cyan,
      secondary: ServiceNeonColors.magenta,
      surface: ServiceNeonColors.darkSurface,
      error: Colors.redAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ServiceNeonColors.darkBg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ServiceNeonColors.cyan),
      titleTextStyle: TextStyle(
        color: ServiceNeonColors.cyan,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ServiceNeonColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: ServiceNeonColors.darkTextSecondary),
    ),
    cardTheme: CardTheme(
      color: ServiceNeonColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ServiceNeonColors.cyan.withOpacity(0.3)),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: ServiceNeonColors.lightBg,
    primaryColor: ServiceNeonColors.cyan,
    colorScheme: const ColorScheme.light(
      primary: ServiceNeonColors.cyan,
      secondary: ServiceNeonColors.magenta,
      surface: ServiceNeonColors.lightSurface,
      error: Colors.redAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ServiceNeonColors.lightBg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ServiceNeonColors.cyan),
      titleTextStyle: TextStyle(
        color: ServiceNeonColors.darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ServiceNeonColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: ServiceNeonColors.lightTextSecondary),
    ),
    cardTheme: CardTheme(
      color: ServiceNeonColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}