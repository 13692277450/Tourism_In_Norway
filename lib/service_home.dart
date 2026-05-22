// service_home.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'service_models.dart';
import 'service_api.dart';
import 'service_theme.dart';
import 'service_product_detail.dart';
import 'service_cart.dart';
import '../auth.dart';

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
      _errorMessage = '网络错误: ${e.toString()}';
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
      backgroundColor: isDark ? ServiceNeonColors.darkBg : ServiceNeonColors.lightBg,
      appBar: AppBar(
        title: Text(
          '霓虹商城',
          style: TextStyle(
            color: isDark ? ServiceNeonColors.cyan : ServiceNeonColors.darkText,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: isDark ? [
              Shadow(color: ServiceNeonColors.cyan, blurRadius: 10),
              Shadow(color: ServiceNeonColors.magenta, blurRadius: 5),
            ] : null,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, 
                  color: isDark ? ServiceNeonColors.cyan : ServiceNeonColors.darkText),
                onPressed: _navigateToCart,
              ),
              // 购物车数量角标（可选）
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(isDark),
          // 分类按钮
          _buildCategoryBar(isDark),
          // 商品列表
          Expanded(
            child: _buildGoodsList(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? ServiceNeonColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: isDark ? [
          BoxShadow(color: ServiceNeonColors.cyan.withOpacity(0.3), blurRadius: 10),
          BoxShadow(color: ServiceNeonColors.magenta.withOpacity(0.2), blurRadius: 5),
        ] : [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
        border: isDark ? Border.all(color: ServiceNeonColors.cyan.withOpacity(0.5)) : null,
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(Icons.search, color: isDark ? ServiceNeonColors.cyan : Colors.grey),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索商品...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              onSubmitted: (_) => _searchGoods(),
            ),
          ),
          TextButton(
            onPressed: _searchGoods,
            child: Text('搜索', style: TextStyle(color: isDark ? ServiceNeonColors.cyan : ServiceNeonColors.cyan)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(bool isDark) {
    return SizedBox(
      height: 48.h,
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
              ? LinearGradient(colors: [ServiceNeonColors.cyan, ServiceNeonColors.magenta])
              : null,
          color: isSelected && !isDark
              ? ServiceNeonColors.cyan
              : (isDark ? ServiceNeonColors.darkSurface : Colors.white),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : ServiceNeonColors.cyan)
                : (isDark ? ServiceNeonColors.cyan.withOpacity(0.5) : Colors.grey[300]!),
            width: 1.5,
          ),
          boxShadow: isSelected && isDark ? [
            BoxShadow(color: ServiceNeonColors.cyan, blurRadius: 15, spreadRadius: 2),
            BoxShadow(color: ServiceNeonColors.magenta, blurRadius: 10, spreadRadius: 1),
          ] : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? ServiceNeonColors.cyan : ServiceNeonColors.darkText),
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
            Icon(Icons.error_outline, size: 48, color: isDark ? ServiceNeonColors.cyan : Colors.grey),
            SizedBox(height: 16.h),
            Text(_errorMessage!, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => _loadGoods(isRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ServiceNeonColors.cyan,
                foregroundColor: Colors.black,
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(12.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.w,
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
          color: isDark ? ServiceNeonColors.darkSurface : Colors.white,
          boxShadow: isDark ? [
            BoxShadow(color: ServiceNeonColors.cyan.withOpacity(0.2), blurRadius: 12, spreadRadius: -4),
          ] : [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, spreadRadius: 2),
          ],
          border: isDark ? Border.all(color: ServiceNeonColors.cyan.withOpacity(0.3)) : null,
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
                    height: 160.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160.h,
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
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [ServiceNeonColors.amber, ServiceNeonColors.magenta],
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
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    goods.shortDescription ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '¥${goods.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? ServiceNeonColors.cyan : ServiceNeonColors.cyan,
                          shadows: isDark ? [
                            Shadow(color: ServiceNeonColors.cyan, blurRadius: 8),
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
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '销量 ${goods.salesCount}',
                        style: TextStyle(fontSize: 10.sp, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      ),
                      _buildNeonIcon(Icons.favorite_border, goods.likeCount, isDark),
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

  Widget _buildNeonIcon(IconData icon, int count, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: isDark ? ServiceNeonColors.magenta : Colors.grey),
        SizedBox(width: 4.w),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 10.sp, color: isDark ? Colors.grey[400] : Colors.grey[500]),
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