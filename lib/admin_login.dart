// admin_login.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_shared.dart' as shared;
import 'admin_api.dart';
import 'admin_home.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final loc = shared.AppLocalizations.of(context);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('admin_please_fill'))),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await AdminApi.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isSubmitting = false);

    if (result['code'] == 200) {
      final data = result['data'] as Map<String, dynamic>?;
      final userData = data?['user'] as Map<String, dynamic>?;

      if (userData != null) {
        final userId =
            userData['user_id'] is int
                ? userData['user_id']
                : int.tryParse(userData['user_id'].toString()) ?? 0;

        shared.UserManager().login(
          shared.User(
            user_id: userId > 0 ? userId : userData['id'] ?? 0,
            name: userData['name'] ?? 'Admin',
            email: userData['email'] ?? _emailController.text,
            password: _passwordController.text,
            telephone: userData['telephone'] ?? '',
            country: userData['country'] ?? '',
            remark: userData['remark'] ?? '',
          ),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = shared.AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B),
                      const Color(0xFF334155),
                    ]
                    : [
                      const Color(0xFFEFF6FF),
                      const Color(0xFFDBEAFE),
                      const Color(0xFFBFDBFE),
                    ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Container(
              width: 420.w,
              padding: EdgeInsets.all(40.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24.w),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.4)
                            : Colors.blue.withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color:
                      isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.w),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.shield, color: Colors.white, size: 40.sp),
                  ),
                  SizedBox(height: 24.h),

                  Text(
                    loc.translate('admin_panel'),
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    loc.translate('admin_welcome'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color:
                          isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Email
                  _buildTextField(
                    controller: _emailController,
                    label: loc.translate('admin_email'),
                    hint: 'admin@example.com',
                    icon: Icons.email_outlined,
                    isDark: isDark,
                  ),
                  SizedBox(height: 16.h),

                  // Password
                  _buildTextField(
                    controller: _passwordController,
                    label: loc.translate('admin_password'),
                    hint: '••••••••',
                    icon: Icons.lock_outlined,
                    isDark: isDark,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color:
                            isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFF3B82F6).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                      ),
                      child:
                          _isSubmitting
                              ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                loc.translate('admin_login'),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                  Text(
                    '🔒 ${loc.translate('admin_secure')}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                          isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 15.sp,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 22.sp),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor:
                isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w),
              borderSide: BorderSide(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
      ],
    );
  }
}
