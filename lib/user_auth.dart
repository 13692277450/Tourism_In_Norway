import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'user_register.dart';
import 'app_shared.dart' as shared;

const baseUrl = '${shared.AppConfig.baseWebUrl}:${shared.AppConfig.port3004}';

// 登录页面
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  // 彩色Emoji
  final String _welcomeEmoji = '👋';
  final String _emailEmoji = '📧';
  final String _passwordEmoji = '🔐';
  final String _loginEmoji = '🚀';
  final String _registerEmoji = '📝';

  Future<void> _submitLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写邮箱和密码')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/bbs/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] as Map<String, dynamic>?;
        final userData =
            data != null && data['user'] is Map<String, dynamic>
                ? data['user'] as Map<String, dynamic>
                : null;

        if (userData == null || userData['user_id'] == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('登录失败，未获取到用户信息')));
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        final userId =
            userData['user_id'] is int
                ? userData['user_id']
                : int.tryParse(userData['user_id'].toString()) ?? 0;

        if (userId <= 0) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('登录失败，用户ID无效')));
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        shared.UserManager().login(
          shared.User(
            user_id: userId,
            name: userData['name'] ?? userData['username'] ?? 'User',
            email: userData['email'] ?? _emailController.text,
            password: _passwordController.text,
            telephone: userData['telephone'] ?? '',
            country: userData['country'] ?? '',
            remark: userData['remark'] ?? '',
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('登录失败，请检查邮箱和密码')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('网络错误，请检查连接')));
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('🔐', style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 8.w),
            const Text('用户登录'),
          ],
        ),
        backgroundColor:
            isDark ? const Color(0xFF1F2937) : const Color(0xFFF5F3FF),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFFF5F3FF), const Color(0xFFEDE9FE)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(20.w),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF7C3AED,
                    ).withOpacity(isDark ? 0.3 : 0.15),
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                ],
                border:
                    isDark
                        ? Border.all(
                          color: const Color(0xFF7C3AED).withOpacity(0.3),
                        )
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  // 欢迎标题 - 添加彩色Emoji
                  Row(
                    children: [
                      Text(_welcomeEmoji, style: TextStyle(fontSize: 28.sp)),
                      SizedBox(width: 12.w),
                      Text(
                        '欢迎回来',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF5B21B6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '请输入您的账号信息',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // 邮箱输入框 - 彩色图标
                  _buildLoginTextField(
                    controller: _emailController,
                    label: '邮箱',
                    hint: '请输入邮箱',
                    icon: Icons.email,
                    emoji: _emailEmoji,
                    iconColor: const Color(0xFF8B5CF6),
                  ),
                  SizedBox(height: 18.h),

                  // 密码输入框 - 彩色图标
                  _buildLoginTextField(
                    controller: _passwordController,
                    label: '密码',
                    hint: '请输入密码',
                    icon: Icons.lock,
                    emoji: _passwordEmoji,
                    iconColor: const Color(0xFFA78BFA),
                    obscureText: true,
                  ),
                  SizedBox(height: 32.h),

                  // 按钮行
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50.h),
                            side: BorderSide(
                              color: const Color(0xFF7C3AED),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.w),
                            ),
                            backgroundColor:
                                isDark ? const Color(0xFF1F2937) : Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _registerEmoji,
                                style: TextStyle(fontSize: 18.sp),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '注册',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF7C3AED),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitLogin,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50.h),
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: const Color(
                              0xFF7C3AED,
                            ).withOpacity(0.4),
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
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _loginEmoji,
                                        style: TextStyle(fontSize: 20.sp),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        '登录',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),
                  // 底部提示
                  Center(
                    child: Text(
                      '🔒 您的信息安全受到保护',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
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

  Widget _buildLoginTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String emoji,
    required Color iconColor,
    bool obscureText = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFocused = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            fontSize: 15.sp,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(icon, color: iconColor, size: 22.sp),
            filled: true,
            fillColor:
                isDark ? const Color(0xFF374151) : const Color(0xFFF8F7FF),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w),
              borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
