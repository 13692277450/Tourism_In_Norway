import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'bbs_home.dart';
import 'app_shared.dart' as shared;
import 'user_auth.dart';

class BbsPostPage extends StatefulWidget {
  const BbsPostPage({super.key});

  @override
  State<BbsPostPage> createState() => _BbsPostPageState();
}

class _BbsPostPageState extends State<BbsPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  List<Category> _categories = [];
  int? _selectedCategoryId;
  final List<File> _imageFiles = []; // 本地图片文件
  final List<String> _imageUrls = []; // 上传后的图片URL
  bool _isSubmitting = false;

  final UserManager = shared.UserManager();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${shared.AppConfig.baseWebUrl}/api/bbs/categories'),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final dataList = decoded['data'] as List<dynamic>? ?? [];
        setState(() {
          _categories =
              dataList.map((item) => Category.fromJson(item)).toList();
          if (_categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
      if (index < _imageUrls.length) {
        _imageUrls.removeAt(index);
      }
    });
  }

  // 上传单张图片
  Future<String?> _uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${shared.AppConfig.baseWebUrl}/api/bbs/upload/image'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('images', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['data']['url'];
      } else {
        debugPrint('图片上传失败: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('图片上传异常: $e');
      return null;
    }
  }

  Future<void> _submitPost() async {
    // 检查用户是否登录
    if (!UserManager.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先登录')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写完整信息')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = UserManager.currentUser;
      if (currentUser == null || currentUser.user_id == null) {
        throw Exception('未检测到有效登录用户，请重新登录');
      }

      // 创建 multipart 请求（直接发送图片文件）
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${shared.AppConfig.baseWebUrl}/api/bbs/posts'),
      );

      // 添加文本字段（使用数据库自增ID，整数类型）
      request.fields['id'] = currentUser.user_id.toString();
      request.fields['user_id'] = currentUser.user_id.toString();
      request.fields['title'] = _titleController.text;
      request.fields['category_id'] = (_selectedCategoryId ?? 1).toString();
      request.fields['content'] = _contentController.text;

      // 添加图片文件, 并显式指定 MIME 类型
      for (var imageFile in _imageFiles) {
        final extension = path.extension(imageFile.path).toLowerCase();
        String mimeType;
        if (extension == '.png') {
          mimeType = 'image/png';
        } else if (extension == '.gif') {
          mimeType = 'image/gif';
        } else {
          mimeType = 'image/jpeg';
        }

        debugPrint('Attach file: ${imageFile.path}, mimeType: $mimeType');

        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // ← 必须与服务器端 upload.array('images', 5) 一致
            imageFile.path,
            filename: path.basename(imageFile.path),
            contentType: MediaType(
              mimeType.split('/')[0],
              mimeType.split('/')[1],
            ),
          ),
        );
      }

      debugPrint('发送的字段: ${request.fields}');
      debugPrint('发送的文件数量: ${request.files.length}');

      // 发送请求
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final success =
            decoded['success'] == true || decoded['message'] == '发布成功';
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('发布成功')));
          Navigator.pop(context);
        } else {
          final errorMessage = decoded['message'] ?? '发布失败';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      } else {
        final decoded = _tryParseJson(response.body);
        final errorMessage =
            decoded?['message'] ?? '发布失败，状态码: ${response.statusCode}';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      debugPrint('Error submitting post: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('发布失败: ${e.toString()}')));
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  Map<String, dynamic>? _tryParseJson(String body) {
    try {
      final decoded = json.decode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          '发布帖子',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        foregroundColor: isDark ? Colors.white : Colors.black,
        shadowColor: isDark ? const Color(0xFF4F46E5).withOpacity(0.5) : null,
        elevation: isDark ? 8 : 4,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题输入
            Text(
              '标题',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? const Color(0xFF4F46E5) : const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.w),
                boxShadow:
                    isDark
                        ? [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                        : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                border: Border.all(
                  color: isDark ? const Color(0xFF4F46E5) : Colors.grey[300]!,
                  width: isDark ? 1.5 : 1,
                ),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
              ),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '请输入标题',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.w),
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                maxLength: 200,
              ),
            ),
            SizedBox(height: 16.h),

            // 分类选择
            Text(
              '分类',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? const Color(0xFF0EA5E9) : const Color(0xFF4F46E5),
              ),
            ),
            SizedBox(height: 8.h),
            isDark
                ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF0EA5E9),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8.w),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0EA5E9).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                    color: const Color(0xFF1E293B),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedCategoryId,
                    hint: const Text(
                      '请选择分类',
                      style: TextStyle(color: Colors.grey),
                    ),
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white),
                    items:
                        _categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(
                              category.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                )
                : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF4F46E5),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8.w),
                    color: Colors.white,
                  ),
                  child: DropdownButton<int>(
                    value: _selectedCategoryId,
                    hint: const Text(
                      '请选择分类',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black),
                    items:
                        _categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(
                              category.name,
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                ),
            SizedBox(height: 16.h),

            // 内容输入
            Text(
              '内容',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? const Color(0xFF4F46E5) : const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.w),
                boxShadow:
                    isDark
                        ? [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                        : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                border: Border.all(
                  color: isDark ? const Color(0xFF4F46E5) : Colors.grey[300]!,
                  width: isDark ? 1.5 : 1,
                ),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
              ),
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: '请输入内容',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.w),
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                maxLines: 10,
              ),
            ),
            SizedBox(height: 16.h),

            // 图片上传
            Text(
              '图片',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? const Color(0xFF0EA5E9) : const Color(0xFF4F46E5),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 100.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imageFiles.length + 1,
                itemBuilder: (context, index) {
                  if (index == _imageFiles.length) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child:
                          isDark
                              ? Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF4F46E5,
                                      ).withOpacity(0.4),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 100.w,
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFF4F46E5),
                                        style: BorderStyle.solid,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8.w),
                                      color: const Color(0xFF1E293B),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Color(0xFF4F46E5),
                                    ),
                                  ),
                                ),
                              )
                              : GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 100.w,
                                  height: 100.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF4F46E5),
                                      style: BorderStyle.solid,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8.w),
                                    color: Colors.white,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ),
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Stack(
                        children: [
                          Image.file(
                            _imageFiles[index],
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 4.w,
                            right: 4.w,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12.w),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 32.h),

            // 提交按钮
            Center(
              child:
                  isDark
                      ? Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5),
                              blurRadius: 15,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: const Color(0xFF0EA5E9),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitPost,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(200.w, 48.h),
                            backgroundColor: const Color(0xFF1E293B),
                            foregroundColor: const Color(0xFF4F46E5),
                            side: const BorderSide(
                              color: Color(0xFF4F46E5),
                              width: 2,
                            ),
                            elevation: 0,
                          ),
                          child:
                              _isSubmitting
                                  ? const CircularProgressIndicator(
                                    color: Color(0xFF4F46E5),
                                  )
                                  : const Text('发布帖子'),
                        ),
                      )
                      : ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitPost,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(200.w, 48.h),
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                        ),
                        child:
                            _isSubmitting
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text('发布帖子'),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
