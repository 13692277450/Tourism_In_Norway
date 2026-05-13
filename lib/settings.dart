import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_shared.dart' as shared;
import 'upgrade.dart';
import 'register.dart';
import 'auth.dart';

enum UpdateState { idle, checking, available, latest, updating, completed }

class SettingsPage extends StatefulWidget {
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  const SettingsPage({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoUpdate = true;
  UpdateState _updateState = UpdateState.idle;
  final String _remoteVersion = '2.1.0';
  
  final UserManager = shared.UserManager();

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
          _InfoCard(
            title: '用户账户',
            child: _buildUserAccountSection(),
          ),
          SizedBox(height: 40.h),
          Text(
            loc.settingsTitle,
            style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Text(
            loc.settingsSubtitle,
            style: TextStyle(fontSize: 15.sp, color: const Color(0xFF65748B)),
          ),
          SizedBox(height: 24.h),
          _InfoCard(
            title: loc.languageSelection,
            child: DropdownButtonFormField<Locale>(
              value: widget.locale,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.w),
                ),
              ),
              items: locales
                  .map(
                    (locale) => DropdownMenuItem<Locale>(
                      value: locale,
                      child: Text(
                        localeNames[locale.languageCode] ?? locale.languageCode,
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
          _InfoCard(
            title: loc.autoUpdateTitle,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(loc.autoUpdateLabel),
                  value: _autoUpdate,
                  onChanged: (value) => setState(() => _autoUpdate = value),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(loc.updateStatusLabel),
                  subtitle: Text(updateMessages[_updateState]!),
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
                    child: Text(loc.checkUpdateButton),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _InfoCard(
            title: loc.appVersion,
            child: Column(
              children: [
                _settingLine(loc.currentVersion, '1.0.0'),
                _settingLine(loc.latestVersion, _remoteVersion),
                _settingLine(loc.compatibility, loc.compatibilityValue),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _settingLine(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 14.sp)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF4B4B6B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserAccountSection() {
    if (UserManager.isLoggedIn) {
      final user = UserManager.currentUser!;
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
                    color: const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(28.w),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: Color(0xFF4338CA),
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
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    UserManager.logout();
                    setState(() {});
                  },
                  icon: const Icon(Icons.logout),
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
            title: const Text('登录'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              ).then((_) => setState(() {}));
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('注册'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterPage(),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      );
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}