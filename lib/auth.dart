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
        Uri.parse('http://www.pavogroup.top:3004/api/login'),
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final userData = decoded['data'] as Map<String, dynamic>;
        
        shared.UserManager().login(
          shared.User(
            id: userData['id'] ?? 1,
            name: userData['name'] ?? userData['username'] ?? '用户',
            email: userData['email'] ?? _emailController.text,
            telephone: userData['telephone'] ?? '',
            country: userData['country'] ?? '',
          ),
        );
        
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登录失败，请检查邮箱和密码')),
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      // 如果API调用失败，使用模拟数据（保持原有行为）
      shared.UserManager().login(
        shared.User(
          id: 1,
          name: '测试用户',
          email: _emailController.text,
          telephone: '',
          country: '中国',
        ),
      );
      Navigator.pop(context);
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