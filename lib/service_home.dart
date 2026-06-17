// service_home.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourism_in_norway/service_settings.dart';
import 'service_models.dart';
import 'service_api.dart';
import 'service_theme.dart' as theme;
import 'service_product_detail.dart';
import 'service_cart.dart';
import 'service_like.dart';
import 'user_auth.dart';
import 'app_shared.dart';

class ServiceHomePage extends StatefulWidget {
  const ServiceHomePage({super.key});

  @override
  State<ServiceHomePage> createState() => _ServiceHomePageState();
}

class _ServiceHomePageState extends State<ServiceHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ServiceCategory> _categories = [];
  int _selectedCategoryId = 0;
  List<ServiceGoods> _goodsList = [];

  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCategories();
    _loadGoods();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreGoods();
      }
    });
  }

  void _loadUser() async {
    try {
      // 等待一小段时间确保 UserManager 已初始化
      await Future.delayed(Duration.zero);
      final user = UserManager().currentUser;
      setState(() {
        _currentUserId = user?.user_id ?? 0;
      });
      print('✅ 当前用户ID: $_currentUserId');

      // 用户加载完成后，刷新商品列表以显示正确的收藏状态
      if (_currentUserId != null &&
          _currentUserId! > 0 &&
          _goodsList.isNotEmpty) {
        _refreshLikeStatusForCurrentGoods();
      }
    } catch (e) {
      print('加载用户失败: $e');
      _currentUserId = 0;
    }
  }

  // 刷新当前商品列表的收藏状态
  Future<void> _refreshLikeStatusForCurrentGoods() async {
    if (_currentUserId == null || _currentUserId! <= 0) return;
    if (_goodsList.isEmpty) return;

    final goodsIds = _goodsList.map((g) => g.id).toList();
    try {
      final likeStatus = await ServiceApi.batchCheckLikeStatus(
        goodsIds,
        _currentUserId!,
      );

      setState(() {
        for (int i = 0; i < _goodsList.length; i++) {
          final goods = _goodsList[i];
          final isLiked = likeStatus[goods.id] ?? false;
          if (goods.isLiked != isLiked) {
            _goodsList[i] = goods.copyWith(isLiked: isLiked);
          }
        }
      });
      print('✅ 刷新收藏状态完成');
    } catch (e) {
      print('刷新收藏状态失败: $e');
    }
  }

  Future<void> _loadCategories() async {
    final categories = await ServiceApi.getCategories();
    setState(() {
      _categories = [ServiceCategory(id: 0, name: '全部'), ...categories];
    });
  }

  Future<void> _loadGoods({bool isRefresh = false}) async {
    if (_isLoadingMore && !isRefresh) return;
    if (!_hasMore && !isRefresh) return;

    setState(() {
      if (isRefresh) {
        _isLoading = true;
        _currentPage = 1;
        _hasMore = true;
        _goodsList = [];
        _errorMessage = null;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final result = await ServiceApi.getGoods(
        page: _currentPage,
        limit: _pageSize,
        keyword:
            _searchController.text.isNotEmpty ? _searchController.text : null,
        categoryId: _selectedCategoryId > 0 ? _selectedCategoryId : null,
      );

      if (result.containsKey('code') && result['code'] == 200) {
        final data = result['data'];
        final List<dynamic> list = data['list'] ?? [];
        final total = data['total'] ?? 0;

        List<ServiceGoods> newGoods =
            list.map((item) => ServiceGoods.fromJson(item)).toList();

        // 获取当前用户的收藏状态
        if (_currentUserId != null &&
            _currentUserId! > 0 &&
            newGoods.isNotEmpty) {
          final goodsIds = newGoods.map((g) => g.id).toList();
          final likeStatus = await ServiceApi.batchCheckLikeStatus(
            goodsIds,
            _currentUserId!,
          );

          for (var goods in newGoods) {
            goods.isLiked = likeStatus[goods.id] ?? false;
          }
          print('✅ 收藏状态加载完成: ${likeStatus.length} 个商品');
        }

        setState(() {
          if (isRefresh) {
            _goodsList = newGoods;
          } else {
            _goodsList.addAll(newGoods);
          }
          _hasMore = _goodsList.length < total;
          _currentPage++;
          _isLoading = false;
          _isLoadingMore = false;

          if (_goodsList.isEmpty) {
            _errorMessage = '暂无商品';
          }
        });
      } else {
        final errorMsg = result['message'] ?? '加载失败，请稍后重试';
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = errorMsg;
        });
      }
    } catch (e) {
      print('❌ 网络请求异常: $e');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = '网络错误: $e';
      });
    }
  }

  void _loadMoreGoods() {
    if (!_isLoadingMore && _hasMore && !_isLoading) {
      _loadGoods();
    }
  }

  void _searchGoods() {
    FocusScope.of(context).unfocus();
    _loadGoods(isRefresh: true);
    _searchController.clear();
  }

  void _onCategorySelected(int categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _loadGoods(isRefresh: true);
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ServiceCartPage()),
    ).then((_) => _loadGoods(isRefresh: true));
  }

  void _navigateToLike() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ServiceLikePage()),
    ).then((_) => _loadGoods(isRefresh: true));
  }

  void _navigateToSettings() {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final themeMode =
        brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServiceSettings(themeMode: themeMode)),
    ).then((_) => _loadGoods(isRefresh: true));
  }

  void _goLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    ).then((_) {
      _loadUser();
      _loadGoods(isRefresh: true);
    });
  }

  void _navigateToDetail(ServiceGoods goods) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServiceProductDetailPage(goods: goods)),
    ).then((_) => _loadGoods(isRefresh: true));
  }

  void _toggleLike(ServiceGoods goods) async {
    // 检查登录状态
    if (_currentUserId == null || _currentUserId == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先登录')));
      _goLogin();
      return;
    }

    final index = _goodsList.indexWhere((g) => g.id == goods.id);
    if (index == -1) return;

    // 保存当前状态
    final currentGoods = _goodsList[index];
    final newIsLiked = !currentGoods.isLiked;
    final newLikeCount =
        newIsLiked ? currentGoods.likeCount + 1 : currentGoods.likeCount - 1;

    // 乐观更新 UI
    setState(() {
      _goodsList[index] = currentGoods.copyWith(
        isLiked: newIsLiked,
        likeCount: newLikeCount,
      );
    });

    try {
      // 调用 API
      final success = await ServiceApi.toggleLike(goods.id, _currentUserId!);

      if (!success) {
        // 失败时恢复原状态
        setState(() {
          _goodsList[index] = currentGoods;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('操作失败，请稍后重试')));
      }
    } catch (e) {
      // 异常时恢复原状态
      setState(() {
        _goodsList[index] = currentGoods;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('网络错误，请检查连接')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? theme.ServiceMetalColors.darkBg
              : theme.ServiceMetalColors.lightBg,
      body: NestedScrollView(
        key: ValueKey(_categories.length),
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverHeaderDelegate(
                headerContent: _buildHeaderContent(isDark),
                backgroundColor:
                    isDark
                        ? theme.ServiceMetalColors.darkBg
                        : theme.ServiceMetalColors.lightBg,
              ),
            ),
          ];
        },
        body: _buildGoodsList(isDark),
      ),
    );
  }

  Widget _buildHeaderContent(bool isDark) {
    return Column(
      children: [
        // 顶部栏（搜索框、收藏、购物篮、设置）
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 4.h, // 上移6px（原10h改为4h）
          ),
          child: Row(
            children: [
              Expanded(flex: 6, child: _buildSearchBar(isDark)),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.deepPurple,
                  ),
                  onPressed: _navigateToLike,
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Colors.deepPurple,
                  ),
                  onPressed: _navigateToCart,
                ),
              ),
              SizedBox(width: 5.w),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(Icons.settings, color: Colors.deepPurple),
                  onPressed: _navigateToSettings,
                ),
              ),
            ],
          ),
        ),
        // 分类栏
        _buildCategoryBar(isDark),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color:
            isDark
                ? theme.ServiceMetalColors.darkSurface
                : theme.ServiceMetalColors.lightSurface,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow:
            isDark
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ]
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
        border: isDark ? Border.all(color: Colors.grey[700]!) : null,
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(
            Icons.search,
            color: isDark ? theme.ServiceMetalColors.primary : Colors.grey,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Service...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color:
                      isDark
                          ? theme.ServiceMetalColors.darkTextSecondary
                          : theme.ServiceMetalColors.lightTextSecondary,
                ),
              ),
              style: TextStyle(
                color:
                    isDark
                        ? theme.ServiceMetalColors.darkText
                        : theme.ServiceMetalColors.lightText,
              ),
              onSubmitted: (_) => _searchGoods(),
            ),
          ),
          TextButton(
            onPressed: _searchGoods,
            child: Text(
              'Search',
              style: TextStyle(
                color:
                    isDark
                        ? theme.ServiceMetalColors.primary
                        : theme.ServiceMetalColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(bool isDark) {
    return SizedBox(
      height: 35.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryId == category.id;

          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: _buildCategoryButton(
              category.name,
              isSelected,
              isDark,
              () => _onCategorySelected(category.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryButton(
    String title,
    bool isSelected,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color:
              isSelected && !isDark
                  ? theme.ServiceMetalColors.primary
                  : (isDark
                      ? theme.ServiceMetalColors.darkSurface
                      : theme.ServiceMetalColors.lightSurface),
          border: Border.all(
            color:
                isSelected
                    ? theme.ServiceMetalColors.primary
                    : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
            width: 1.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color:
                isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark
                        ? theme.ServiceMetalColors.darkText
                        : theme.ServiceMetalColors.lightText),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildGoodsList(bool isDark) {
    if (_isLoading && _goodsList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _goodsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: isDark ? theme.ServiceMetalColors.primary : Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              _errorMessage!,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => _loadGoods(isRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.ServiceMetalColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(12.w, 12.w, 12.w, 100.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 27.w,
        mainAxisSpacing: 70.h,
      ),
      shrinkWrap: false,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _goodsList.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _goodsList.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child:
                  _isLoadingMore
                      ? const CircularProgressIndicator()
                      : Text(
                        '—— 加载更多 ——',
                        style: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey[400],
                        ),
                      ),
            ),
          );
        }
        return _buildGoodsCard(_goodsList[index], isDark);
      },
    );
  }

  Widget _buildGoodsCard(ServiceGoods goods, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateToDetail(goods),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color:
              isDark
                  ? theme.ServiceMetalColors.darkSurface
                  : theme.ServiceMetalColors.lightSurface,
          boxShadow:
              isDark
                  ? [
                    BoxShadow(
                      color: theme.ServiceMetalColors.primary.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: -4,
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
          border:
              isDark
                  ? Border.all(
                    color: theme.ServiceMetalColors.primary.withOpacity(0.3),
                  )
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Stack(
                children: [
                  Image.network(
                    goods.mainImage ?? 'https://picsum.photos/id/0/400/400',
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          height: 180.h,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                  // 评分标签
                  if (goods.score > 0)
                    Positioned(
                      top: 8.w,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              theme.ServiceMetalColors.gold,
                              theme.ServiceMetalColors.bronze,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 12.sp, color: Colors.white),
                            SizedBox(width: 4.w),
                            Text(
                              '${goods.score}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 商品信息
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goods.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark
                              ? theme.ServiceMetalColors.darkText
                              : theme.ServiceMetalColors.lightText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    goods.shortDescription ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color:
                          isDark
                              ? theme.ServiceMetalColors.darkTextSecondary
                              : theme.ServiceMetalColors.lightTextSecondary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Text(
                        '¥${goods.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                          color: theme.ServiceMetalColors.primary,
                        ),
                      ),
                      if (goods.originalPrice != null)
                        Padding(
                          padding: EdgeInsets.only(left: 8.w),
                          child: Text(
                            '¥${goods.originalPrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              decoration: TextDecoration.lineThrough,
                              color:
                                  isDark
                                      ? theme
                                          .ServiceMetalColors
                                          .darkTextTertiary
                                      : theme
                                          .ServiceMetalColors
                                          .lightTextTertiary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '销量 ${goods.salesCount}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color:
                              isDark
                                  ? theme.ServiceMetalColors.darkTextTertiary
                                  : theme.ServiceMetalColors.lightTextTertiary,
                        ),
                      ),
                      _buildLikeButton(
                        goods.likeCount,
                        goods.isLiked,
                        isDark,
                        () => _toggleLike(goods),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton(
    int count,
    bool isLiked,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            size: 14.sp,
            color:
                isLiked
                    ? theme.ServiceMetalColors.accent
                    : (isDark
                        ? theme.ServiceMetalColors.darkTextSecondary
                        : Colors.grey),
          ),
          SizedBox(width: 4.w),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 10.sp,
              color:
                  isDark
                      ? theme.ServiceMetalColors.darkTextSecondary
                      : theme.ServiceMetalColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// 分类栏 SliverPersistentHeader 代理
class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget headerContent;
  final Color backgroundColor;

  _SliverHeaderDelegate({
    required this.headerContent,
    required this.backgroundColor,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: headerContent);
  }

  @override
  double get maxExtent => 100.h;

  @override
  double get minExtent => 100.h;

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor ||
        headerContent != oldDelegate.headerContent;
  }
}
