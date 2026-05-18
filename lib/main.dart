import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'home.dart';
import 'view.dart';
import 'bbs.dart';
import 'settings.dart';
import 'version_checker.dart';
import 'update_dialog.dart';
import 'service.dart';

import 'app_shared.dart' as shared;

void main() {
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
        // 使用 showDialog 显示更新提示
        await showDialog(
          context: context,
          barrierDismissible: !versionInfo.isMandatory,
          builder: (context) => UpdateDialog(versionInfo: versionInfo),
        );
      }
    } catch (e) {
      print('版本检查失败: $e');
    } finally {
      setState(() {
        _initialized = true;
      });
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
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3D5AFE),
              brightness: Brightness.light,
            ),
          ),
          home: child,
        );
      },
      child: UpdateCheckWrapper(
        child: MainScreen(
          selectedIndex: _selectedIndex,
          onTabSelected: _changeTab,
          locale: _locale,
          onLocaleChanged: _changeLocale,
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

  const MainScreen({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.locale,
    required this.onLocaleChanged,
  });

  static final List<_NavItem> _navItems = [
    _NavItem(
      key: 'home',
      icon: Icons.home_outlined,
      label: 'HOME',
      activeColor: Color(0xFF3D5AFE),
      inactiveColor: Color(0xFF6A78A4),
    ),
    _NavItem(
      key: 'education',
      icon: Icons.remove_red_eye_outlined,
      label: 'EDUCATION',
      activeColor: Color(0xFF009688),
      inactiveColor: Color(0xFF6A78A4),
    ),
    _NavItem(
      key: 'bbs',
      icon: Icons.group_outlined,
      label: 'BBS',
      activeColor: Color(0xFF8E24AA),
      inactiveColor: Color(0xFF6A78A4),
    ),
    _NavItem(
      key: 'service',
      icon: Icons.shopping_bag_outlined,
      label: 'SERVICE',
      activeColor: Color(0xFFF57C00),
      inactiveColor: Color(0xFF6A78A4),
    ),
    _NavItem(
      key: 'setting',
      icon: Icons.settings_outlined,
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
        );
      case 0:
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = shared.AppLocalizations.of(context);
    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF1F6FF), Color(0xFFFFFFFF)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HeaderCard(),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(32.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
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
                        color: selected ? item.activeColor.withOpacity(0.10) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20.w),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 26.r,
                            color: selected ? item.activeColor : item.inactiveColor,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            loc.translate(item.label),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: selected ? item.activeColor : item.inactiveColor,
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
  final String label;
  final Color activeColor;
  final Color inactiveColor;

  const _NavItem({
    required this.key,
    required this.icon,
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


