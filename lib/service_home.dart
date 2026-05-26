// service_home.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'service_models.dart';
import 'service_api.dart';
import 'service_theme.dart' as theme;
import 'service_product_detail.dart';
import 'service_cart.dart';

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

  void _loadUser() {
    // 从您的UserManager获取当前用户ID
    // 这里需要根据您的实际Auth实现来获取
    // 示例：_currentUserId = userManager.currentUser?.id;
  }

  Future<void> _loadCategories() async {
    final categories = await ServiceApi.getCategories();
    setState(() {
      _categories = [
        ServiceCategory(id: 0, name: '全部'),
        ...categories,
      ];
    });
  }
// service_home.dart - 修改 _loadGoods 方法

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
    print('🔄 开始加载商品，页码: $_currentPage, 分类: $_selectedCategoryId');
    
    final result = await ServiceApi.getGoods(
      page: _currentPage,
      limit: _pageSize,
      keyword: _searchController.text.isNotEmpty ? _searchController.text : null,
      categoryId: _selectedCategoryId > 0 ? _selectedCategoryId : null,
    );

    print('📦 API返回结果: $result');

    // 检查返回结果的格式
    if (result.containsKey('code') && result['code'] == 200) {
      final data = result['data'];
      final List<dynamic> list = data['list'] ?? [];
      final total = data['total'] ?? 0;
      
      print('✅ 获取到 ${list.length} 条商品，总计 $total 条');
      
      final newGoods = list.map((item) => ServiceGoods.fromJson(item)).toList();
      
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
      // 处理错误响应
      final errorMsg = result['message'] ?? '加载失败，请稍后重试';
      print('❌ API返回错误: $errorMsg');
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = errorMsg;
      });
    }
  } catch (e, stackTrace) {
    // 捕获异常并打印详细堆栈
    print('❌ 网络请求异常: $e');
    print('📚 堆栈信息: $stackTrace');
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
  }

  void _onCategorySelected(int categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _loadGoods(isRefresh: true);
  }

  void _navigateToCart() {
    // 检查登录状态
    // if (!isLoggedIn) {
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    //   return;
    // }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ServiceCartPage()),
    ).then((_) => _loadGoods(isRefresh: true));
  }

  void _navigateToDetail(ServiceGoods goods) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServiceProductDetailPage(goods: goods)),
    ).then((_) => _loadGoods(isRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? theme.ServiceMetalColors.darkBg : theme.ServiceMetalColors.lightBg,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: isDark ? theme.ServiceMetalColors.darkBg : theme.ServiceMetalColors.lightBg,
              elevation: 0,
              pinned: true,
              floating: true,
              snap: true,
              expandedHeight: 120.h,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: EdgeInsets.only(top: 40.h),
                  color: isDark ? theme.ServiceMetalColors.darkBg : theme.ServiceMetalColors.lightBg,
                  child: Column(
                    children: [
                      // 搜索栏
                      _buildSearchBar(isDark),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverCategoryDelegate(
                categoryBar: _buildCategoryBar(isDark),
                backgroundColor: isDark ? theme.ServiceMetalColors.darkBg : theme.ServiceMetalColors.lightBg,
              ),
            ),
          ];
        },
        body: _buildGoodsList(isDark),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? theme.ServiceMetalColors.darkSurface : theme.ServiceMetalColors.lightSurface,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: isDark ? [
          BoxShadow(color: theme.ServiceMetalColors.primary.withOpacity(0.3), blurRadius: 10),
          BoxShadow(color: theme.ServiceMetalColors.accent.withOpacity(0.2), blurRadius: 5),
        ] : [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
        border: isDark ? Border.all(color: theme.ServiceMetalColors.primary.withOpacity(0.5)) : null,
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(Icons.search, color: isDark ? theme.ServiceMetalColors.primary : Colors.grey),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Service...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: isDark ? theme.ServiceMetalColors.darkTextSecondary : theme.ServiceMetalColors.lightTextSecondary),
              ),
              style: TextStyle(color: isDark ? theme.ServiceMetalColors.darkText : theme.ServiceMetalColors.lightText),
              onSubmitted: (_) => _searchGoods(),
            ),
          ),
          TextButton(
            onPressed: _searchGoods,
            child: Text('Search', style: TextStyle(color: isDark ? theme.ServiceMetalColors.primary : theme.ServiceMetalColors.primary)),
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

  Widget _buildCategoryButton(String title, bool isSelected, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: isSelected && isDark
              ? LinearGradient(colors: [theme.ServiceMetalColors.primary, theme.ServiceMetalColors.accent])
              : null,
          color: isSelected && !isDark
              ? theme.ServiceMetalColors.primary
              : (isDark ? theme.ServiceMetalColors.darkSurface : theme.ServiceMetalColors.lightSurface),
          border: Border.all(
            color: isSelected
                ? (isDark ? theme.ServiceMetalColors.silver : theme.ServiceMetalColors.primary)
                : (isDark ? theme.ServiceMetalColors.primary.withOpacity(0.5) : Colors.grey[300]!),
            width: 1.5,
          ),
          boxShadow: isSelected && isDark ? [
            BoxShadow(color: theme.ServiceMetalColors.primary, blurRadius: 15, spreadRadius: 2),
            BoxShadow(color: theme.ServiceMetalColors.accent, blurRadius: 10, spreadRadius: 1),
          ] : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? theme.ServiceMetalColors.darkText : theme.ServiceMetalColors.lightText),
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
            Icon(Icons.error_outline, size: 48, color: isDark ? theme.ServiceMetalColors.primary : Colors.grey),
            SizedBox(height: 16.h),
            Text(_errorMessage!, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
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
      padding: EdgeInsets.all(12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 27.w,
      ),
      itemCount: _goodsList.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _goodsList.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: _isLoadingMore
                  ? const CircularProgressIndicator()
                  : Text('—— 加载更多 ——', style: TextStyle(color: isDark ? Colors.grey : Colors.grey[400])),
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
          color: isDark ? theme.ServiceMetalColors.darkSurface : theme.ServiceMetalColors.lightSurface,
          boxShadow: isDark ? [
            BoxShadow(color: theme.ServiceMetalColors.primary.withOpacity(0.2), blurRadius: 12, spreadRadius: -4),
          ] : [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, spreadRadius: 2),
          ],
          border: isDark ? Border.all(color: theme.ServiceMetalColors.primary.withOpacity(0.3)) : null,
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
                    errorBuilder: (_, __, ___) => Container(
                      height: 180.h,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                    ),
                  ),
                  // 评分标签
                  if (goods.score > 0)
                    Positioned(
                      top: 8.w,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [theme.ServiceMetalColors.gold, theme.ServiceMetalColors.bronze],
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
                              style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold),
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
                      color: isDark ? theme.ServiceMetalColors.darkText : theme.ServiceMetalColors.lightText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    goods.shortDescription ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? theme.ServiceMetalColors.darkTextSecondary : theme.ServiceMetalColors.lightTextSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '¥${goods.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                          color: isDark ? theme.ServiceMetalColors.primary : theme.ServiceMetalColors.primary,
                          shadows: isDark ? [
                            Shadow(color: theme.ServiceMetalColors.primary, blurRadius: 8),
                          ] : null,
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
                              color: isDark ? theme.ServiceMetalColors.darkTextTertiary : theme.ServiceMetalColors.lightTextTertiary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '销量 ${goods.salesCount}',
                        style: TextStyle(fontSize: 10.sp, color: isDark ? theme.ServiceMetalColors.darkTextTertiary : theme.ServiceMetalColors.lightTextTertiary),
                      ),
                      _buildMetalIcon(Icons.favorite_border, goods.likeCount, isDark),
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

  Widget _buildMetalIcon(IconData icon, int count, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: isDark ? theme.ServiceMetalColors.accent : Colors.grey),
        SizedBox(width: 4.w),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 10.sp, color: isDark ? theme.ServiceMetalColors.darkTextSecondary : theme.ServiceMetalColors.lightTextSecondary),
        ),
      ],
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
class _SliverCategoryDelegate extends SliverPersistentHeaderDelegate {
  final Widget categoryBar;
  final Color backgroundColor;

  _SliverCategoryDelegate({
    required this.categoryBar,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: categoryBar,
    );
  }

  @override
  double get maxExtent => 35.h;

  @override
  double get minExtent => 35.h;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}