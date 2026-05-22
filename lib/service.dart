// service.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'service_home.dart';
import 'service_theme.dart';
import 'service_cart.dart';
import 'service_address.dart';

// 主题管理 Provider
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class ServiceApp extends StatelessWidget {
  const ServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: '霓虹商城',
                debugShowCheckedModeBanner: false,
                theme: themeProvider.isDarkMode ? ServiceTheme.darkTheme : ServiceTheme.lightTheme,
                home: const ServiceMainPage(),
                routes: {
                  '/home': (context) => const ServiceHomePage(),
                  '/cart': (context) => const ServiceCartPage(),
                  '/address': (context) => const ServiceAddressPage(),
                },
              );
            },
          );
        },
      ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark ? ServiceNeonColors.cyan.withOpacity(0.2) : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? ServiceNeonColors.darkSurface : Colors.white,
          selectedItemColor: ServiceNeonColors.cyan,
          unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shop_outlined),
              activeIcon: Icon(Icons.shop),
              label: '商城',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: '购物车',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                themeProvider.toggleTheme();
              },
              backgroundColor: isDark ? ServiceNeonColors.darkSurface : ServiceNeonColors.cyan,
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? ServiceNeonColors.cyan : Colors.white,
              ),
            )
          : null,
    );
  }
}

// 个人中心页面
class ServiceProfilePage extends StatelessWidget {
  const ServiceProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? ServiceNeonColors.darkBg : ServiceNeonColors.lightBg,
      appBar: AppBar(
        title: Text(
          '我的',
          style: TextStyle(color: isDark ? ServiceNeonColors.cyan : ServiceNeonColors.darkText),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // 用户头像区域
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDark ? ServiceNeonColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: isDark ? Border.all(color: ServiceNeonColors.cyan.withOpacity(0.3)) : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [ServiceNeonColors.cyan, ServiceNeonColors.magenta],
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
                          color: ServiceNeonColors.cyan,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: isDark ? Colors.grey[500] : Colors.grey[400]),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // 订单状态
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? ServiceNeonColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: isDark ? Border.all(color: ServiceNeonColors.cyan.withOpacity(0.3)) : null,
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
              color: isDark ? ServiceNeonColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: isDark ? Border.all(color: ServiceNeonColors.cyan.withOpacity(0.3)) : null,
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  Icons.location_on_outlined,
                  '收货地址管理',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ServiceAddressPage()),
                  ),
                  isDark,
                ),
                _buildDivider(isDark),
                _buildMenuItem(
                  Icons.favorite_border,
                  '我的收藏',
                  () {},
                  isDark,
                ),
                _buildDivider(isDark),
                _buildMenuItem(
                  Icons.message_outlined,
                  '消息通知',
                  () {},
                  isDark,
                ),
                _buildDivider(isDark),
                _buildMenuItem(
                  Icons.help_outline,
                  '帮助中心',
                  () {},
                  isDark,
                ),
                _buildDivider(isDark),
                _buildMenuItem(
                  Icons.dark_mode,
                  '深色模式',
                  () => themeProvider.toggleTheme(),
                  isDark,
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeColor: ServiceNeonColors.cyan,
                  ),
                ),
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
        Icon(icon, size: 28.sp, color: ServiceNeonColors.cyan),
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

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, bool isDark, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: ServiceNeonColors.cyan),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: isDark ? Colors.grey[500] : Colors.grey[400]),
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