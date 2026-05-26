// service_theme.dart
import 'package:flutter/material.dart';

class ServiceMetalColors {
  // 现代化金属风格色彩
  static const primary = Color(0xFF4F46E5);       // 靛蓝紫色 - 主色调
  static const primaryLight = Color(0xFF6366F1);  // 浅靛蓝
  static const primaryDark = Color(0xFF3730A3);   // 深靛蓝
  static const accent = Color(0xFF0EA5E9);        // 天蓝色 - 强调色
  static const accentLight = Color(0xFF38BDF8);   // 浅天蓝
  static const gold = Color(0xFFD4AF37);          // 金色 - 点缀色
  static const silver = Color(0xFFC0C0C0);        // 银色
  static const bronze = Color(0xFFCD7F32);        // 青铜色
  
  // 背景色
  static const darkBg = Color(0xFF0F172A);        // 深蓝灰背景
  static const darkSurface = Color(0xFF1E293B);   // 深卡片背景
  static const darkSurfaceElevated = Color(0xFF334155); // 更高层级卡片
  static const lightBg = Color(0xFFF8FAFC);       // 浅灰背景
  static const lightSurface = Colors.white;       // 白色卡片
  static const lightSurfaceElevated = Color(0xFFF1F5F9); // 浅灰卡片
  
  // 文字色
  static const darkText = Color(0xFFFFFFFF);      // 白色文字
  static const darkTextSecondary = Color(0xFF94A3B8); // 浅灰文字
  static const darkTextTertiary = Color(0xFF64748B);  // 深灰文字
  static const lightText = Color(0xFF1E293B);     // 深灰文字
  static const lightTextSecondary = Color(0xFF64748B); // 中灰文字
  static const lightTextTertiary = Color(0xFF94A3B8);  // 浅灰文字
}

class ServiceTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: ServiceMetalColors.darkBg,
    primaryColor: ServiceMetalColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: ServiceMetalColors.primary,
      secondary: ServiceMetalColors.accent,
      surface: ServiceMetalColors.darkSurface,
      error: Colors.redAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ServiceMetalColors.darkBg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ServiceMetalColors.primary),
      titleTextStyle: TextStyle(
        color: ServiceMetalColors.darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ServiceMetalColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: ServiceMetalColors.darkTextSecondary),
    ),
    cardTheme: CardTheme(
      color: ServiceMetalColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ServiceMetalColors.primary.withOpacity(0.3)),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: ServiceMetalColors.lightBg,
    primaryColor: ServiceMetalColors.primary,
    colorScheme: const ColorScheme.light(
      primary: ServiceMetalColors.primary,
      secondary: ServiceMetalColors.accent,
      surface: ServiceMetalColors.lightSurface,
      error: Colors.redAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ServiceMetalColors.lightBg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ServiceMetalColors.primary),
      titleTextStyle: TextStyle(
        color: ServiceMetalColors.lightText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ServiceMetalColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: ServiceMetalColors.lightTextSecondary),
    ),
    cardTheme: CardTheme(
      color: ServiceMetalColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}