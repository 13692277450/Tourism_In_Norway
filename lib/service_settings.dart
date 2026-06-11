// service_settings.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'service_theme.dart' as theme;
import 'service_address.dart';
import 'service_like.dart';
import 'service_order.dart';

class ServiceSettings extends StatelessWidget {
  final ThemeMode themeMode;

  const ServiceSettings({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '信息中心',
          style: TextStyle(
            color:
                isDark
                    ? theme.ServiceMetalColors.primary
                    : theme.ServiceMetalColors.lightText,
          ),
        ),
      ),
      backgroundColor:
          isDark
              ? theme.ServiceMetalColors.darkBg
              : theme.ServiceMetalColors.lightBg,
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '游客用户',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('点击登录', style: TextStyle(fontSize: 13)),
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
                _buildMenuItem(
                  Icons.favorite_border,
                  '我的收藏',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ServiceLikePage()),
                  ),
                  isDark,
                ),
                _buildDivider(isDark),
                _buildMenuItem(
                  Icons.shopping_bag_outlined,
                  '我的订单',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ServiceOrderListPage(),
                    ),
                  ),
                  isDark,
                ),
                _buildDivider(isDark),
                _buildMenuItem(Icons.message_outlined, '消息通知', () {}, isDark),
                _buildDivider(isDark),
                _buildMenuItem(Icons.help_outline, '帮助中心', () {}, isDark),
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
