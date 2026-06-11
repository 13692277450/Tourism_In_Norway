import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'app_shared.dart' as shared;

// 可用的Flutter内置图标列表
const List<IconData> availableIcons = [
  Icons.person,
  Icons.account_circle,
  Icons.supervisor_account,
  Icons.person_outline,
  Icons.person,
  Icons.person_outline,
  Icons.face,
  Icons.face_outlined,
  Icons.emoji_people,
  Icons.group,
  Icons.family_restroom,
  Icons.business_center,
  Icons.work,
  Icons.school,
  Icons.home,
  Icons.location_on,
  Icons.email,
  Icons.phone,
  Icons.camera,
  Icons.image,
];

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  String? _selectedCountry;
  IconData? _selectedIcon;
  bool _isSubmitting = false;
  bool _showIconPicker = false;

  Future<void> _submitRegister() async {
    if (_selectedCountry == null ||
        _mailController.text.isEmpty ||
        _telephoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _selectedCountry == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写所有必填信息')));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('两次输入的密码不一致')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${shared.AppConfig.baseWebUrl}:3004/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text,
          'email': _mailController.text,
          'telephone': _telephoneController.text,
          'password': _passwordController.text,
          'country': _selectedCountry,
          'remark': _remarkController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('注册成功')));

        // 解析服务器返回的用户ID
        final decoded = json.decode(response.body);
        final data = decoded['data'] as Map<String, dynamic>?;
        if (data == null || data['id'] == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('注册成功，但未获取到用户ID，请重新登录')));
          Navigator.pop(context);
          return;
        }

        final userId =
            data['id'] is int
                ? data['id']
                : int.tryParse(data['id'].toString()) ?? 0;

        if (userId <= 0) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('注册成功，但获取用户ID失败，请重新登录')));
          Navigator.pop(context);
          return;
        }

        shared.UserManager().login(
          shared.User(
            user_id: userId,
            name: _nameController.text,
            email: _mailController.text,
            password: _passwordController.text,
            telephone: _telephoneController.text,
            country: _selectedCountry!,
            remark: _remarkController.text,
          ),
        );

        Navigator.pop(context);
      } else {
        final decoded = json.decode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(decoded['message'] ?? '注册失败')));
      }
    } catch (e) {
      debugPrint('Error registering: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('注册失败，请检查网络')));
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户注册')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用户信息',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _nameController,
              label: '登录用户名 *',
              hint: '请输入登录用户名',
              icon: Icons.person,
            ),
            SizedBox(height: 12.h),

            _buildTextField(
              controller: _mailController,
              label: '邮箱 *',
              hint: '请输入邮箱',
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email,
            ),
            SizedBox(height: 12.h),

            _buildTextField(
              controller: _telephoneController,
              label: '电话 *',
              hint: '请输入电话',
              keyboardType: TextInputType.phone,
              icon: Icons.phone,
            ),
            SizedBox(height: 12.h),

            _buildTextField(
              controller: _passwordController,
              label: '密码 *',
              hint: '请输入密码',
              obscureText: true,
              icon: Icons.lock,
            ),
            SizedBox(height: 12.h),

            _buildTextField(
              controller: _confirmPasswordController,
              label: '确认密码 *',
              hint: '请再次输入密码',
              obscureText: true,
              icon: Icons.lock_outline,
            ),
            SizedBox(height: 12.h),

            _buildCountryDropdown(),
            SizedBox(height: 12.h),

            _buildIconPicker(),
            SizedBox(height: 12.h),

            _buildTextField(
              controller: _remarkController,
              label: '备注',
              hint: '请输入备注信息',
              maxLines: 3,
              icon: Icons.note,
            ),
            SizedBox(height: 32.h),

            Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRegister,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200.w, 48.h),
                  backgroundColor: const Color(0xFF3D5AFE),
                ),
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('注册'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp)),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.w),
            ),
            prefixIcon: icon != null ? Icon(icon) : null,
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('国家 *', style: TextStyle(fontSize: 14)),
        SizedBox(height: 4.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCountry,
            hint: const Text('请选择国家'),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            items:
                shared.countryList.map((country) {
                  return DropdownMenuItem(value: country, child: Text(country));
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCountry = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIconPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('选择图标', style: TextStyle(fontSize: 14)),
            TextButton(
              onPressed: () {
                setState(() {
                  _showIconPicker = !_showIconPicker;
                });
              },
              child: const Text('选择'),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        _selectedIcon != null
            ? Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(24.w),
              ),
              child: Icon(
                _selectedIcon,
                size: 24,
                color: const Color(0xFF4338CA),
              ),
            )
            : Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(24.w),
              ),
              child: const Icon(Icons.add),
            ),
        if (_showIconPicker)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
              ),
              itemCount: availableIcons.length,
              itemBuilder: (context, index) {
                final icon = availableIcons[index];
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedIcon = icon;
                      _showIconPicker = false;
                    });
                  },
                  icon: Icon(icon),
                  color:
                      _selectedIcon == icon
                          ? const Color(0xFF3D5AFE)
                          : Colors.grey,
                );
              },
            ),
          ),
      ],
    );
  }
}
