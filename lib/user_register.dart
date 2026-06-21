import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'app_shared.dart' as shared;

const baseUrl = '${shared.AppConfig.baseWebUrl}:${shared.AppConfig.port3004}';

// 20个人物彩色Emoji
const List<String> personEmojis = [
  // 基础人物 (4个)
  '👨', // 男人
  '👩', // 女人
  '🧑', // 中性人物
  '👴', // 老年人（爷爷）
  '👵', // 老年人（奶奶）
  // 中年人 (2个)
  '👨‍🦳', // 中年男人（白发）
  '👩‍🦳', // 中年女人（白发）
  // 年轻人 (2个)
  '👦', // 男孩
  '👧', // 女孩
  // 帅气/美丽 (4个)
  '🧑‍🦰', // 帅气男人（红发）
  '👨‍🦱', // 卷发帅男
  '👩‍🦰', // 红发美女
  '👩‍🦱', // 卷发美女
  // 长发/短发 (3个)
  '👨‍🦲', // 光头/短发男
  '👩‍🦲', // 短发女
  '🧑‍🦳', // 长发中性
  // 搞笑/滑稽/幽默 (5个)
  '🤣', // 笑到流泪（超级搞笑）
  '😜', // 搞怪眨眼
  '😝', // 吐舌搞怪
  '🤪', // 滑稽疯狂
  '🥳', // 派对开心（幽默欢乐）
];

// 所有50个Emoji（包含人物+动物+宠物+花朵+自然）
const List<String> availableEmojis = [
  // 人物 (20个)
  ...personEmojis,
  // 动物 (8个)
  '🦁', '🐯', '🐱', '🐶', '🐺', '🦊', '🐼', '🐨',
  // 宠物 (8个)
  '🐕', '🐈', '🐇', '🐹', '🐭', '🐰', '🦝', '🐾',
  // 花朵 (7个)
  '🌸', '🌺', '🌻', '🌷', '🌹', '🌿', '🍀',
  // 自然/其他 (7个)
  '⭐', '🌟', '✨', '🌈', '☀️', '🌙', '🦋',
];

