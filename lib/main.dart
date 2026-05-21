import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
import 'view.dart';
import 'bbs.dart';
import 'settings.dart';
import 'version_checker.dart';
import 'update_dialog.dart';
import 'service.dart';

import 'app_shared.dart' as shared;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class UpdateCheckWrapper extends StatefulWidget {
  final Widget child;

  const UpdateCheckWrapper({super.key, required this.child});

  @override
  State<UpdateCheckWrapper> createState() => _UpdateCheckWrapperState();
}

class _UpdateCheckWrapperState extends State<UpdateCheckWrapper> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      final versionInfo = await VersionChecker.checkForUpdate();
      if (versionInfo != null && mounted) {
        await showDialog(
          context: context,
          barrierDismissible: !versionInfo.isMandatory,
          builder: (context) => UpdateDialog(versionInfo: versionInfo),
        );
      }
    } catch (e) {
      throw Exception('版本检查失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return widget.child;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  int _selectedIndex = 0;
  ThemeMode _themeMode = ThemeMode.system; // 默认跟随系统

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode');
    if (themeIndex != null) {
      setState(() {
        _themeMode = ThemeMode.values[themeIndex];
      });
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    _saveThemeMode(mode);
  }

  // 亮色主题
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3D5AFE),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F6FF),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF1F6FF),
        foregroundColor: Color(0xFF1A1A2E),
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF6A78A4)),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF1A1A2E)),
        bodyMedium: TextStyle(color: Color(0xFF4B4B6B)),
      ),
      dividerColor: const Color(0xFFE0E0E0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.w),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    );
  }

  // 暗色主题
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3D5AFE),
        brightness: Brightness.dark,
        primary: const Color(0xFF64B5F6),
        secondary: const Color(0xFF81C784),
        surface: const Color(0xFF1E1E2E),
        background: const Color(0xFF121212),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E2E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: Color(0xFFE0E0E0),
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E2E),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF9E9E9E)),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(color: Color(0xFFB0B0B0)),
      ),
      dividerColor: const Color(0xFF333333),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A3E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.w),
          borderSide: const BorderSide(color: Color(0xFF444444)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Norway Travel',
          locale: _locale,
          supportedLocales: shared.AppLocalizations.supportedLocales,
          localizationsDelegates: [
            shared.AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: _themeMode,
          home: child,
        );
      },
      child: UpdateCheckWrapper(
        child: MainScreen(
          selectedIndex: _selectedIndex,
          onTabSelected: _changeTab,
          locale: _locale,
          onLocaleChanged: _changeLocale,
          themeMode: _themeMode,
          onThemeModeChanged: _changeThemeMode,
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const MainScreen({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.locale,
    required this.onLocaleChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  static final List<_NavItem> _navItems = [
    _NavItem(
      key: 'home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'HOME',
      activeColor: Color(0xFF3D5AFE),
      inactiveColor: Color(0xFF6A78A4),
    ),
    _NavItem(
      key: 'education',
      icon: Icons.remove_red_eye_outlined,
      activeIcon: Icons.remove_red_eye,
      label: 'EDUCATION',
      activeColor: Color(0xFF009688),
      inactiveColor: Color(0xFF6A78A4),
    ),
    _NavItem(
      key: 'bbs',
      icon: Icons.group_outlined,
      activeIcon: Icons.group,
      label: 'BBS',
      activeColor: Color(0xFF8E24AA),
      inactiveColor: Color(0xFF6A78A4),
    ),
    _NavItem(
      key: 'service',
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      label: 'SERVICE',
      activeColor: Color(0xFFF57C00),
      inactiveColor: Color(0xFF6A78A4),
    ),
    _NavItem(
      key: 'setting',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'SETTING',
      activeColor: Color(0xFF43A047),
      inactiveColor: Color(0xFF6A78A4),
    ),
  ];

  Widget _buildPage(BuildContext context) {
    switch (selectedIndex) {
      case 1:
        return const EducationPage();
      case 2:
        return const BbsPage();
      case 3:
        return const ServicePage();
      case 4:
        return SettingsPage(
          locale: locale,
          onLocaleChanged: onLocaleChanged,
          themeMode: themeMode,
          onThemeModeChanged: onThemeModeChanged,
        );
      case 0:
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = shared.AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景渐变 - 暗色模式下使用深色渐变
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF1A1A2E), const Color(0xFF121212)]
                    : [const Color(0xFFF1F6FF), const Color(0xFFFFFFFF)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 主题切换按钮（顶部）
                      // IconButton(
                      //   icon: Icon(
                      //     isDark ? Icons.light_mode : Icons.dark_mode,
                      //     color: isDark ? Colors.amber : const Color(0xFF6A78A4),
                      //   ),
                      //   onPressed: () {
                      //     onThemeModeChanged(
                      //       isDark ? ThemeMode.light : ThemeMode.dark,
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
                Expanded(child: _buildPage(context)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
        child: PhysicalModel(
          color: Colors.transparent,
          elevation: 3,
          borderRadius: BorderRadius.circular(32.w),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.circular(32.w),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
                  blurRadius: 6,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _navItems.map((item) {
                final selected = _navItems.indexOf(item) == selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabSelected(_navItems.indexOf(item)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? item.activeColor.withOpacity(isDark ? 0.20 : 0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.w),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? item.activeIcon : item.icon,
                            size: 26.r,
                            color: selected
                                ? item.activeColor
                                : (isDark
                                    ? const Color(0xFF9E9E9E)
                                    : item.inactiveColor),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            loc.translate(item.label),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? item.activeColor
                                  : (isDark
                                      ? const Color(0xFF9E9E9E)
                                      : item.inactiveColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String key;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color activeColor;
  final Color inactiveColor;

  const _NavItem({
    required this.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.activeColor,
    required this.inactiveColor,
  });
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final loc = shared.AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A64FE), Color(0xFF5E8BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.w),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.flight_takeoff,
              color: const Color(0xFF3D5AFE),
              size: 20.r,
            ),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                loc.appTagline,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
