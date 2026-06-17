// service_theme.dart
import 'package:flutter/material.dart';

class ServiceColors {
  static const primary = Color(0xFF2563EB); // 蓝色 - 主色调
  static const primaryLight = Color(0xFF3B82F6); // 浅蓝
  static const primaryDark = Color(0xFF1D4ED8); // 深蓝
  static const accent = Color(0xFFF59E0B); // 琥珀色 - 强调色
  static const accentLight = Color(0xFFFBBF24); // 浅琥珀
  static const success = Color(0xFF10B981); // 绿色
  static const warning = Color(0xFFF97316); // 橙色
  static const danger = Color(0xFFEF4444); // 红色

  // 背景色
  static const darkBg = Color(0xFF111827); // 深灰背景
  static const darkSurface = Color(0xFF1F2937); // 深卡片背景
  static const darkSurfaceElevated = Color(0xFF374151); // 更高层级卡片
  static const lightBg = Color(0xFFF9FAFB); // 浅灰背景
  static const lightSurface = Colors.white; // 白色卡片
  static const lightSurfaceElevated = Color(0xFFF3F4F6); // 浅灰卡片

  // 文字色
  static const darkText = Color(0xFFF9FAFB); // 白色文字
  static const darkTextSecondary = Color(0xFF9CA3AF); // 浅灰文字
  static const darkTextTertiary = Color(0xFF6B7280); // 深灰文字
  static const lightText = Color(0xFF111827); // 深灰文字
  static const lightTextSecondary = Color(0xFF6B7280); // 中灰文字
  static const lightTextTertiary = Color(0xFF9CA3AF); // 浅灰文字
}

// 兼容旧代码的别名
class ServiceMetalColors {
  static const primary = ServiceColors.primary;
  static const primaryLight = ServiceColors.primaryLight;
  static const primaryDark = ServiceColors.primaryDark;
  static const accent = ServiceColors.accent;
  static const accentLight = ServiceColors.accentLight;
  static const gold = ServiceColors.accent;
  static const silver = Color(0xFF9CA3AF);
  static const bronze = Color(0xFF92400E);
  static const darkBg = ServiceColors.darkBg;
  static const darkSurface = ServiceColors.darkSurface;
  static const darkSurfaceElevated = ServiceColors.darkSurfaceElevated;
  static const lightBg = ServiceColors.lightBg;
  static const lightSurface = ServiceColors.lightSurface;
  static const lightSurfaceElevated = ServiceColors.lightSurfaceElevated;
  static const darkText = ServiceColors.darkText;
  static const darkTextSecondary = ServiceColors.darkTextSecondary;
  static const darkTextTertiary = ServiceColors.darkTextTertiary;
  static const lightText = ServiceColors.lightText;
  static const lightTextSecondary = ServiceColors.lightTextSecondary;
  static const lightTextTertiary = ServiceColors.lightTextTertiary;
}

class ServiceTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: ServiceColors.darkBg,
    primaryColor: ServiceColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: ServiceColors.primary,
      secondary: ServiceColors.accent,
      surface: ServiceColors.darkSurface,
      error: ServiceColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ServiceColors.darkBg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ServiceColors.primary),
      titleTextStyle: TextStyle(
        color: ServiceColors.darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ServiceColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: ServiceColors.darkTextSecondary),
    ),
    cardTheme: CardTheme(
      color: ServiceColors.darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: ServiceColors.lightBg,
    primaryColor: ServiceColors.primary,
    colorScheme: const ColorScheme.light(
      primary: ServiceColors.primary,
      secondary: ServiceColors.accent,
      surface: ServiceColors.lightSurface,
      error: ServiceColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ServiceColors.lightBg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ServiceColors.primary),
      titleTextStyle: TextStyle(
        color: ServiceColors.lightText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ServiceColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: ServiceColors.lightTextSecondary),
    ),
    cardTheme: CardTheme(
      color: ServiceColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
