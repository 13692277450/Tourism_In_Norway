// service.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'service_home.dart';
import 'service_theme.dart' as theme;
import 'service_cart.dart';
import 'service_address.dart';

class ServiceSettings extends StatelessWidget {
  final ThemeMode themeMode;

  const ServiceSettings({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    // 从主应用获取主题状态
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Norway Service',
          debugShowCheckedModeBanner: false,
          theme:
              isDarkMode
                  ? theme.ServiceTheme.darkTheme
                  : theme.ServiceTheme.lightTheme,
          home: const ServiceMainPage(),
          routes: {
            '/home': (context) => const ServiceHomePage(),
            '/cart': (context) => const ServiceCartPage(),
            '/address': (context) => const ServiceAddressPage(),
          },
        );
      },
    );
  }
}

class ServiceMainPage extends StatefulWidget {
  const ServiceMainPage({super.key});

  @override
  State<ServiceMainPage> createState() => _ServiceMainPageState();
}

class _ServiceMainPageState extends State<ServiceMainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const ServiceHomePage(),
    const ServiceCartPage(),
    const ServiceProfilePage(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.shop_outlined, 'activeIcon': Icons.shop, 'label': '商城'},
    {
      'icon': Icons.shopping_cart_outlined,
      'activeIcon': Icons.shopping_cart,
      'label': '购物车',
    },
    {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': '我的'},
  ];

  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
      _isMenuOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _pages[_currentIndex],
      // 主悬浮按钮 - 点击弹出菜单
      floatingActionButton: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 弹出菜单按钮
          if (_isMenuOpen)
            ..._navItems.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return Positioned(
                bottom: 80.h + (2 - index) * 70.h,
                right: 20.w,
                child: AnimatedOpacity(
                  opacity: _isMenuOpen ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedScale(
                    scale: _isMenuOpen ? 1 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: FloatingActionButton(
                      heroTag: 'nav_$index',
                      onPressed: () => _navigateToPage(index),
                      backgroundColor:
                          isDark
                              ? theme.ServiceMetalColors.darkSurface
                              : Colors.yellow.shade200,
                      foregroundColor:
                          isDark
                              ? theme.ServiceMetalColors.primary
                              : theme.ServiceMetalColors.lightText,
                      elevation: 8,
                      child: Icon(item['icon']),
                    ),
                  ),
                ),
              );
            }),
          // 主题切换按钮（首页显示）
          if (_currentIndex == 0)
            // Positioned(
            //   right: 0,
            //   bottom: 0,
            //   child: FloatingActionButton(
            //     heroTag: 'theme',
            //     onPressed: () => themeProvider.toggleTheme(),
            //     backgroundColor: theme.ServiceMetalColors.primary,
            //     foregroundColor: Colors.white,
            //     elevation: 8,
            //     child: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            //   ),
            // ),
            // 主菜单按钮
            Positioned(
              left: 20.w,
              bottom: 0,
              child: FloatingActionButton(
                heroTag: 'menu',
                onPressed: _toggleMenu,
                backgroundColor: theme.ServiceMetalColors.accent,
                foregroundColor: Colors.white,
                elevation: 8,
                child: AnimatedRotation(
                  turns: _isMenuOpen ? 0.25 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.menu),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 个人中心页面
class ServiceProfilePage extends StatelessWidget {
  const ServiceProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? theme.ServiceMetalColors.darkBg
              : theme.ServiceMetalColors.lightBg,
      appBar: AppBar(
        title: Text(
          '我的',
          style: TextStyle(
            color:
                isDark
                    ? theme.ServiceMetalColors.primary
                    : theme.ServiceMetalColors.lightText,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // 用户头像区域
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color:
                  isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border:
                  isDark
                      ? Border.all(
                        color: theme.ServiceMetalColors.primary.withOpacity(
                          0.3,
                        ),
                      )
                      : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        theme.ServiceMetalColors.primary,
                        theme.ServiceMetalColors.accent,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 30, color: Colors.black),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '游客用户',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '点击登录',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: theme.ServiceMetalColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // 订单状态
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color:
                  isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border:
                  isDark
                      ? Border.all(
                        color: theme.ServiceMetalColors.primary.withOpacity(
                          0.3,
                        ),
                      )
                      : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '我的订单',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOrderStatusItem(Icons.payment, '待付款', isDark),
                    _buildOrderStatusItem(Icons.local_shipping, '待发货', isDark),
                    _buildOrderStatusItem(Icons.inbox, '待收货', isDark),
                    _buildOrderStatusItem(Icons.rate_review, '待评价', isDark),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // 功能列表
          Container(
            decoration: BoxDecoration(
              color:
                  isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border:
                  isDark
                      ? Border.all(
                        color: theme.ServiceMetalColors.primary.withOpacity(
                          0.3,
                        ),
                      )
                      : null,
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  Icons.location_on_outlined,
                  '收货地址管理',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ServiceAddressPage(),
                    ),
                  ),
                  isDark,
                ),
                _buildDivider(isDark),
                _buildMenuItem(Icons.favorite_border, '我的收藏', () {}, isDark),
                _buildDivider(isDark),
                _buildMenuItem(Icons.message_outlined, '消息通知', () {}, isDark),
                _buildDivider(isDark),
                _buildMenuItem(Icons.help_outline, '帮助中心', () {}, isDark),
                _buildDivider(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem(IconData icon, String label, bool isDark) {
    return Column(
      children: [
        Icon(icon, size: 28.sp, color: theme.ServiceMetalColors.primary),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap,
    bool isDark, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.ServiceMetalColors.primary),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }
}
