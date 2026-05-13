import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'bbs.dart';

class BbsDetailsPage extends StatefulWidget {
  final Post post;

  const BbsDetailsPage({super.key, required this.post});

  @override
  State<BbsDetailsPage> createState() => _BbsDetailsPageState();
}

class _BbsDetailsPageState extends State<BbsDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likesCount;
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://www.pavogroup.top:3004/api/posts/${widget.post.id}/comments'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final dataList = decoded['data'] as List<dynamic>? ?? [];
        setState(() {
          _comments = dataList.map((item) => Comment.fromJson(item)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('http://www.pavogroup.top:3004/api/posts/${widget.post.id}/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'content': _commentController.text,
        }),
      );

      if (response.statusCode == 200) {
        _commentController.clear();
        _fetchComments();
      }
    } catch (e) {
      debugPrint('Error submitting comment: $e');
    }
  }

  Future<void> _toggleLike() async {
    try {
      final response = await http.post(
        Uri.parse('http://www.pavogroup.top:3004/api/posts/${widget.post.id}/like'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLiked = !_isLiked;
          _likesCount += _isLiked ? 1 : -1;
        });
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帖子详情'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16.w),
              margin: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 分类标签
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                    child: Text(
                      widget.post.categoryName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF4338CA),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  
                  // 标题
                  Text(
                    widget.post.title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  
                  // 作者信息
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.authorName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDate(widget.post.createdAt),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  // 内容
                  Text(
                    widget.post.content,
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.8,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // 图片
                  if (widget.post.images.isNotEmpty)
                    Column(
                      children: widget.post.images.map((imageUrl) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 16.h),
                  
                  // 操作栏
                  Row(
                    children: [
                      IconButton(
                        onPressed: _toggleLike,
                        icon: Icon(
                          Icons.thumb_up,
                          color: _isLiked ? Colors.red : Colors.grey,
                          size: 24.r,
                        ),
                      ),
                      Text(_likesCount.toString()),
                      SizedBox(width: 24.w),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.comment,
                          color: Colors.grey,
                          size: 24.r,
                        ),
                      ),
                      Text(_comments.length.toString()),
                      SizedBox(width: 24.w),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.share,
                          color: Colors.grey,
                          size: 24.r,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 评论标题
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '评论 (${_comments.length})',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // 评论列表
          if (_isLoading)
            SliverToBoxAdapter(
              child: Center(child: const CircularProgressIndicator()),
            )
          else if (_comments.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Text('暂无评论'),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final comment = _comments[index];
                  return _CommentCard(comment: comment);
                },
                childCount: _comments.length,
              ),
            ),
          
          // 底部评论输入
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: '发表评论...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.w),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: _submitComment,
                    child: const Text('发送'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute}';
  }
}

class Comment {
  final int id;
  final String content;
  final String authorName;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.authorName,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      authorName: json['user_name'] ?? json['author'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final Comment comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.authorName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDate(comment.createdAt),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            comment.content,
            style: TextStyle(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute}';
  }
}