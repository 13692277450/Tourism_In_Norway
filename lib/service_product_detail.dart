// service_product_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourism_in_norway/service_checkout.dart';
import 'service_models.dart';
import 'service_api.dart';
import 'service_theme.dart' as theme;
import 'user_auth.dart';
import 'app_shared.dart' as shared;

class ServiceProductDetailPage extends StatefulWidget {
  final ServiceGoods goods;

  const ServiceProductDetailPage({super.key, required this.goods});

  @override
  State<ServiceProductDetailPage> createState() =>
      _ServiceProductDetailPageState();
}

class _ServiceProductDetailPageState extends State<ServiceProductDetailPage> {
  late ServiceGoods _goods;
  List<ServiceComment> _comments = [];
  bool _isLiked = false;
  int _quantity = 1;
  int _currentImageIndex = 0;
  bool _isLoading = true;
  int? _currentUserId;

  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final double _imageOffset = 0.0;
  final double _maxOffset = 150.0; // 图片最大移动距离

  @override
  void initState() {
    super.initState();
    _goods = widget.goods;
    _loadUser();
    _loadComments();
    _checkLikeStatus();
  }

  void _loadUser() {
    // 从UserManager获取当前用户ID
    final userManager = shared.UserManager();
    _currentUserId = userManager.currentUser?.user_id;
  }