// 人物Emoji的分类标签映射
final Map<String, String> personEmojiCategories = {
  '👨': '男人',
  '👩': '女人',
  '🧑': '中性',
  '👴': '老爷爷',
  '👵': '老奶奶',
  '👨‍🦳': '中年男',
  '👩‍🦳': '中年女',
  '👦': '男孩',
  '👧': '女孩',
  '🧑‍🦰': '帅气男',
  '👨‍🦱': '卷发帅男',
  '👩‍🦰': '红发美女',
  '👩‍🦱': '卷发美女',
  '👨‍🦲': '光头男',
  '👩‍🦲': '短发女',
  '🧑‍🦳': '长发中性',
  '🤣': '爆笑',
  '😜': '搞怪',
  '😝': '吐舌',
  '🤪': '滑稽',
  '🥳': '欢乐',
};

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
  String? _selectedEmoji;
  bool _isSubmitting = false;
  bool _showEmojiPicker = false;
  String _emojiSearchQuery = '';
  String _selectedCategory = '全部';

  // 彩色Emoji映射
  final Map<String, String> _fieldEmojis = {
    '登录用户名': '👤',
    '邮箱': '📧',
    '电话': '📱',
    '密码': '🔐',
    '确认密码': '✅',
    '国家': '🌍',
    '备注': '📝',
    '注册': '🚀',
    '用户信息': '📋',
  };

  String _getFieldEmoji(String label) {
    return _fieldEmojis[label] ?? '📌';
  }

  // 获取Emoji分类
  String _getEmojiCategory(String emoji) {
    if (personEmojis.contains(emoji)) return '人物';
    final animalEmojis = ['🦁', '🐯', '🐱', '🐶', '🐺', '🦊', '🐼', '🐨'];
    if (animalEmojis.contains(emoji)) return '动物';
    final petEmojis = ['🐕', '🐈', '🐇', '🐹', '🐭', '🐰', '🦝', '🐾'];
    if (petEmojis.contains(emoji)) return '宠物';
    final flowerEmojis = ['🌸', '🌺', '🌻', '🌷', '🌹', '🌿', '🍀'];
    if (flowerEmojis.contains(emoji)) return '花朵';
    final natureEmojis = ['⭐', '🌟', '✨', '🌈', '☀️', '🌙', '🦋'];
    if (natureEmojis.contains(emoji)) return '自然';
    return '其他';
  }

  // 获取人物Emoji的详细标签
  String _getPersonEmojiLabel(String emoji) {
    return personEmojiCategories[emoji] ?? '人物';
  }

  // 获取分类图标
  String _getCategoryIcon(String category) {
    switch (category) {
      case '人物':
        return '👤';
      case '动物':
        return '🦁';
      case '宠物':
        return '🐕';
      case '花朵':
        return '🌸';
      case '自然':
        return '⭐';
      default:
        return '📌';
    }
  }

  // 按分类分组
  Map<String, List<String>> get _groupedEmojis {
    final Map<String, List<String>> groups = {};
    for (final emoji in availableEmojis) {
      final category = _getEmojiCategory(emoji);
      if (!groups.containsKey(category)) {
        groups[category] = [];
      }
      groups[category]!.add(emoji);
    }
    return groups;
  }

  // 获取分类列表
  List<String> get _categories => ['全部', ..._groupedEmojis.keys];

  // 过滤Emoji
  List<String> get _filteredEmojis {
    var filtered = availableEmojis;

    // 按分类过滤
    if (_selectedCategory != '全部') {
      filtered =
          filtered.where((emoji) {
            return _getEmojiCategory(emoji) == _selectedCategory;
          }).toList();
    }

    // 按搜索词过滤
    if (_emojiSearchQuery.isNotEmpty) {
      filtered =
          filtered.where((emoji) {
            final category = _getEmojiCategory(emoji);
            final personLabel = _getPersonEmojiLabel(emoji);
            return emoji.contains(_emojiSearchQuery) ||
                category.contains(_emojiSearchQuery) ||
                personLabel.contains(_emojiSearchQuery);
          }).toList();
    }

    return filtered;
  }

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
        Uri.parse('$baseUrl/api/bbs/users/register'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('📋', style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 8.w),
            const Text('用户注册'),
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
              padding: EdgeInsets.all(24.w),
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
                  // 标题
                  Row(
                    children: [
                      Text('📋', style: TextStyle(fontSize: 24.sp)),
                      SizedBox(width: 12.w),
                      Text(
                        '用户信息',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF5B21B6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '请填写以下信息完成注册',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // 登录用户名
                  _buildTextField(
                    controller: _nameController,
                    label: '登录用户名',
                    emoji: '👤',
                    hint: '请输入登录用户名',
                  ),
                  SizedBox(height: 14.h),

                  // 邮箱
                  _buildTextField(
                    controller: _mailController,
                    label: '邮箱',
                    emoji: '📧',
                    hint: '请输入邮箱',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 14.h),

                  // 电话
                  _buildTextField(
                    controller: _telephoneController,
                    label: '电话',
                    emoji: '📱',
                    hint: '请输入电话',
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 14.h),

                  // 密码
                  _buildTextField(
                    controller: _passwordController,
                    label: '密码',
                    emoji: '🔐',
                    hint: '请输入密码',
                    obscureText: true,
                  ),
                  SizedBox(height: 14.h),

                  // 确认密码
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: '确认密码',
                    emoji: '✅',
                    hint: '请再次输入密码',
                    obscureText: true,
                  ),
                  SizedBox(height: 14.h),

                  // 国家选择
                  _buildCountryDropdown(),
                  SizedBox(height: 14.h),

                  // Emoji选择器
                  _buildEmojiPicker(),
                  SizedBox(height: 14.h),

                  // 备注
                  _buildTextField(
                    controller: _remarkController,
                    label: '备注',
                    emoji: '📝',
                    hint: '请输入备注信息',
                    maxLines: 3,
                  ),
                  SizedBox(height: 32.h),

                  // 注册按钮
                  Center(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRegister,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(220.w, 50.h),
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFF7C3AED).withOpacity(0.4),
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🚀', style: TextStyle(fontSize: 20.sp)),
                                  SizedBox(width: 10.w),
                                  Text(
                                    '注册',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                    ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String emoji,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            if (label != '备注') ...[
              SizedBox(width: 4.w),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
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

  Widget _buildCountryDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('🌍', style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 6.w),
            Text(
              '国家',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : const Color(0xFF4B5563),
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.w),
            color: isDark ? const Color(0xFF374151) : const Color(0xFFF8F7FF),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCountry,
            hint: Text(
              '请选择国家',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
                fontSize: 14.sp,
              ),
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.w),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.w),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.w),
                borderSide: const BorderSide(
                  color: Color(0xFF7C3AED),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            dropdownColor: isDark ? const Color(0xFF374151) : Colors.white,
            items:
                shared.countryList.map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(
                      country,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
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

  Widget _buildEmojiPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('🎨', style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 6.w),
            Text(
              '选择头像表情',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : const Color(0xFF4B5563),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _showEmojiPicker = !_showEmojiPicker;
                  if (!_showEmojiPicker) {
                    _emojiSearchQuery = '';
                    _selectedCategory = '全部';
                  }
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7C3AED),
              ),
              child: Text(
                _showEmojiPicker ? '收起' : '选择',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        // 显示选中的Emoji
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28.w),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              _selectedEmoji ?? '😊',
              style: TextStyle(fontSize: 28.sp),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // 已选提示
        if (_selectedEmoji != null)
          Center(
            child: Text(
              '已选择: $_selectedEmoji ${_getPersonEmojiLabel(_selectedEmoji!)}',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF7C3AED),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (_showEmojiPicker)
          Container(
            margin: EdgeInsets.only(top: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFF8F7FF),
              borderRadius: BorderRadius.circular(12.w),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // 搜索框
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(8.w),
                    border: Border.all(
                      color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _emojiSearchQuery = value.toLowerCase();
                      });
                    },
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: '搜索表情...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                        fontSize: 13.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: const Color(0xFF7C3AED),
                        size: 20.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // 分类标签
                if (_emojiSearchQuery.isEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _categories.map((category) {
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? const Color(0xFF7C3AED)
                                            : const Color(
                                              0xFF7C3AED,
                                            ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.w),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.transparent
                                              : const Color(
                                                0xFF7C3AED,
                                              ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (category != '全部')
                                        Text(
                                          _getCategoryIcon(category),
                                          style: TextStyle(fontSize: 12.sp),
                                        ),
                                      if (category != '全部')
                                        SizedBox(width: 4.w),
                                      Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF7C3AED),
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                SizedBox(height: 8.h),
                // Emoji网格
                if (_filteredEmojis.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                    itemCount: _filteredEmojis.length,
                    itemBuilder: (context, index) {
                      final emoji = _filteredEmojis[index];
                      final isSelected = _selectedEmoji == emoji;
                      final isPerson = personEmojis.contains(emoji);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedEmoji = emoji;
                            _showEmojiPicker = false;
                            _emojiSearchQuery = '';
                            _selectedCategory = '全部';
                          });
                        },
                        child: Tooltip(
                          message:
                              isPerson
                                  ? _getPersonEmojiLabel(emoji)
                                  : _getEmojiCategory(emoji),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFF7C3AED).withOpacity(0.2)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.w),
                              border:
                                  isSelected
                                      ? Border.all(
                                        color: const Color(0xFF7C3AED),
                                        width: 2,
                                      )
                                      : null,
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: TextStyle(fontSize: 22.sp),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Center(
                      child: Text(
                        '没有找到匹配的表情',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
