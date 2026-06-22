// service_home.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourism_in_norway/settings_home.dart';
import 'service_models.dart';
import 'service_api.dart';
import 'service_theme.dart' as theme;
import 'service_product_detail.dart';
import 'service_cart.dart';
import 'service_like.dart';
import 'user_auth.dart';
import 'app_shared.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';

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
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int? _currentUserId;

  final Set<int> _loadedImageIds = {};

  // 分类对应的彩色Emoji映射
  final Map<String, String> _categoryEmojis = {
    '全部': '📦',
    '电子产品': '📱',
    '服装服饰': '👔',
    '服装配饰': '👔',
    '其他': '📌',
    '服务': '🚀',
    '食品饮料': '🍜',
    '家居生活': '🏠',
    '美妆护肤': '💄',
    '母婴玩具': '👶',
    '运动户外': '⚽',
    '图书文具': '📚',
    '汽车用品': '🚗',
    '宠物用品': '🐾',
    '珠宝首饰': '💎',
    '数码配件': '🔌',
    '家用电器': '📺',
    '办公耗材': '🖊️',
    '鞋靴箱包': '👟',
    '床上用品': '🛏️',
    '厨房用具': '🍳',
    '个护清洁': '🧴',
    '乐器音像': '🎵',
    '手机通讯': '📱',
    '电脑办公': '💻',
    '摄影摄像': '📷',
    '餐厅美食': '🍽',
  };

  // 获取分类对应的Emoji
  String _getCategoryEmoji(String categoryName) {
    for (final entry in _categoryEmojis.entries) {
      if (categoryName.contains(entry.key)) {
        return entry.value;
      }
    }
    // 默认返回
    return '📌';
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCategories();
    _loadGoods(isRefresh: true);

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll - 200) {
        _loadMoreGoods();
      }
    }
  }

  void _loadUser() async {
    try {
      await Future.delayed(Duration.zero);
      final user = UserManager().currentUser;
      setState(() {
        _currentUserId = user?.user_id ?? 0;
      });
      print('✅ 当前用户ID: $_currentUserId');

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
        _loadedImageIds.clear();
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

        newGoods.sort((a, b) => b.id.compareTo(a.id));

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
            final existingIds = _goodsList.map((g) => g.id).toSet();
            final uniqueNewGoods =
                newGoods.where((g) => !existingIds.contains(g.id)).toList();
            _goodsList.addAll(uniqueNewGoods);
            _goodsList.sort((a, b) => b.id.compareTo(a.id));
          }

          final totalLoaded = _goodsList.length;
          if (newGoods.isEmpty || totalLoaded >= total) {
            _hasMore = false;
          } else {
            _currentPage++;
            _hasMore = true;
          }

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
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        if (isRefresh || _goodsList.isEmpty) {
          _errorMessage = '网络错误，请检查连接';
        }
      });
    }
  }

  void _loadMoreGoods() {
    if (!_isLoadingMore && _hasMore && !_isLoading) {
      print('🔄 加载更多数据，当前页: $_currentPage');
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

    // 获取当前语言
    final locale = Localizations.localeOf(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => SettingsPage(
              locale: locale,
              onLocaleChanged: (newLocale) {},
              themeMode: themeMode,
              onThemeModeChanged: (newThemeMode) {},
            ),
      ),
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
    if (_currentUserId == null || _currentUserId == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先登录')));
      _goLogin();
      return;
    }

    final index = _goodsList.indexWhere((g) => g.id == goods.id);
    if (index == -1) return;

    final currentGoods = _goodsList[index];
    final newIsLiked = !currentGoods.isLiked;
    final newLikeCount =
        newIsLiked ? currentGoods.likeCount + 1 : currentGoods.likeCount - 1;

    setState(() {
      _goodsList[index] = currentGoods.copyWith(
        isLiked: newIsLiked,
        likeCount: newLikeCount,
      );
    });

    try {
      final success = await ServiceApi.toggleLike(goods.id, _currentUserId!);

      if (!success) {
        setState(() {
          _goodsList[index] = currentGoods;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('操作失败，请稍后重试')));
      }
    } catch (e) {
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
      body: Column(
        children: [
          _buildHeaderContent(isDark),
          Expanded(child: _buildGoodsList(isDark)),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(bool isDark) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 4.h,
          ),
          child: Row(
            children: [
              Expanded(flex: 6, child: _buildSearchBar(isDark)),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.orange),
                  onPressed: _navigateToLike,
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.orange),
                  onPressed: _navigateToCart,
                ),
              ),
              SizedBox(width: 5.w),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.orange),
                  onPressed: _navigateToSettings,
                ),
              ),
            ],
          ),
        ),
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
        borderRadius: BorderRadius.circular(22.r),
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
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                filled: isDark,
                fillColor:
                    isDark
                        ? theme.ServiceMetalColors.darkSurface
                        : theme.ServiceMetalColors.lightSurface,
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
          GestureDetector(
            onTap: _searchGoods,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Icon(
                Icons.search,
                color: isDark ? theme.ServiceMetalColors.primary : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(bool isDark) {
    if (_categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 35.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryId == category.id;
          final emoji = _getCategoryEmoji(category.name);

          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: _buildCategoryButton(
              category.name,
              emoji,
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
    String emoji,
    bool isSelected,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.r),
          gradient:
              isSelected
                  ? const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : isDark
                  ? const LinearGradient(
                    colors: [Color(0xFF374151), Color(0xFF1F2937)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : const LinearGradient(
                    colors: [Color(0xFFF0F4FF), Color(0xFFE8EDF5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          border: Border.all(
            color:
                isSelected
                    ? Colors.transparent
                    : isDark
                    ? Colors.grey[600]!
                    : const Color(0xFFD1D9E6),
            width: 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.35),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: 14.sp)),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : isDark
                        ? theme.ServiceMetalColors.darkText
                        : const Color(0xFF2D3748),
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
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
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(9.w, 8.h, 9.w, 90.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.68,
      ),
      itemCount: _goodsList.length + 1,
      itemBuilder: (context, index) {
        if (index == _goodsList.length) {
          if (_isLoadingMore) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: const Center(child: CircularProgressIndicator()),
            );
          } else if (!_hasMore && _goodsList.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  'No more data',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }

        final goods = _goodsList[index];
        return _buildGoodsCard(goods, isDark);
      },
    );
  }

  Widget _buildGoodsCard(ServiceGoods goods, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateToDetail(goods),
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // 商品图片
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        goods.mainImage ?? 'https://picsum.photos/id/0/400/400',
                    height: 150.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 300),
                    fadeOutDuration: const Duration(milliseconds: 150),
                    placeholder:
                        (context, url) => Container(
                          height: 150.h,
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.ServiceMetalColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          height: 150.h,
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                    cacheKey:
                        goods.mainImage != null
                            ? 'goods_${goods.id}_${goods.mainImage!.hashCode}'
                            : null,
                  ),
                  // 评分标签
                  if (goods.score > 0)
                    Positioned(
                      top: 8.w,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              theme.ServiceMetalColors.gold,
                              theme.ServiceMetalColors.bronze,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 10.sp, color: Colors.white),
                            SizedBox(width: 2.w),
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
            // 商品信息 - 使用Expanded确保内容不溢出
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 商品名称
                    Flexible(
                      child: Text(
                        goods.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color:
                              isDark
                                  ? theme.ServiceMetalColors.darkText
                                  : theme.ServiceMetalColors.lightText,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // 简短描述
                    if (goods.shortDescription != null &&
                        goods.shortDescription!.isNotEmpty)
                      Flexible(
                        child: Text(
                          goods.shortDescription!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color:
                                isDark
                                    ? theme.ServiceMetalColors.darkTextSecondary
                                    : theme
                                        .ServiceMetalColors
                                        .lightTextSecondary,
                          ),
                        ),
                      ),
                    SizedBox(height: 6.h),
                    // 价格行
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '¥${goods.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.ServiceMetalColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (goods.originalPrice != null)
                          Padding(
                            padding: EdgeInsets.only(left: 4.w),
                            child: Text(
                              '¥${goods.originalPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 10.sp,
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
                    SizedBox(height: 6.h),
                    // 销量和点赞行
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
                                    : theme
                                        .ServiceMetalColors
                                        .lightTextTertiary,
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
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(width: 3.w),
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
