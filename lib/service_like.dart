// service_like.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'service_models.dart';
import 'service_api.dart';
import 'service_theme.dart' as theme;
import 'service_product_detail.dart';
import 'user_auth.dart';
import 'app_shared.dart' as shared;

class ServiceLikePage extends StatefulWidget {
  const ServiceLikePage({super.key});

  @override
  State<ServiceLikePage> createState() => _ServiceLikePageState();
}

class _ServiceLikePageState extends State<ServiceLikePage> {
  List<ServiceGoods> _likedGoods = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadLikedGoods();
  }

  void _loadUser() {
    final userManager = shared.UserManager();
    _currentUserId = userManager.currentUser?.user_id;
  }

  Future<void> _loadLikedGoods() async {
    if (_currentUserId == null || _currentUserId! <= 0) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ServiceApi.baseUrl}/goods/liked?user_id=$_currentUserId'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['code'] == 200) {
          final list = decoded['data']['list'] as List? ?? [];
          setState(() {
            _likedGoods =
                list.map((item) => ServiceGoods.fromJson(item)).toList();
          });
        }
      }
    } catch (e) {
      print('❌ 加载收藏商品失败: $e');
    }

    setState(() => _isLoading = false);
  }

  void _navigateToDetail(ServiceGoods goods) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServiceProductDetailPage(goods: goods)),
    ).then((_) => _loadLikedGoods());
  }

  void _removeLike(int goodsId) async {
    if (_currentUserId == null) return;

    final success = await ServiceApi.toggleLike(goodsId, _currentUserId!);
    if (success) {
      setState(() {
        _likedGoods.removeWhere((g) => g.id == goodsId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已取消收藏'), backgroundColor: Colors.green),
      );
    }
  }

  void _goLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    ).then((_) {
      _loadUser();
      _loadLikedGoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? theme.ServiceMetalColors.darkBg
              : theme.ServiceMetalColors.lightBg,
      appBar: AppBar(
        title: Text(
          '我的收藏',
          style: TextStyle(
            color:
                isDark
                    ? theme.ServiceMetalColors.darkText
                    : theme.ServiceMetalColors.lightText,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentUserId == null || _currentUserId! <= 0
              ? _buildLoginPrompt(isDark)
              : _likedGoods.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _likedGoods.length,
                itemBuilder:
                    (context, index) =>
                        _buildLikeCard(_likedGoods[index], isDark),
              ),
    );
  }

  Widget _buildLoginPrompt(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: 60.sp,
            color: isDark ? theme.ServiceMetalColors.primary : Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            '请先登录',
            style: TextStyle(
              fontSize: 18.sp,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _goLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.ServiceMetalColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('立即登录'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 60.sp,
            color: isDark ? theme.ServiceMetalColors.accent : Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无收藏',
            style: TextStyle(
              fontSize: 18.sp,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '去商品列表看看吧',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeCard(ServiceGoods goods, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateToDetail(goods),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: isDark ? Border.all(color: Colors.grey[700]!) : null,
          boxShadow:
              isDark
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
        ),
        child: Row(
          children: [
            // 左边图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                goods.mainImage ?? 'https://picsum.photos/id/0/100/100',
                width: 100.w,
                height: 100.h,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: 100.w,
                      height: 100.h,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 30),
                    ),
              ),
            ),
            SizedBox(width: 12.w),
            // 右边信息
            Expanded(
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '¥${goods.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.ServiceMetalColors.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeLike(goods.id),
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
}
