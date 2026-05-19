import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'app_shared.dart' as shared;
import 'bbsDetails.dart';
import 'bbsPost.dart';
import 'auth.dart';

class BbsPage extends StatefulWidget {
  const BbsPage({super.key});

  @override
  State<BbsPage> createState() => _BbsPageState();
}

class _BbsPageState extends State<BbsPage> {
  final TextEditingController _searchController = TextEditingController();
  
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
  
  final UserManager = shared.UserManager();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchPosts();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://www.pavogroup.top:3004/api/categories'));
      
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
      final uri = Uri.parse('http://www.pavogroup.top:3004/api/posts').replace(
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
    _fetchPosts(isRefresh: true);
  }

  void _onCategorySelected(int categoryId) {
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
      Uri.parse('http://www.pavogroup.top:3004/api/posts/$postId'),
    );
    
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除成功')),
      );
      _fetchPosts(isRefresh: true);
      if (_showMyPosts) {
        _fetchMyPosts();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除失败，请稍后重试')),
      );
    }
  } catch (e) {
    debugPrint('Error deleting post: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('网络错误，请检查连接')),
    );
  }
}
  
  void _toggleMyPosts() {
    setState(() {
      _showMyPosts = !_showMyPosts;
      if (_showMyPosts) {
        _fetchMyPosts();
      }
    });
  }
  
  Future<void> _fetchMyPosts() async {
    final currentUser = UserManager.currentUser;
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
      final uri = Uri.parse('http://www.pavogroup.top:3004/api/posts').replace(
        queryParameters: {
          'user_id': userId.toString(),
          'id': userId.toString(),
        },
      );

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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToPostPage,
        child: const Icon(Icons.add),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification &&
              scrollNotification.metrics.extentAfter == 0) {
            if (!_isLoadingMore && _hasMore && !_isLoading) {
              _fetchPosts();
            }
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('论坛'),
              pinned: true,
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  onPressed: () {
                    if (UserManager.isLoggedIn) {
                      _toggleMyPosts();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      ).then((_) => setState(() {}));
                    }
                  },
                  icon: const Icon(Icons.message),
                  tooltip: '我的留言',
                ),
              ],
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (UserManager.isLoggedIn) {
                            _toggleMyPosts();
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            ).then((_) => setState(() {}));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showMyPosts
                              ? const Color(0xFF3D5AFE)
                              : Colors.white,
                          foregroundColor: _showMyPosts
                              ? Colors.white
                              : const Color(0xFF3D5AFE),
                          side: const BorderSide(
                            color: Color(0xFF3D5AFE),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                        ),
                        child: const Text('我的留言'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Container(
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
                  child: Row(
                    children: [
                      SizedBox(width: 12.w),
                      const Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: '搜索帖子或用户名',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _searchPosts(),
                        ),
                      ),
                      TextButton(
                        onPressed: _searchPosts,
                        child: const Text('搜索'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            if (!_showMyPosts)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 56.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategoryId == category.id;
                      return Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: ElevatedButton(
                          onPressed: () => _onCategorySelected(category.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color(0xFF3D5AFE)
                                : Colors.white,
                            foregroundColor: isSelected
                                ? Colors.white
                                : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.w),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: Text(category.name),
                        ),
                      );
                    },
                  ),
                ),
              ),
            
            if (_showMyPosts && !UserManager.isLoggedIn)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.login,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '请先登录',
                        style: TextStyle(fontSize: 16.sp),
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
                        child: const Text('去登录'),
                      ),
                    ],
                  ),
                ),
              )
            
            else if (_isLoading && _posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: const Center(child: CircularProgressIndicator()),
              )
            
            else if (_errorMessage != null && _posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 14.sp, color: Colors.redAccent),
                  ),
                ),
              )
            
            else ...[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = _showMyPosts ? _myPosts[index] : _posts[index];
                    return _PostCard(
                      post: post,
                      onTap: () => _navigateToPostDetail(post),
                      onDelete: () => _deletePost(post.id),
                    );
                  },
                  childCount: _showMyPosts ? _myPosts.length : _posts.length,
                ),
              ),
              
              if (!_showMyPosts) ...[
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
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
              ],
              
              if (_showMyPosts && _myPosts.isEmpty && !_isLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.message,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            '暂无留言',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class Category {
  final int id;
  final String name;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

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
        } catch (_) {
        }
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
}

class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PostCard({
    required this.post,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final userManager = shared.UserManager();
    final isLoggedIn = userManager.isLoggedIn;
    final currentUserName = userManager.currentUser?.name ?? '';
    // 只在当前用户自己的帖子中显示删除按钮
    final isOwnPost = isLoggedIn && post.authorName == currentUserName;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.w),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                
                Text(
                  post.content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                
                if (post.images.isNotEmpty)
                  SizedBox(
                    height: 80.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: post.images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Image.network(
                            post.images[index],
                            width: 80.w,
                            height: 80.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80.w,
                                height: 80.h,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 12.h),
                
                // DELETE按钮（仅当前用户自己的帖子显示）
                if (isOwnPost)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        _showDeleteConfirmation(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: const Color(0xFFEF4444),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.w),
                          side: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.delete_outline, size: 14),
                          SizedBox(width: 4.w),
                          Text(
                            '删除',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (isOwnPost) SizedBox(height: 8.h),
                
                Row(
                  children: [
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
                        post.categoryName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF4338CA),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      post.authorName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.thumb_up, size: 14.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          post.likesCount.toString(),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        SizedBox(width: 16.w),
                        Icon(Icons.comment, size: 14.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          post.commentsCount.toString(),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDate(post.createdAt),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
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