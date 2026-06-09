import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_shared.dart' as shared;
import 'settings_upgrade.dart';
import 'user_register.dart';
import 'user_auth.dart';

enum UpdateState { idle, checking, available, latest, updating, completed }

class SettingsPage extends StatefulWidget {
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const SettingsPage({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
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

    final updateMessages = <UpdateState, String>{
      UpdateState.idle: loc.updateIdle,
      UpdateState.checking: loc.updateChecking,
      UpdateState.available: loc.updateFound(_remoteVersion),
      UpdateState.latest: loc.updateLatest,
      UpdateState.updating: loc.updateInstalling,
      UpdateState.completed: loc.updateCompleted,
    };

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          _InfoCard(title: '用户账户', child: _buildUserAccountSection(isDark)),
          SizedBox(height: 40.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  loc.settingsTitle,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFE0E0E0) : null,
                  ),
                ),
              ),
              // 快速主题切换按钮
              Container(
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? const Color(0xFF2A2A3E)
                          : const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(30.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ThemeIconButton(
                      icon: Icons.light_mode,
                      label: 'Light',
                      isSelected: !isDark,
                      onTap: () => widget.onThemeModeChanged(ThemeMode.light),
                    ),
                    _ThemeIconButton(
                      icon: Icons.dark_mode,
                      label: 'Dark',
                      isSelected: isDark,
                      onTap: () => widget.onThemeModeChanged(ThemeMode.dark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            loc.settingsSubtitle,
            style: TextStyle(
              fontSize: 15.sp,
              color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF65748B),
            ),
          ),
          SizedBox(height: 24.h),

          // 主题设置卡片
          _InfoCard(title: '主题设置', child: _buildThemeSection(isDark)),
          SizedBox(height: 20.h),

          // 语言选择卡片
          _InfoCard(
            title: loc.languageSelection,
            child: DropdownButtonFormField<Locale>(
              value: widget.locale,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.w),
                ),
                fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
              ),
              style: TextStyle(color: isDark ? const Color(0xFFE0E0E0) : null),
              dropdownColor: isDark ? const Color(0xFF1E1E2E) : null,
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
                if (newLocale != null) widget.onLocaleChanged(newLocale);
              },
            ),
          ),
          SizedBox(height: 20.h),

          // 自动更新卡片
          _InfoCard(
            title: loc.autoUpdateTitle,
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

          // 版本信息卡片
          _InfoCard(
            title: loc.appVersion,
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

  // 主题设置部分
  Widget _buildThemeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 三种主题模式选择
        _buildThemeOption(
          icon: Icons.brightness_auto,
          title: '跟随系统',
          subtitle: '根据系统设置自动切换',
          isSelected: widget.themeMode == ThemeMode.system,
          onTap: () => widget.onThemeModeChanged(ThemeMode.system),
          isDark: isDark,
        ),
        SizedBox(height: 8.h),
        _buildThemeOption(
          icon: Icons.light_mode,
          title: '亮色模式',
          subtitle: '始终使用亮色主题',
          isSelected: widget.themeMode == ThemeMode.light,
          onTap: () => widget.onThemeModeChanged(ThemeMode.light),
          isDark: isDark,
        ),
        SizedBox(height: 8.h),
        _buildThemeOption(
          icon: Icons.dark_mode,
          title: '暗色模式',
          subtitle: '始终使用暗色主题',
          isSelected: widget.themeMode == ThemeMode.dark,
          onTap: () => widget.onThemeModeChanged(ThemeMode.dark),
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

  Widget _buildUserAccountSection(bool isDark) {
    if (userManager.isLoggedIn) {
      final user = userManager.currentUser!;
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF2A2A3E)
                            : const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(28.w),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 28,
                    color:
                        isDark
                            ? const Color(0xFF64B5F6)
                            : const Color(0xFF4338CA),
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
                              isDark
                                  ? const Color(0xFF9E9E9E)
                                  : Colors.grey[500],
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
                    color: isDark ? const Color(0xFFE0E0E0) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          ListTile(
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
}

// 快速主题切换按钮
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
