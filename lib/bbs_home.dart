import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image_ce/cached_network_image.dart';

import 'app_shared.dart' as shared;
import 'bbs_details.dart';
import 'bbs_post.dart';
import 'user_auth.dart';

// ==================== Category 类 ====================
class Category {
  final int id;
  final String name;
  final String description;

  Category({required this.id, required this.name, required this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

// ==================== Post 类 ====================
class Post {
  final int id;
  final int user_id;
  final String title;
  final String content;
  final String authorName;
  final String categoryName;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final List<String> images;
  final int categoryId;

  Post({
    required this.id,
    required this.user_id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.categoryName,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    this.images = const [],
    this.categoryId = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'];
    List<String> images = [];

    if (imagesJson != null) {
      if (imagesJson is List) {
        images = imagesJson.map((e) => e.toString()).toList();
      } else if (imagesJson is String) {
        try {
          final parsed = jsonDecode(imagesJson);
          if (parsed is List) {
            images = parsed.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
    }

    return Post(
      id: json['id'] ?? 0,
      user_id: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorName: json['user_name'] ?? json['author'] ?? 'Anonymous',
      categoryName: json['category_name'] ?? 'No Category',
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      images: images,
      categoryId: json['category_id'] ?? 0,
    );
  }

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

// ==================== 颜色工具函数 ====================
Color _getCategoryColor(int categoryId) {
  switch (categoryId) {
    case 1:
      return const Color(0xFF4F46E5);
    case 2:
      return const Color(0xFF059669);
    case 3:
      return const Color(0xFFD97706);
    case 4:
      return const Color(0xFFDC2626);
    case 5:
      return const Color(0xFF7C3AED);
    case 6:
      return const Color(0xFF0891B2);
    case 7:
      return const Color(0xFFDB2777);
    case 8:
      return const Color(0xFF65A30D);
    default:
      return const Color(0xFF4F46E5);
  }
}

// ==================== CachedPostImage 组件 ====================
class CachedPostImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const CachedPostImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder:
          (context, url) => Container(
            width: width,
            height: height,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
          ),
      errorWidget:
          (context, url, error) => Container(
            width: width,
            height: height,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            child: Icon(
              Icons.broken_image,
              size: 30,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
    );
  }
}

// ==================== _PostCard 组件 ====================
class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final int? currentUserId;
  final Map<int, String> categoryEmojis;
  final Map<String, String> categoryNameEmojis;
  final String Function(int) getHotEmoji;

  const _PostCard({
    required this.post,
    required this.onTap,
    required this.onDelete,
    this.currentUserId,
    required this.categoryEmojis,
    required this.categoryNameEmojis,
    required this.getHotEmoji,
  });

  String _getEmojiForCategory(int categoryId, String categoryName) {
    if (categoryEmojis.containsKey(categoryId)) {
      return categoryEmojis[categoryId]!;
    }
    for (final entry in categoryNameEmojis.entries) {
      if (categoryName.contains(entry.key)) {
        return entry.value;
      }
    }
    return '📝';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwnPost = currentUserId != null && post.user_id == currentUserId;
    final hotEmoji = getHotEmoji(post.likesCount);
    final categoryEmoji = _getEmojiForCategory(
      post.categoryId,
      post.categoryName,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12.w),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题行 - 添加分类Emoji
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(categoryEmoji, style: TextStyle(fontSize: 18.sp)),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            post.title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark
                                      ? _getCategoryColor(
                                        post.categoryId,
                                      ).withOpacity(0.9)
                                      : _getCategoryColor(post.categoryId),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOwnPost) SizedBox(width: 32.w),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color:
                            isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),

                    // 使用带缓存的图片组件
                    if (post.images.isNotEmpty)
                      SizedBox(
                        height: 80.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: post.images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: CachedPostImage(
                                imageUrl: post.images[index],
                                width: 80.w,
                                height: 80.h,
                              ),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? const Color(0xFF4F46E5).withOpacity(0.15)
                                    : const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(4.w),
                            border: Border.all(
                              color: const Color(0xFF4F46E5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '$categoryEmoji ${post.categoryName}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _getCategoryColor(post.categoryId),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          post.authorName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:
                                isDark
                                    ? const Color(0xFF94A3B8)
                                    : Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: 14.sp,
                              color:
                                  isDark
                                      ? const Color(0xFF94A3B8)
                                      : Colors.grey[500],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              post.likesCount.toString(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color:
                                    isDark
                                        ? const Color(0xFF94A3B8)
                                        : Colors.grey[500],
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Icon(
                              Icons.comment,
                              size: 14.sp,
                              color:
                                  isDark
                                      ? const Color(0xFF94A3B8)
                                      : Colors.grey[500],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              post.commentsCount.toString(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color:
                                    isDark
                                        ? const Color(0xFF94A3B8)
                                        : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          _formatDate(post.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:
                                isDark
                                    ? const Color(0xFF64748B)
                                    : Colors.grey[500],
                          ),
                        ),
                        // 如果点赞超过100，在底部中间显示热门Emoji
                        if (hotEmoji.isNotEmpty) ...[
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFF6B35,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  hotEmoji,
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${post.likesCount}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isOwnPost)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showDeleteConfirmation(context),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? const Color(0xFF334155).withOpacity(0.9)
                                : Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18.sp,
                        color:
                            isDark ? const Color(0xFFFF4757) : Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这条帖子吗？此操作无法撤销。'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF4757),
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
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

// ==================== BbsPage 主页面 ====================
class BbsPage extends StatefulWidget {
  const BbsPage({super.key});

  @override
  State<BbsPage> createState() => _BbsPageState();
}

class _BbsPageState extends State<BbsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Category> _categories = [];
  int _selectedCategoryId = 0;

  List<Post> _posts = [];

  List<Post> _myPosts = [];
  bool _showMyPosts = false;

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isLoading = true;
  String? _errorMessage;

  final shared.UserManager userManager = shared.UserManager();

  // 分类对应的彩色Emoji
  final Map<int, String> _categoryEmojis = {
    1: '💬',
    2: '🍽️',
    3: '✈️',
    4: '🎭',
    5: '📌',
    6: '🏨',
    7: '🎪',
    8: '🌿',
  };

  final Map<String, String> _categoryNameEmojis = {
    '酒店住宿': '🏨',
    '美食餐厅': '🍽️',
    '旅游攻略': '✈️',
    '文化体验': '🎭',
    '实用信息': '📌',
    '景点推荐': '🏞️',
    '活动体验': '🎪',
    '自然风光': '🌿',
  };

  // 热门Emoji列表（点赞超过100时显示）
  final List<String> _hotEmojis = [
    '🔥',
    '⭐',
    '🌟',
    '💯',
    '🎉',
    '🏆',
    '👑',
    '💪',
    '✨',
    '🌈',
  ];

  String _getHotEmoji(int likesCount) {
    if (likesCount < 100) return '';
    if (likesCount >= 500) return '👑';
    if (likesCount >= 300) return '🏆';
    if (likesCount >= 200) return '🌟';
    return '🔥';
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${shared.AppConfig.baseWebUrl3004}/api/bbs/categories'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final dataList = decoded['data'] as List<dynamic>? ?? [];

        setState(() {
          _categories = [
            Category(id: 0, name: '全部', description: '全部帖子'),
            ...dataList.map((item) => Category.fromJson(item)),
          ];
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> _fetchPosts({bool isRefresh = false}) async {
    if (_isLoadingMore && !isRefresh) return;
    if (!_hasMore && !isRefresh) return;

    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1;
        _hasMore = true;
        _posts = [];
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final uri = Uri.parse(
        '${shared.AppConfig.baseWebUrl3004}/api/bbs/posts',
      ).replace(
        queryParameters: {
          'page': _currentPage.toString(),
          'limit': _pageSize.toString(),
          if (_selectedCategoryId > 0)
            'category_id': _selectedCategoryId.toString(),
          if (_searchController.text.isNotEmpty)
            'keyword': _searchController.text.trim(),
        },
      );

      debugPrint('请求URL: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        debugPrint('响应数据: ${response.body}');

        final dataMap = decoded['data'] as Map<String, dynamic>? ?? {};
        final dataList = dataMap['list'] as List<dynamic>? ?? [];
        final total = dataMap['total'] as int? ?? 0;

        final newPosts = dataList.map((item) => Post.fromJson(item)).toList();

        setState(() {
          if (isRefresh) {
            _posts = newPosts;
          } else {
            _posts.addAll(newPosts);
          }

          if (newPosts.length < _pageSize || _posts.length >= total) {
            _hasMore = false;
          } else {
            _currentPage++;
          }

          _isLoading = false;
          _isLoadingMore = false;

          if (_posts.isEmpty) {
            _errorMessage = '未找到相关帖子';
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = '加载失败，请稍后重试';
        });
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        if (_posts.isEmpty) {
          _errorMessage = '网络错误，请检查连接';
        }
      });
    }
  }

  void _searchPosts() {
    _searchFocusNode.unfocus();
    _fetchPosts(isRefresh: true);
  }

  void _onCategorySelected(int categoryId) {
    if (_showMyPosts) {
      setState(() {
        _showMyPosts = false;
      });
    }
    debugPrint('选中分类: $categoryId');
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _fetchPosts(isRefresh: true);
  }

  void _navigateToPostDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BbsDetailsPage(post: post)),
    ).then((_) => _fetchPosts(isRefresh: true));
  }

  void _navigateToPostPage() {
    if (!userManager.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先登录')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BbsPostPage()),
    ).then((_) {
      _fetchPosts(isRefresh: true);
      if (_showMyPosts) {
        _fetchMyPosts();
      }
    });
  }

  Future<void> _deletePost(int postId) async {
    try {
      final response = await http.delete(
        Uri.parse('${shared.AppConfig.baseWebUrl3004}/api/bbs/posts/$postId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('删除成功')));
        _fetchPosts(isRefresh: true);
        if (_showMyPosts) {
          _fetchMyPosts();
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('删除失败，请稍后重试')));
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('网络错误，请检查连接')));
    }
  }

  void _toggleMyPosts() {
    setState(() {
      _showMyPosts = !_showMyPosts;
      if (_showMyPosts) {
        _selectedCategoryId = 0;
        _fetchMyPosts();
      } else {
        _fetchPosts(isRefresh: true);
      }
    });
  }

  Future<void> _fetchMyPosts() async {
    final currentUser = userManager.currentUser;
    if (currentUser == null || currentUser.user_id == null) {
      setState(() {
        _myPosts = [];
        _isLoading = false;
      });
      debugPrint('未检测到有效登录用户，无法获取我的帖子');
      return;
    }

    setState(() {
      _isLoading = true;
      _myPosts = [];
    });

    try {
      final userId = currentUser.user_id!;
      final uri = Uri.parse(
        '${shared.AppConfig.baseWebUrl3004}/api/bbs/posts',
      ).replace(queryParameters: {'user_id': userId.toString()});

      debugPrint('我的留言请求URL: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        List<dynamic> dataList = [];

        if (data is Map<String, dynamic>) {
          dataList = data['list'] as List<dynamic>? ?? [];
        } else if (data is List<dynamic>) {
          dataList = data;
        }

        setState(() {
          _myPosts = dataList.map((item) => Post.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        debugPrint('获取我的帖子失败: ${response.statusCode} ${response.body}');
        setState(() {
          _myPosts = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching my posts: $e');
      setState(() {
        _myPosts = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = shared.AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification &&
              scrollNotification.metrics.extentAfter == 0) {
            if (!_isLoadingMore && _hasMore && !_isLoading && !_showMyPosts) {
              _fetchPosts();
            }
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            // 标题栏 - 添加彩色icon，文字改为深橙色
            SliverAppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.forum, size: 20.sp, color: Colors.white),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '论坛',
                    style: TextStyle(
                      color: const Color(0xFFE67E22), // 深橙色
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              foregroundColor: isDark ? Colors.white : Colors.black,
              shadowColor:
                  isDark ? const Color(0xFF4F46E5).withOpacity(0.3) : null,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 10.w, 16.w, 16.w),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(12.w),
                          border: Border.all(
                            color:
                                isDark
                                    ? const Color(0xFF334155)
                                    : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 12.w),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                decoration: InputDecoration(
                                  hintText: 'Search post or name',
                                  border: InputBorder.none,
                                  filled: isDark,
                                  fillColor:
                                      isDark
                                          ? const Color(0xFF1E293B)
                                          : Colors.white,
                                  hintStyle: TextStyle(
                                    color:
                                        isDark
                                            ? const Color(0xFF94A3B8)
                                            : Colors.grey[500],
                                  ),
                                ),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                onSubmitted: (_) => _searchPosts(),
                              ),
                            ),
                            IconButton(
                              onPressed: _searchPosts,
                              icon: Icon(
                                Icons.search,
                                color:
                                    isDark
                                        ? const Color(0xFF4F46E5)
                                        : const Color(0xFF4F46E5),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            SizedBox(width: 8.w),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF818CF8), Color(0xFF60A5FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.w),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _navigateToPostPage,
                          borderRadius: BorderRadius.circular(12.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  '发帖',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 42.h,
                child:
                    _categories.isEmpty
                        ? const SizedBox.shrink()
                        : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: _categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final category = _categories[0];
                              final isSelected =
                                  !_showMyPosts &&
                                  _selectedCategoryId == category.id;
                              return Padding(
                                padding: EdgeInsets.only(right: 12.w),
                                child: ElevatedButton(
                                  onPressed:
                                      () => _onCategorySelected(category.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isDark
                                            ? (isSelected
                                                ? const Color(0xFF4F46E5)
                                                : const Color(0xFF1E293B))
                                            : (isSelected
                                                ? const Color(0xFF4F46E5)
                                                : Colors.white),
                                    foregroundColor:
                                        isDark
                                            ? (isSelected
                                                ? Colors.white
                                                : const Color(0xFF94A3B8))
                                            : (isSelected
                                                ? Colors.white
                                                : const Color(0xFF4F46E5)),
                                    side: BorderSide(
                                      color: const Color(0xFF4F46E5),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13.w),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 12.h,
                                    ),
                                    elevation: isSelected ? 4 : 0,
                                  ),
                                  child: Text(category.name),
                                ),
                              );
                            }

                            if (index == 1) {
                              final isSelected = _showMyPosts;
                              return Padding(
                                padding: EdgeInsets.only(right: 12.w),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (userManager.isLoggedIn) {
                                      _toggleMyPosts();
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const LoginPage(),
                                        ),
                                      ).then((_) => setState(() {}));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isDark
                                            ? (isSelected
                                                ? const Color(0xFFD4AF37)
                                                : const Color(0xFF1E293B))
                                            : (isSelected
                                                ? const Color(0xFFD4AF37)
                                                : Colors.white),
                                    foregroundColor:
                                        isDark
                                            ? (isSelected
                                                ? Colors.black
                                                : const Color(0xFFD4AF37))
                                            : (isSelected
                                                ? Colors.black
                                                : const Color(0xFFD4AF37)),
                                    side: BorderSide(
                                      color: const Color(0xFFD4AF37),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13.w),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 12.h,
                                    ),
                                    elevation: isSelected ? 4 : 0,
                                  ),
                                  child: const Text('我的留言'),
                                ),
                              );
                            }

                            final category = _categories[index - 1];
                            final isSelected =
                                !_showMyPosts &&
                                _selectedCategoryId == category.id;
                            return Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: ElevatedButton(
                                onPressed:
                                    () => _onCategorySelected(category.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isDark
                                          ? (isSelected
                                              ? const Color(0xFF4F46E5)
                                              : const Color(0xFF1E293B))
                                          : (isSelected
                                              ? const Color(0xFF4F46E5)
                                              : Colors.white),
                                  foregroundColor:
                                      isDark
                                          ? (isSelected
                                              ? Colors.white
                                              : const Color(0xFF94A3B8))
                                          : (isSelected
                                              ? Colors.white
                                              : const Color(0xFF4F46E5)),
                                  side: BorderSide(
                                    color: const Color(0xFF4F46E5),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13.w),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 12.h,
                                  ),
                                  elevation: isSelected ? 4 : 0,
                                ),
                                child: Text(category.name),
                              ),
                            );
                          },
                        ),
              ),
            ),

            if (_showMyPosts && !userManager.isLoggedIn)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login,
                        size: 48,
                        color:
                            isDark
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFF3D5AFE),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '请先登录',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFF3D5AFE),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('去登录'),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_showMyPosts && _isLoading && _posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: const Center(child: CircularProgressIndicator()),
              ),

            if (!_showMyPosts && _errorMessage != null && _posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 14.sp, color: Colors.redAccent),
                  ),
                ),
              ),

            if (!_showMyPosts && _posts.isNotEmpty) ...[
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = _posts[index];
                  return _PostCard(
                    post: post,
                    onTap: () => _navigateToPostDetail(post),
                    onDelete: () => _deletePost(post.id),
                    currentUserId: userManager.currentUser?.user_id,
                    categoryEmojis: _categoryEmojis,
                    categoryNameEmojis: _categoryNameEmojis,
                    getHotEmoji: _getHotEmoji,
                  );
                }, childCount: _posts.length),
              ),

              if (_isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (!_hasMore && _posts.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: Text(
                        '—— 没有更多帖子了 ——',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ),
            ],

            if (_showMyPosts && _myPosts.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = _myPosts[index];
                  return _PostCard(
                    post: post,
                    onTap: () => _navigateToPostDetail(post),
                    onDelete: () => _deletePost(post.id),
                    currentUserId: userManager.currentUser?.user_id,
                    categoryEmojis: _categoryEmojis,
                    categoryNameEmojis: _categoryNameEmojis,
                    getHotEmoji: _getHotEmoji,
                  );
                }, childCount: _myPosts.length),
              ),

            if (_showMyPosts && _myPosts.isEmpty && !_isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.message,
                          size: 48,
                          color:
                              isDark
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFF3D5AFE),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          '暂无留言',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
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
