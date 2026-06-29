// admin_home.dart
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourism_in_norway/admin_orders.dart';
import 'app_shared.dart' as shared;
import 'admin_api.dart';
import 'admin_models.dart';
import 'admin_login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0; // 0: 仪表盘, 1: 用户, 2: 订单
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('zh');
  final String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final themeIndex = prefs.getInt('admin_theme');
      if (themeIndex != null) {
        _themeMode = ThemeMode.values[themeIndex];
      }
      final lang = prefs.getString('admin_lang');
      if (lang != null) {
        _locale = Locale(lang);
      }
    });
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('admin_theme', mode.index);
  }

  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_lang', locale.languageCode);
  }

  void _changeThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    _saveThemeMode(mode);
  }

  void _changeLocale(Locale locale) {
    setState(() => _locale = locale);
    _saveLocale(locale);
  }

  void _logout() {
    shared.UserManager().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      locale: _locale,
      supportedLocales: const [Locale('zh'), Locale('en'), Locale('no')],
      localizationsDelegates: [
        shared.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _themeMode,
      home: _buildAdminLayout(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0), space: 1),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3B82F6),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardColor: const Color(0xFF1E293B),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Color(0xFFF1F5F9),
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF334155), space: 1),
    );
  }

  Widget _buildAdminLayout() {
    final loc = shared.AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // 侧边栏
          _buildSidebar(loc, isDark),
          // 主内容区
          Expanded(
            child: Column(
              children: [
                _buildTopBar(loc, isDark),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    child: _buildContentPage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(shared.AppLocalizations loc, bool isDark) {
    final items = [
      _NavItem(
        Icons.dashboard_outlined,
        Icons.dashboard,
        loc.translate('admin_dashboard'),
        0,
      ),
      _NavItem(
        Icons.people_outline,
        Icons.people,
        loc.translate('admin_users'),
        1,
      ),
      _NavItem(
        Icons.shopping_bag_outlined,
        Icons.shopping_bag,
        loc.translate('admin_orders'),
        2,
      ),
    ];

    return Container(
      width: 260.w,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: EdgeInsets.all(24.w),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Icon(Icons.shield, color: Colors.white, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  loc.translate('admin_panel'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),

          // 导航菜单
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8.w, bottom: 12.h),
                  child: Text(
                    loc.translate('admin_menu'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                ...items.map((item) => _buildNavItem(item, isDark)),
              ],
            ),
          ),

          const Spacer(),

          // 退出登录
          Padding(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout, size: 18.sp),
                label: Text(loc.translate('admin_logout')),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  side: BorderSide(
                    color:
                        isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFFCBD5E1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool isDark) {
    final selected = _selectedIndex == item.index;
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = item.index),
          borderRadius: BorderRadius.circular(10.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color:
                  selected
                      ? const Color(0xFF3B82F6).withOpacity(isDark ? 0.15 : 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 22.sp,
                  color:
                      selected
                          ? const Color(0xFF3B82F6)
                          : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B)),
                ),
                SizedBox(width: 12.w),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        selected
                            ? const Color(0xFF3B82F6)
                            : (isDark
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(shared.AppLocalizations loc, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            _getPageTitle(loc),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const Spacer(),

          // 语言选择
          _buildLanguageSelector(loc, isDark),
          SizedBox(width: 12.w),

          // 主题切换
          IconButton(
            onPressed: () {
              final next =
                  _themeMode == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
              _changeThemeMode(next);
            },
            icon: Icon(
              _themeMode == ThemeMode.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
            ),
            tooltip: loc.translate('admin_theme'),
          ),
          SizedBox(width: 12.w),

          // 用户头像
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(30.w),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14.w,
                  backgroundColor: const Color(0xFF3B82F6),
                  child: Icon(Icons.person, color: Colors.white, size: 16.sp),
                ),
                SizedBox(width: 8.w),
                Text(
                  shared.UserManager().currentUser?.name ?? 'Admin',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(shared.AppLocalizations loc, bool isDark) {
    final languages = [
      const _LangOption('zh', '中文', '🇨🇳'),
      const _LangOption('en', 'English', '🇺🇸'),
      const _LangOption('no', 'Norsk', '🇳🇴'),
    ];

    return PopupMenuButton<String>(
      onSelected: (value) => _changeLocale(Locale(value)),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      itemBuilder:
          (context) =>
              languages.map((lang) {
                final selected = _locale.languageCode == lang.code;
                return PopupMenuItem<String>(
                  value: lang.code,
                  child: Row(
                    children: [
                      Text(lang.flag, style: TextStyle(fontSize: 16.sp)),
                      SizedBox(width: 10.w),
                      Text(
                        lang.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              selected
                                  ? const Color(0xFF3B82F6)
                                  : (isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B)),
                        ),
                      ),
                      if (selected) ...[
                        const Spacer(),
                        Icon(
                          Icons.check,
                          color: const Color(0xFF3B82F6),
                          size: 18.sp,
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              languages
                  .firstWhere(
                    (l) => l.code == _locale.languageCode,
                    orElse: () => languages[0],
                  )
                  .flag,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.arrow_drop_down,
              size: 18.sp,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(shared.AppLocalizations loc) {
    switch (_selectedIndex) {
      case 0:
        return loc.translate('admin_dashboard');
      case 1:
        return loc.translate('admin_users');
      case 2:
        return loc.translate('admin_orders');
      default:
        return '';
    }
  }

  Widget _buildContentPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardPage(
          key: ValueKey('dashboard_${_locale.languageCode}'),
        );
      case 1:
        return UsersManagementPage(
          key: ValueKey('users_${_locale.languageCode}'),
        );
      case 2:
        return AdminOrdersPage(key: ValueKey('orders_${_locale.languageCode}'));
      default:
        return const SizedBox.shrink();
    }
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  const _NavItem(this.icon, this.activeIcon, this.label, this.index);
}

class _LangOption {
  final String code;
  final String name;
  final String flag;

  const _LangOption(this.code, this.name, this.flag);
}

// ==================== 仪表盘页面 ====================
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final result = await AdminApi.getDashboardStats();
    if (mounted) {
      setState(() {
        _stats = result['data'] ?? {};
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = shared.AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final cards = [
      _StatCard(
        title: loc.translate('admin_total_users'),
        value: _formatNumber(_stats['total_users'] ?? 0),
        icon: Icons.people,
        gradient: const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
        isDark: isDark,
      ),
      _StatCard(
        title: loc.translate('admin_total_orders'),
        value: _formatNumber(_stats['total_orders'] ?? 0),
        icon: Icons.shopping_bag,
        gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
        isDark: isDark,
      ),
      _StatCard(
        title: loc.translate('admin_total_revenue'),
        value: '¥${(_stats['total_revenue'] ?? 0.0).toStringAsFixed(2)}',
        icon: Icons.attach_money,
        gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        isDark: isDark,
      ),
      _StatCard(
        title: loc.translate('admin_active_users'),
        value: _formatNumber(_stats['active_users'] ?? 0),
        icon: Icons.person,
        gradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        isDark: isDark,
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 欢迎信息
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: Row(
              children: [
                Icon(Icons.waving_hand, color: Colors.white, size: 36.sp),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${loc.translate('admin_welcome')}, ${shared.UserManager().currentUser?.name ?? 'Admin'}!',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        loc.translate('admin_welcome_desc'),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // 统计卡片
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280.w,
              childAspectRatio: 1.6,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) => cards[index],
          ),
          SizedBox(height: 32.h),

          // 快捷操作
          Text(
            loc.translate('admin_quick_actions'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16.w),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic n) {
    final int num = n is int ? n : (n as int?)?.toInt() ?? 0;
    if (num >= 10000) {
      return '${(num / 10000).toStringAsFixed(1)}w';
    }
    return num.toString();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Icon(icon, color: Colors.white, size: 24.sp),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 用户管理页面 ====================
class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  List<AdminUser> _users = [];
  int _total = 0;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final result = await AdminApi.getUsers(
      page: _currentPage,
      limit: _pageSize,
      keyword: _searchController.text,
    );

    if (mounted) {
      setState(() {
        final list = result['data']?['list'] as List? ?? [];
        _users = list.map((e) => AdminUser.fromJson(e)).toList();
        _total = result['data']?['total'] as int? ?? list.length;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = shared.AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // 搜索和操作栏
        _buildToolbar(loc, isDark),
        SizedBox(height: 20.h),

        // 表格
        Expanded(
          child:
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildUserTable(loc, isDark),
        ),

        // 分页
        if (!_loading) _buildPagination(loc, isDark),
      ],
    );
  }

  Widget _buildToolbar(shared.AppLocalizations loc, bool isDark) {
    return Row(
      children: [
        // 搜索框
        Expanded(
          child: SizedBox(
            width: 300.w,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc.translate('admin_search_user'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _currentPage = 1;
                            _loadUsers();
                          },
                        )
                        : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.w),
                  borderSide: BorderSide(
                    color:
                        isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.w),
                  borderSide: BorderSide(
                    color:
                        isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              onSubmitted: (_) {
                _currentPage = 1;
                _loadUsers();
              },
            ),
          ),
        ),
        SizedBox(width: 16.w),

        // 刷新按钮
        IconButton(
          onPressed: _loadUsers,
          icon: const Icon(Icons.refresh),
          style: IconButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            padding: EdgeInsets.all(12.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.w),
              side: BorderSide(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // 新增用户按钮
        ElevatedButton.icon(
          onPressed: () => _showUserDialog(loc),
          icon: const Icon(Icons.add),
          label: Text(loc.translate('admin_add_user')),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTable(shared.AppLocalizations loc, bool isDark) {
    final headers = [
      loc.translate('admin_id'),
      loc.translate('admin_user_name'),
      loc.translate('admin_email'),
      loc.translate('admin_phone'),
      loc.translate('admin_country'),
      loc.translate('admin_status'),
      loc.translate('admin_created'),
      loc.translate('admin_actions'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child:
          _users.isEmpty
              ? Center(
                child: Padding(
                  padding: EdgeInsets.all(60.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        loc.translate('admin_no_data'),
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
              : Column(
                children: [
                  // 表头
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? const Color(0xFF334155).withOpacity(0.5)
                              : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.w),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color:
                              isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    child: Row(
                      children:
                          headers.asMap().entries.map((entry) {
                            final flexValues = [1, 2, 3, 2, 2, 1, 2, 2];
                            return Expanded(
                              flex: flexValues[entry.key],
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                  // 表格内容
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children:
                            _users.asMap().entries.map((entry) {
                              final index = entry.key;
                              final user = entry.value;
                              return _buildUserRow(user, index, isDark, loc);
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildUserRow(
    AdminUser user,
    int index,
    bool isDark,
    shared.AppLocalizations loc,
  ) {
    final active = user.active ?? 1;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color:
            index.isEven
                ? Colors.transparent
                : (isDark
                    ? const Color(0xFF0F172A).withOpacity(0.3)
                    : const Color(0xFFF8FAFC)),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '${user.id}',
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14.w,
                  backgroundColor: const Color(0xFF3B82F6),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0] : '?',
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              user.email,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user.telephone ?? '-',
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user.country ?? '-',
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color:
                    active == 1
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.w),
              ),
              child: Text(
                active == 1
                    ? loc.translate('admin_active')
                    : loc.translate('admin_inactive'),
                style: TextStyle(
                  fontSize: 11.sp,
                  color:
                      active == 1
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user.createdAt != null ? _formatDate(user.createdAt!) : '-',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.white60 : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildActionButton(
                  Icons.edit_outlined,
                  Colors.blue,
                  () => _showUserDialog(loc, user: user),
                ),
                SizedBox(width: 6.w),
                _buildActionButton(
                  Icons.delete_outline,
                  Colors.red,
                  () => _confirmDelete(user, loc),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.w),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Icon(icon, size: 16.sp, color: color),
      ),
    );
  }

  Widget _buildPagination(shared.AppLocalizations loc, bool isDark) {
    final totalPages = (_total / _pageSize).ceil();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${loc.translate('admin_total')}: $_total',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          SizedBox(width: 24.w),
          IconButton(
            onPressed:
                _currentPage > 1
                    ? () {
                      setState(() => _currentPage--);
                      _loadUsers();
                    }
                    : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('$_currentPage / ${totalPages > 0 ? totalPages : 1}'),
          IconButton(
            onPressed:
                _currentPage < totalPages
                    ? () {
                      setState(() => _currentPage++);
                      _loadUsers();
                    }
                    : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Future<void> _showUserDialog(
    shared.AppLocalizations loc, {
    AdminUser? user,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _UserFormDialog(user: user),
    );

    if (result == true) {
      _loadUsers();
    }
  }

  Future<void> _confirmDelete(
    AdminUser user,
    shared.AppLocalizations loc,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(loc.translate('admin_confirm_delete')),
            content: Text(
              '${loc.translate('admin_delete_user_confirm')}: ${user.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(loc.translate('admin_cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(loc.translate('admin_delete')),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final result = await AdminApi.deleteUser(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['code'] == 200
                  ? loc.translate('admin_success')
                  : '${loc.translate('admin_failed')}: ${result['message']}',
            ),
          ),
        );
        _loadUsers();
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// ==================== 用户表单弹窗 ====================
class _UserFormDialog extends StatefulWidget {
  final AdminUser? user;

  const _UserFormDialog({this.user});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _countryController;
  late final TextEditingController _passwordController;
  late final TextEditingController _remarkController;
  int _active = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(
      text: widget.user?.telephone ?? '',
    );
    _countryController = TextEditingController(
      text: widget.user?.country ?? '',
    );
    _passwordController = TextEditingController();
    _remarkController = TextEditingController(text: widget.user?.remark ?? '');
    _active = widget.user?.active ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'telephone': _phoneController.text.trim(),
      'country': _countryController.text.trim(),
      'active': _active,
      'remark': _remarkController.text.trim(),
      if (_passwordController.text.isNotEmpty)
        'password': _passwordController.text,
    };

    Map<String, dynamic> result;
    if (widget.user != null) {
      result = await AdminApi.updateUser(widget.user!.id, data);
    } else {
      result = await AdminApi.createUser(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
