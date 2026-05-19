import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'bbs.dart';
import 'app_shared.dart' as shared;
import 'auth.dart';

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
  final List<File> _imageFiles = [];  // 本地图片文件
  final List<String> _imageUrls = [];  // 上传后的图片URL
  bool _isSubmitting = false;
  
  final UserManager = shared.UserManager();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://www.pavogroup.top:3004/api/categories'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final dataList = decoded['data'] as List<dynamic>? ?? [];
        setState(() {
          _categories = dataList.map((item) => Category.fromJson(item)).toList();
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
        Uri.parse('http://www.pavogroup.top:3004/api/upload/image'),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        imageFile.path,
      ));
      
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整信息')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 第一步：上传所有图片
      _imageUrls.clear();
      for (var imageFile in _imageFiles) {
        final url = await _uploadImage(imageFile);
        if (url != null) {
          _imageUrls.add(url);
        } else {
          throw Exception('图片上传失败，请重试');
        }
      }
      
      debugPrint('上传的图片URL: $_imageUrls');

      final currentUser = UserManager.currentUser;
      if (currentUser == null || currentUser.id == null) {
        throw Exception('未检测到有效登录用户，请重新登录');
      }

      // 第二步：发布帖子
      final Map<String, dynamic> requestBody = {
        'id': currentUser.id,
        'title': _titleController.text,
        'category_id': _selectedCategoryId ?? 1,
        'content': _contentController.text,
      };
      if (_imageUrls.isNotEmpty) {
        requestBody['images'] = _imageUrls;
      }

      final bodyJson = json.encode(requestBody);

  

      final response = await http.post(
        Uri.parse('http://www.pavogroup.top:3004/api/posts'),
        headers: {'Content-Type': 'application/json'},
        body: bodyJson,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final success = decoded['success'] == true || decoded['message'] == '发布成功';
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('发布成功')),
          );
          Navigator.pop(context);
        } else {
          final errorMessage = decoded['message'] ?? '发布失败';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } else {
        final decoded = _tryParseJson(response.body);
        final errorMessage = decoded?['message'] ?? '发布失败，状态码: ${response.statusCode}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      debugPrint('Error submitting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发布失败: ${e.toString()}')),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布帖子'),
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
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '请输入标题',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.w),
                ),
              ),
              maxLength: 200,
            ),
            SizedBox(height: 16.h),
            
            // 分类选择
            Text(
              '分类',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: DropdownButton<int>(
                value: _selectedCategoryId,
                hint: const Text('请选择分类'),
                isExpanded: true,
                underline: const SizedBox(),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
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
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '请输入内容',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.w),
                ),
              ),
              maxLines: 10,
            ),
            SizedBox(height: 16.h),
            
            // 图片上传
            Text(
              '图片',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
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
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.grey,
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
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200.w, 48.h),
                  backgroundColor: const Color.fromARGB(255, 159, 171, 242),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text( 'SUBMIT',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 147, 133, 9),
                      ),
                    ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}