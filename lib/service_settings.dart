// service.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'service_theme.dart' as theme;
import 'service_address.dart';

// class ServiceSettings extends StatelessWidget {
//   final ThemeMode themeMode;

//   const ServiceSettings({super.key, required this.themeMode});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(
//             size: 24.sp,
//             Icons.arrow_back_ios_new_rounded,
//             color:
//                 isDark
//                     ? theme.ServiceMetalColors.primary
//                     : theme.ServiceMetalColors.lightText,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       backgroundColor:
//           isDark
//               ? theme.ServiceMetalColors.darkBg
//               : theme.ServiceMetalColors.lightBg,
//       body: ListView(
//         padding: EdgeInsets.all(16.w),
//         children: [
//           // 主题切换
//           Container(
//             padding: EdgeInsets.all(16.w),
//             decoration: BoxDecoration(
//               color:
//                   isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
//               borderRadius: BorderRadius.circular(16.r),
//               border:
//                   isDark
//                       ? Border.all(
//                         color: theme.ServiceMetalColors.primary.withOpacity(
//                           0.3,
//                         ),
//                       )
//                       : null,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [],
//             ),
//           ),
//           SizedBox(height: 16.h),
//           // 其他设置项
//           Container(
//             decoration: BoxDecoration(
//               color:
//                   isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
//               borderRadius: BorderRadius.circular(16.r),
//               border:
//                   isDark
//                       ? Border.all(
//                         color: theme.ServiceMetalColors.primary.withOpacity(
//                           0.3,
//                         ),
//                       )
//                       : null,
//             ),
//             child: Column(
//               children: [
//                 _buildSettingsItem(
//                   Icons.account_circle_outlined,
//                   '账号管理',
//                   () {},
//                   isDark,
//                 ),
//                 _buildDivider(isDark),
//                 _buildSettingsItem(
//                   Icons.notifications_outlined,
//                   '通知设置',
//                   () {},
//                   isDark,
//                 ),
//                 _buildDivider(isDark),
//                 _buildSettingsItem(
//                   Icons.security_outlined,
//                   '隐私设置',
//                   () {},
//                   isDark,
//                 ),
//                 _buildDivider(isDark),
//                 _buildSettingsItem(Icons.info_outline, '关于我们', () {}, isDark),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettingsItem(
//     IconData icon,
//     String title,
//     VoidCallback onTap,
//     bool isDark,
//   ) {
//     return ListTile(
//       leading: Icon(icon, color: theme.ServiceMetalColors.primary),
//       title: Text(
//         title,
//         style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//       ),
//       trailing: Icon(
//         Icons.chevron_right,
//         color: isDark ? Colors.grey[500] : Colors.grey[400],
//       ),
//       onTap: onTap,
//     );
//   }

//   Widget _buildDivider(bool isDark) {
//     return Divider(
//       height: 1,
//       color: isDark ? Colors.grey[800] : Colors.grey[200],
//     );
//   }
// }

class ServiceSettings extends StatelessWidget {
  final ThemeMode themeMode;

  const ServiceSettings({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '设置',
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
          // 主题切换
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '深色模式',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Switch(
                  value: isDark,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(value ? '已切换到深色模式' : '已切换到浅色模式')),
                    );
                  },
                  activeColor: theme.ServiceMetalColors.primary,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // 其他设置项
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
                _buildSettingsItem(
                  Icons.account_circle_outlined,
                  '账号管理',
                  () {},
                  isDark,
                ),
                _buildDivider(isDark),
                _buildSettingsItem(
                  Icons.notifications_outlined,
                  '通知设置',
                  () {},
                  isDark,
                ),
                _buildDivider(isDark),
                _buildSettingsItem(
                  Icons.security_outlined,
                  '隐私设置',
                  () {},
                  isDark,
                ),
                _buildDivider(isDark),
                _buildSettingsItem(Icons.info_outline, '关于我们', () {}, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ListTile(
      leading: Icon(icon, color: theme.ServiceMetalColors.primary),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      trailing: Icon(
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
