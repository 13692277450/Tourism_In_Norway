import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'app_shared.dart' as shared;

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

  Future<void> _submitLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写邮箱和密码')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 调用登录API获取用户信息
      final response = await http.post(
        Uri.parse('http://www.pavogroup.top:3004/api/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] as Map<String, dynamic>?;
        final userData = data != null && data['user'] is Map<String, dynamic>
            ? data['user'] as Map<String, dynamic>
            : null;

        if (userData == null || userData['user_id'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登录失败，未获取到用户信息')),
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        final userId = userData['user_id'] is int
            ? userData['user_id']
            : int.tryParse(userData['user_id'].toString()) ?? 0;

        if (userId <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登录失败，用户ID无效')),
          );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登录失败，请检查邮箱和密码')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('网络错误，请检查连接')),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户登录'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40.h),
            Text(
              '欢迎回来',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '请输入您的账号信息',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 32.h),
            
            _buildLoginTextField(
              controller: _emailController,
              label: '邮箱',
              hint: '请输入邮箱',
              icon: Icons.email,
            ),
            SizedBox(height: 16.h),
            
            _buildLoginTextField(
              controller: _passwordController,
              label: '密码',
              hint: '请输入密码',
              icon: Icons.lock,
              obscureText: true,
            ),
            SizedBox(height: 32.h),
            
            Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200.w, 48.h),
                  backgroundColor: const Color(0xFF3D5AFE),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp),
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.w),
            ),
            prefixIcon: Icon(icon),
          ),
          obscureText: obscureText,
        ),
      ],
    );
  }
}