// settings_home.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourism_in_norway/admin_login.dart';

import 'app_shared.dart' as shared;
import 'settings_upgrade.dart';
import 'user_register.dart';
import 'user_auth.dart';
import 'service_address.dart';
import 'service_like.dart';
import 'settings_orders.dart' as settings_orders;

enum UpdateState { idle, checking, available, latest, updating, completed }

class SettingsPage extends StatefulWidget {
  final Locale? locale;
  final ValueChanged<Locale>? onLocaleChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  const SettingsPage({
    super.key,
    this.locale,
    this.onLocaleChanged,
    required this.themeMode,
    this.onThemeModeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoUpdate = true;
  UpdateState _updateState = UpdateState.idle;
  final String _remoteVersion = '2.1.0';

  final userManager = shared.UserManager();

  Future<void> _checkForUpdates() async {
    setState(() => _updateState = UpdateState.checking);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _updateState = UpdateState.available);

    if (_autoUpdate) {
      await _performAutoUpdate();
    }
  }

  Future<void> _performAutoUpdate() async {
    setState(() => _updateState = UpdateState.updating);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _updateState = UpdateState.completed);
  }

  @override
  Widget build(BuildContext context) {
    final loc = shared.AppLocalizations.of(context);
    final locales = shared.AppLocalizations.supportedLocales;
    final localeNames = shared.AppLocalizations.languageNames;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 获取当前语言
    final currentLocale = widget.locale ?? Localizations.localeOf(context);

    final updateMessages = <UpdateState, String>{
      UpdateState.idle: loc.updateIdle,
      UpdateState.checking: loc.updateChecking,
      UpdateState.available: loc.updateFound(_remoteVersion),
      UpdateState.latest: loc.updateLatest,
      UpdateState.updating: loc.updateInstalling,
      UpdateState.completed: loc.updateCompleted,
    };

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),

          // ==================== 用户账户区域 ====================
          _InfoCard(title: '👤 用户账户', child: _buildUserAccountSection(isDark)),
          SizedBox(height: 20.h),

          // ==================== 我的订单 ====================
          _InfoCard(
            title: '📦 我的订单',
            child: _buildOrderStatusSection(context, isDark),
          ),
          SizedBox(height: 20.h),

          // ==================== 功能列表 ====================
          _InfoCard(
            title: '🛠️ 功能服务',
            child: _buildFunctionList(context, isDark),
          ),
          SizedBox(height: 20.h),

          // ==================== 主题设置 ====================
          _InfoCard(title: '🎨 主题设置', child: _buildThemeSection(isDark)),
          SizedBox(height: 20.h),