  Future<void> _loadComments() async {
    final result = await ServiceApi.getComments(_goods.id);
    if (result['code'] == 200) {
      final list = result['data']['list'] as List? ?? [];
      setState(() {
        _comments = list.map((item) => ServiceComment.fromJson(item)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkLikeStatus() async {
    if (_currentUserId == null) return;
    // 调用API检查点赞状态
    final isLiked = await ServiceApi.checkLikeStatus(
      _goods.id,
      _currentUserId!,
    );
    setState(() => _isLiked = isLiked);
  }

  Future<void> _toggleLike() async {
    if (_currentUserId == null) {
      _showLoginRequired();
      return;
    }

    HapticFeedback.mediumImpact();
    final success = await ServiceApi.toggleLike(_goods.id, _currentUserId!);
    if (success) {
      setState(() {
        _isLiked = !_isLiked;
        _goods = _goods.copyWith(
          isLiked: _isLiked,
          likeCount: _isLiked ? _goods.likeCount + 1 : _goods.likeCount - 1,
        );
      });
    }
  }

  Future<void> _addToCart() async {
    if (_currentUserId == null) {
      _showLoginRequired();
      return;
    }

    HapticFeedback.mediumImpact();
    final success = await ServiceApi.addToCart(
      _currentUserId!,
      _goods.id,
      quantity: _quantity,
    );
    if (success) {
      _showSuccess('已添加到购物车');
    } else {
      _showError('添加失败');
    }
  }
  // service_product_detail.dart - 修复后的 _buyNow 方法

  void _buyNow() async {
    if (_currentUserId == null) {
      _showLoginRequired();
      return;
    }

    // 修复：正确构建 checkoutItems
    final checkoutItems = [
      {'goods_id': _goods.id, 'quantity': _quantity},
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ServiceCheckoutPage(
              directBuyItems: checkoutItems, // 使用 directBuyItems 参数
              directBuyGoods: _goods,
              quantity: _quantity,
              checkoutItems: [],
            ),
      ),
    );
  }

  void _showLoginRequired() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    ).then((_) {
      // 登录成功后刷新用户信息
      _loadUser();
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor:
                  isDark
                      ? theme.ServiceMetalColors.darkBg
                      : theme.ServiceMetalColors.lightBg,
              elevation: 0,
              pinned: true,
              floating: true,
              snap: true,
              expandedHeight: 350.h,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildImageCarousel(isDark),
              ),
              title: Text(
                '商品详情',
                style: TextStyle(
                  color:
                      isDark
                          ? theme.ServiceMetalColors.darkText
                          : theme.ServiceMetalColors.lightText,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : null,
                  ),
                  onPressed: _toggleLike,
                ),
              ],
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  isDark
                      ? theme.ServiceMetalColors.darkBg
                      : theme.ServiceMetalColors.lightBg,
            ),
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(isDark),
                SizedBox(height: 16.h),
                _buildMetalDivider(isDark),
                SizedBox(height: 16.h),
                _buildQuantitySelector(isDark),
                SizedBox(height: 16.h),
                _buildMetalDivider(isDark),
                SizedBox(height: 16.h),
                _buildProductDescription(isDark),
                SizedBox(height: 16.h),
                _buildMetalDivider(isDark),
                SizedBox(height: 16.h),
                _buildCommentsSection(isDark),
                SizedBox(height: 16.h),
                // 购买按钮放在评价区域下面
                _buildBottomBar(isDark),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(bool isDark) {
    final images =
        _goods.images.isEmpty && _goods.mainImage != null
            ? [_goods.mainImage!]
            : (_goods.images.isEmpty
                ? ['https://picsum.photos/id/0/400/400']
                : _goods.images);

    return SizedBox(
      height: 350.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged:
                (index) => setState(() => _currentImageIndex = index),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                width: double.infinity,
                height: 350.h,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
              );
            },
          ),
          // 指示器
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentImageIndex == index
                            ? (isDark
                                ? theme.ServiceMetalColors.primary
                                : theme.ServiceMetalColors.primary)
                            : Colors.white.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    theme.ServiceMetalColors.primary,
                    theme.ServiceMetalColors.accent,
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                _goods.categoryName ?? '商品',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            if (_goods.score > 0)
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 14.sp,
                    color: theme.ServiceMetalColors.gold,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${_goods.score}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                          isDark
                              ? theme.ServiceMetalColors.darkText
                              : theme.ServiceMetalColors.lightText,
                    ),
                  ),
                ],
              ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          _goods.name,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color:
                isDark
                    ? theme.ServiceMetalColors.darkText
                    : theme.ServiceMetalColors.lightText,
          ),
        ),
        SizedBox(height: 8.h),
        if (_goods.nameEn != null)
          Text(
            _goods.nameEn!,
            style: TextStyle(
              fontSize: 14.sp,
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
              '¥${_goods.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color:
                    isDark
                        ? theme.ServiceMetalColors.primary
                        : theme.ServiceMetalColors.primary,
                shadows:
                    isDark
                        ? [
                          Shadow(
                            color: theme.ServiceMetalColors.primary,
                            blurRadius: 10,
                          ),
                        ]
                        : null,
              ),
            ),
            if (_goods.originalPrice != null)
              Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: Text(
                  '¥${_goods.originalPrice!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    decoration: TextDecoration.lineThrough,
                    color:
                        isDark
                            ? theme.ServiceMetalColors.darkTextTertiary
                            : theme.ServiceMetalColors.lightTextTertiary,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              '库存 ${_goods.stock}',
              style: TextStyle(
                fontSize: 12.sp,
                color:
                    isDark
                        ? theme.ServiceMetalColors.darkTextSecondary
                        : theme.ServiceMetalColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _buildInfoChip(
              Icons.remove_red_eye_outlined,
              '${_goods.viewCount} 浏览',
              isDark,
            ),
            SizedBox(width: 12.w),
            _buildInfoChip(
              Icons.shopping_bag_outlined,
              '${_goods.salesCount} 销量',
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color:
            isDark
                ? theme.ServiceMetalColors.darkSurface
                : theme.ServiceMetalColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(20.r),
        border:
            isDark
                ? Border.all(
                  color: theme.ServiceMetalColors.primary.withOpacity(0.3),
                )
                : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: isDark ? theme.ServiceMetalColors.primary : Colors.grey,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color:
                  isDark
                      ? theme.ServiceMetalColors.darkText
                      : theme.ServiceMetalColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(bool isDark) {
    return Row(
      children: [
        Text(
          '数量',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color:
                isDark
                    ? theme.ServiceMetalColors.darkText
                    : theme.ServiceMetalColors.lightText,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isDark
                      ? theme.ServiceMetalColors.primary.withOpacity(0.5)
                      : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              _buildQuantityButton(Icons.remove, () {
                if (_quantity > 1) setState(() => _quantity--);
              }, isDark),
              Container(
                width: 50.w,
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color:
                        isDark
                            ? theme.ServiceMetalColors.darkText
                            : theme.ServiceMetalColors.lightText,
                  ),
                ),
              ),
              _buildQuantityButton(Icons.add, () {
                if (_quantity < _goods.stock) setState(() => _quantity++);
              }, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:
              isDark
                  ? theme.ServiceMetalColors.darkSurface
                  : theme.ServiceMetalColors.lightSurfaceElevated,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color:
              isDark
                  ? theme.ServiceMetalColors.primary
                  : theme.ServiceMetalColors.lightText,
        ),
      ),
    );
  }

  Widget _buildProductDescription(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '商品描述',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color:
                isDark
                    ? theme.ServiceMetalColors.darkText
                    : theme.ServiceMetalColors.lightText,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          _goods.description ?? _goods.shortDescription ?? '暂无详细描述',
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.6,
            color:
                isDark
                    ? theme.ServiceMetalColors.darkTextSecondary
                    : theme.ServiceMetalColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '商品评价 (${_comments.length})',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color:
                isDark
                    ? theme.ServiceMetalColors.darkText
                    : theme.ServiceMetalColors.lightText,
          ),
        ),
        SizedBox(height: 12.h),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: Text(
                '暂无评价',
                style: TextStyle(
                  color:
                      isDark
                          ? theme.ServiceMetalColors.darkTextSecondary
                          : theme.ServiceMetalColors.lightTextSecondary,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length > 3 ? 3 : _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return _buildCommentCard(comment, isDark);
            },
          ),
        if (_comments.length > 3)
          TextButton(
            onPressed: () {
              // 跳转到全部评论页面
            },
            child: Text(
              '查看全部 ${_comments.length} 条评价',
              style: TextStyle(color: theme.ServiceMetalColors.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentCard(ServiceComment comment, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color:
            isDark
                ? theme.ServiceMetalColors.darkSurface
                : theme.ServiceMetalColors.lightSurface,
        borderRadius: BorderRadius.circular(12.r),
        border:
            isDark
                ? Border.all(
                  color: theme.ServiceMetalColors.primary.withOpacity(0.2),
                )
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: theme.ServiceMetalColors.primary.withOpacity(
                  0.2,
                ),
                child: Text(
                  comment.userName.isNotEmpty ? comment.userName[0] : 'U',
                  style: const TextStyle(
                    color: theme.ServiceMetalColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                comment.userName,
                style: TextStyle(
                  fontSize: 14.sp,
                  color:
                      isDark
                          ? theme.ServiceMetalColors.darkText
                          : theme.ServiceMetalColors.lightText,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < comment.rating ? Icons.star : Icons.star_border,
                    size: 12.sp,
                    color: theme.ServiceMetalColors.gold,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 13.sp,
              color:
                  isDark
                      ? theme.ServiceMetalColors.darkTextSecondary
                      : theme.ServiceMetalColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _formatDate(comment.createdAt),
            style: TextStyle(
              fontSize: 10.sp,
              color:
                  isDark
                      ? theme.ServiceMetalColors.darkTextTertiary
                      : theme.ServiceMetalColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetalDivider(bool isDark) {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark
                ? theme.ServiceMetalColors.primary.withOpacity(0)
                : Colors.transparent,
            isDark
                ? theme.ServiceMetalColors.primary
                : theme.ServiceMetalColors.primary,
            isDark
                ? theme.ServiceMetalColors.accent
                : theme.ServiceMetalColors.accent,
            isDark
                ? theme.ServiceMetalColors.accent.withOpacity(0)
                : Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color:
            isDark
                ? theme.ServiceMetalColors.darkSurface
                : theme.ServiceMetalColors.lightSurface,
        borderRadius: BorderRadius.circular(16.r),
        border:
            isDark
                ? Border.all(
                  color: theme.ServiceMetalColors.primary.withOpacity(0.3),
                )
                : null,
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
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetalButton(
              '加入购物车',
              _addToCart,
              isDark,
              gradient: const LinearGradient(
                colors: [
                  theme.ServiceMetalColors.primary,
                  theme.ServiceMetalColors.accent,
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildMetalButton(
              '立即购买',
              _buyNow,
              isDark,
              gradient: const LinearGradient(
                colors: [
                  theme.ServiceMetalColors.accent,
                  theme.ServiceMetalColors.primary,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetalButton(
    String text,
    VoidCallback onTap,
    bool isDark, {
    Gradient? gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          gradient:
              gradient ??
              (isDark
                  ? const LinearGradient(
                    colors: [
                      theme.ServiceMetalColors.primary,
                      theme.ServiceMetalColors.accent,
                    ],
                  )
                  : const LinearGradient(
                    colors: [
                      theme.ServiceMetalColors.primary,
                      theme.ServiceMetalColors.primary,
                    ],
                  )),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow:
              isDark
                  ? [
                    BoxShadow(
                      color: theme.ServiceMetalColors.primary,
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: theme.ServiceMetalColors.accent,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                  : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}天前';
    if (diff.inHours > 0) return '${diff.inHours}小时前';
    if (diff.inMinutes > 0) return '${diff.inMinutes}分钟前';
    return '刚刚';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
