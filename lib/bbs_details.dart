import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'app_shared.dart' as shared;
import 'bbs_home.dart';

class BbsDetailsPage extends StatefulWidget {
  final Post post;

  const BbsDetailsPage({super.key, required this.post});

  @override
  State<BbsDetailsPage> createState() => _BbsDetailsPageState();
}

class _BbsDetailsPageState extends State<BbsDetailsPage> {
  late Post _post;
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isLiked = false;
  final TextEditingController _commentController = TextEditingController();
  final shared.UserManager userManager = shared.UserManager();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _fetchComments();
    _checkLikeStatus();
  }

  // 获取评论列表
  Future<void> _fetchComments() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${shared.AppConfig.baseWebUrl3004}/api/bbs/posts/${_post.id}/comments',
        ),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final dataList = decoded['data'] as List<dynamic>? ?? [];

        setState(() {
          _comments = dataList.map((item) => Comment.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 检查点赞状态
  Future<void> _checkLikeStatus() async {
    final currentUser = userManager.currentUser;
    if (currentUser == null || currentUser.user_id == null) return;

    try {
      final response = await http.get(
        Uri.parse(
          '${shared.AppConfig.baseWebUrl3004}/api/bbs/posts/${_post.id}/like/status?user_id=${currentUser.user_id}',
        ),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          _isLiked = decoded['data']['liked'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error checking like status: $e');
    }
  }

  // 点赞/取消点赞
  Future<void> _toggleLike() async {
    final currentUser = userManager.currentUser;
    if (currentUser == null || currentUser.user_id == null) {
      _showLoginRequired();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          '${shared.AppConfig.baseWebUrl3004}/api/bbs/posts/${_post.id}/like',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': currentUser.user_id}),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          _isLiked = decoded['data']['liked'];
          if (_isLiked) {
            _post = _post.copyWith(likesCount: _post.likesCount + 1);
          } else {
            _post = _post.copyWith(likesCount: _post.likesCount - 1);
          }
        });
      } else {
        _showError('操作失败，请稍后重试');
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      _showError('网络错误，请检查连接');
    }
  }

  // 发表评论
  Future<void> _addComment() async {
    final currentUser = userManager.currentUser;
    if (currentUser == null || currentUser.user_id == null) {
      _showLoginRequired();
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) {
      _showError('请输入评论内容');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          '${shared.AppConfig.baseWebUrl3004}/api/bbs/posts/${_post.id}/comments',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': currentUser.user_id, 'content': content}),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        _commentController.clear();

        // 更新评论数和评论列表
        setState(() {
          _post = _post.copyWith(commentsCount: _post.commentsCount + 1);
        });

        // 重新获取评论列表
        await _fetchComments();

        _showSuccess(decoded['message'] ?? '评论成功');
      } else {
        _showError('评论失败，请稍后重试');
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
      _showError('网络错误，请检查连接');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLoginRequired() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('请先登录')));
    // 可以选择跳转到登录页
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('帖子详情'),
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: isDark ? 0 : 4,
        shadowColor: isDark ? const Color(0xFF4F46E5).withOpacity(0.3) : null,
      ),
      body: Column(
        children: [
          // 帖子内容
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    _post.title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // 作者和分类信息
                  Row(
                    children: [
                      _buildCategoryChip(isDark),
                      SizedBox(width: 12.w),
                      Text(
                        _post.authorName,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color:
                              isDark
                                  ? const Color(0xFF94A3B8)
                                  : Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(_post.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color:
                              isDark
                                  ? const Color(0xFF64748B)
                                  : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // 内容
                  Text(
                    _post.content,
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.5,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 图片展示
                  if (_post.images.isNotEmpty) ...[
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children:
                          _post.images.map((imageUrl) {
                            return GestureDetector(
                              onTap: () => _showImagePreview(imageUrl),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.network(
                                  imageUrl,
                                  width:
                                      (MediaQuery.of(context).size.width -
                                          48.w) /
                                      3,
                                  height: 120.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width:
                                          (MediaQuery.of(context).size.width -
                                              48.w) /
                                          3,
                                      height: 120.h,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // 点赞和评论统计
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        ),
                        bottom: BorderSide(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                          icon:
                              _isLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                          label: '${_post.likesCount}',
                          onTap: _toggleLike,
                          isActive: _isLiked,
                          isDark: isDark,
                        ),
                        _buildActionButton(
                          icon: Icons.comment_outlined,
                          label: '${_post.commentsCount}',
                          onTap: () => _scrollToComments(),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 评论标题
                  Text(
                    '评论 (${_comments.length})',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // 评论列表
                  if (_isLoading && _comments.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (_comments.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.h),
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color:
                                  isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '暂无评论，快来抢沙发吧～',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color:
                                    isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return _buildCommentCard(comment, isDark);
                      },
                    ),
                  SizedBox(height: 80.h), // 为底部输入框留出空间
                ],
              ),
            ),
          ),

          // 底部评论输入框
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: '写下你的评论...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFEEF2FF),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send, size: 20.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF4F46E5), width: 1.5),
      ),
      child: Text(
        _post.categoryName,
        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4F46E5)),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color:
                isActive
                    ? const Color(0xFF4F46E5)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color:
                  isActive
                      ? const Color(0xFF4F46E5)
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Comment comment, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              isDark
                  ? const Color(0xFF4F46E5).withOpacity(0.5)
                  : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor:
                    isDark
                        ? const Color(0xFF3D5AFE).withOpacity(0.2)
                        : const Color(0xFF3D5AFE).withOpacity(0.1),
                child: Text(
                  comment.userName.isNotEmpty
                      ? comment.userName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF3D5AFE),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                comment.userName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(comment.createdAt),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[300] : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
    );
  }

  void _scrollToComments() {
    // 滚动到评论区域
    // 可以添加滚动控制器实现
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${date.month}/${date.day}';
  }
}

// 评论模型
class Comment {
  final int id;
  final int postId;
  final int userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      postId: json['post_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '匿名用户',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

// 扩展 Post 类，添加 copyWith 方法
extension PostCopy on Post {
  Post copyWith({
    int? id,
    int? user_id,
    String? title,
    String? content,
    String? authorName,
    String? categoryName,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    List<String>? images,
    int? categoryId,
  }) {
    return Post(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      categoryName: categoryName ?? this.categoryName,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