          // ==================== 语言选择 ====================
          _InfoCard(
            title: '🌐 语言选择',
            child: DropdownButtonFormField<Locale>(
              value: currentLocale,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.w),
                ),
                fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
              ),
              style: TextStyle(
                color: isDark ? const Color(0xFFE0E0E0) : Colors.black87,
              ),
              dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              items:
                  locales
                      .map(
                        (locale) => DropdownMenuItem<Locale>(
                          value: locale,
                          child: Text(
                            localeNames[locale.languageCode] ??
                                locale.languageCode,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                final newLocale = value;
                if (newLocale != null) {
                  if (widget.onLocaleChanged != null) {
                    widget.onLocaleChanged!(newLocale);
                  }
                }
              },
            ),
          ),
          SizedBox(height: 20.h),

          // ==================== 自动更新 ====================
          _InfoCard(
            title: '🔄 自动更新',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    loc.autoUpdateLabel,
                    style: TextStyle(
                      color: isDark ? const Color(0xFFE0E0E0) : null,
                    ),
                  ),
                  value: _autoUpdate,
                  activeColor: const Color(0xFF3D5AFE),
                  onChanged: (value) => setState(() => _autoUpdate = value),
                ),
                Divider(
                  height: 1,
                  color: isDark ? const Color(0xFF333333) : null,
                ),
                ListTile(
                  title: Text(
                    loc.updateStatusLabel,
                    style: TextStyle(
                      color: isDark ? const Color(0xFFE0E0E0) : null,
                    ),
                  ),
                  subtitle: Text(
                    updateMessages[_updateState]!,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF9E9E9E) : null,
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Upgrade(),
                          maintainState: false,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D5AFE),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(loc.checkUpdateButton),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          // ==================== ADMINADMIN ====================
          _InfoCard(
            title: 'Admin Settings',
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  // 打开登录页
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D5AFE),
                foregroundColor: Colors.white,
              ),
              child: Text('Admin Login'),
            ),
          ),
          SizedBox(height: 20.h),
          // ==================== 版本信息 ====================
          _InfoCard(
            title: '📱 版本信息',
            child: Column(
              children: [
                _settingLine(loc.currentVersion, '1.0.0', isDark),
                _settingLine(loc.latestVersion, _remoteVersion, isDark),
                _settingLine(loc.compatibility, loc.compatibilityValue, isDark),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // ==================== 用户账户区域 ====================
  Widget _buildUserAccountSection(bool isDark) {
    if (userManager.isLoggedIn) {
      final user = userManager.currentUser!;
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28.w),
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFE0E0E0) : null,
                    ),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                          isDark ? const Color(0xFF9E9E9E) : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                userManager.logout();
                setState(() {});
              },
              icon: Icon(
                Icons.logout,
                color: isDark ? const Color(0xFFE0E0E0) : Colors.redAccent,
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          ListTile(
            leading: Icon(Icons.login, color: const Color(0xFF3D5AFE)),
            title: Text(
              '登录',
              style: TextStyle(color: isDark ? const Color(0xFFE0E0E0) : null),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: isDark ? const Color(0xFF9E9E9E) : null,
              size: 16,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              ).then((_) => setState(() {}));
            },
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF333333) : null),
          ListTile(
            leading: Icon(
              Icons.app_registration,
              color: const Color(0xFF3D5AFE),
            ),
            title: Text(
              '注册',
              style: TextStyle(color: isDark ? const Color(0xFFE0E0E0) : null),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: isDark ? const Color(0xFF9E9E9E) : null,
              size: 16,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      );
    }
  }

  // ==================== 订单状态区域 ====================
  Widget _buildOrderStatusSection(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildOrderStatusItem(
          context: context,
          icon: Icons.payment,
          label: '待付款',
          count: '3',
          color: const Color(0xFFFF6B35),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => const settings_orders.ServiceOrderListPage(
                      initialTab: 0,
                      title: '待付款',
                    ),
              ),
            );
          },
          isDark: isDark,
        ),
        _buildOrderStatusItem(
          context: context,
          icon: Icons.local_shipping,
          label: '待发货',
          count: '2',
          color: const Color(0xFF3D5AFE),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => const settings_orders.ServiceOrderListPage(
                      initialTab: 1,
                      title: '待发货',
                    ),
              ),
            );
          },
          isDark: isDark,
        ),
        _buildOrderStatusItem(
          context: context,
          icon: Icons.inbox,
          label: '待收货',
          count: '1',
          color: const Color(0xFF00C853),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => const settings_orders.ServiceOrderListPage(
                      initialTab: 2,
                      title: '待收货',
                    ),
              ),
            );
          },
          isDark: isDark,
        ),
        _buildOrderStatusItem(
          context: context,
          icon: Icons.rate_review,
          label: '待评价',
          count: '4',
          color: const Color(0xFFFFD600),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => const settings_orders.ServiceOrderListPage(
                      initialTab: 3,
                      title: '待评价',
                    ),
              ),
            );
          },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildOrderStatusItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String count,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24.sp, color: color),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 功能列表 ====================
  Widget _buildFunctionList(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildMenuItem(
          context: context,
          icon: Icons.location_on_outlined,
          title: '收货地址管理',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServiceAddressPage()),
              ),
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildMenuItem(
          context: context,
          icon: Icons.favorite_border,
          title: '我的收藏',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServiceLikePage()),
              ),
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildMenuItem(
          context: context,
          icon: Icons.shopping_bag_outlined,
          title: '我的订单',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => const settings_orders.ServiceOrderListPage(
                        initialTab: 0,
                        title: '我的订单',
                      ),
                ),
              ),
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildMenuItem(
          context: context,
          icon: Icons.message_outlined,
          title: '消息通知',
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('消息通知功能开发中')));
          },
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildMenuItem(
          context: context,
          icon: Icons.help_outline,
          title: '帮助中心',
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('帮助中心功能开发中')));
          },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3D5AFE)),
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

  // ==================== 主题设置 ====================
  Widget _buildThemeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildThemeOption(
          icon: Icons.brightness_auto,
          title: '跟随系统',
          subtitle: '根据系统设置自动切换',
          isSelected: widget.themeMode == ThemeMode.system,
          onTap: () {
            if (widget.onThemeModeChanged != null) {
              widget.onThemeModeChanged!(ThemeMode.system);
            }
          },
          isDark: isDark,
        ),
        SizedBox(height: 8.h),
        _buildThemeOption(
          icon: Icons.light_mode,
          title: '亮色模式',
          subtitle: '始终使用亮色主题',
          isSelected: widget.themeMode == ThemeMode.light,
          onTap: () {
            if (widget.onThemeModeChanged != null) {
              widget.onThemeModeChanged!(ThemeMode.light);
            }
          },
          isDark: isDark,
        ),
        SizedBox(height: 8.h),
        _buildThemeOption(
          icon: Icons.dark_mode,
          title: '暗色模式',
          subtitle: '始终使用暗色主题',
          isSelected: widget.themeMode == ThemeMode.dark,
          onTap: () {
            if (widget.onThemeModeChanged != null) {
              widget.onThemeModeChanged!(ThemeMode.dark);
            }
          },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (isDark
                      ? const Color(0xFF3D5AFE).withOpacity(0.2)
                      : const Color(0xFFE0E7FF))
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFF3D5AFE)
                    : (isDark
                        ? const Color(0xFF444444)
                        : const Color(0xFFE0E0E0)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? const Color(0xFF3D5AFE)
                      : (isDark
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF6A78A4)),
              size: 24.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? const Color(0xFF3D5AFE)
                              : (isDark
                                  ? const Color(0xFFE0E0E0)
                                  : const Color(0xFF1A1A2E)),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color:
                          isDark
                              ? const Color(0xFF9E9E9E)
                              : const Color(0xFF6A78A4),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF3D5AFE),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _settingLine(String title, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? const Color(0xFFE0E0E0) : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF4B4B6B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== InfoCard 组件 ====================
class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(22.w),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
            blurRadius: 18,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFE0E0E0) : null,
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

// ==================== 快捷主题切换按钮 ====================
class _ThemeIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeIconButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3D5AFE) : Colors.transparent,
          borderRadius: BorderRadius.circular(30.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18.r,
              color:
                  isSelected
                      ? Colors.white
                      : (isDark
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF6A78A4)),
            ),
            if (isSelected) SizedBox(width: 4.w),
            if (isSelected)
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<bool> checkGooglePlayUpdate() async {
  return false;
}
