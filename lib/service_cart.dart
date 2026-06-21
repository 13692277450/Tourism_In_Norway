// service_cart.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'service_models.dart';
import 'service_api.dart';
import 'service_theme.dart' as theme;
import 'service_checkout.dart';
import 'app_shared.dart' as shared;

class ServiceCartPage extends StatefulWidget {
  const ServiceCartPage({super.key});

  @override
  State<ServiceCartPage> createState() => _ServiceCartPageState();
}

class _ServiceCartPageState extends State<ServiceCartPage> {
  List<ServiceCartItem> _cartItems = [];
  bool _isLoading = true;
  bool _isAllSelected = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCart();
  }

  void _loadUser() {
    final userManager = shared.UserManager();
    _currentUserId = userManager.currentUser?.user_id;
  }

  Future<void> _loadCart() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    final items = await ServiceApi.getCart(_currentUserId!);
    setState(() {
      _cartItems = items;
      _isLoading = false;
      _updateSelectAllState();
    });
  }

  void _updateSelectAllState() {
    if (_cartItems.isEmpty) {
      _isAllSelected = false;
      return;
    }
    _isAllSelected = _cartItems.every((item) => item.selected);
  }

  Future<void> _toggleSelectAll() async {
    final newSelected = !_isAllSelected;
    setState(() {
      _isAllSelected = newSelected;
      for (var item in _cartItems) {
        item.selected = newSelected;
      }
    });

    for (var item in _cartItems) {
      await ServiceApi.updateCart(cartId: item.id, selected: item.selected);
    }
  }

  Future<void> _toggleSelectItem(ServiceCartItem item) async {
    setState(() {
      item.selected = !item.selected;
      _updateSelectAllState();
    });
    await ServiceApi.updateCart(cartId: item.id, selected: item.selected);
  }

  Future<void> _updateQuantity(ServiceCartItem item, int newQuantity) async {
    if (newQuantity < 1 || newQuantity > item.stock) return;

    setState(() {
      item.quantity = newQuantity;
    });
    await ServiceApi.updateCart(cartId: item.id, quantity: newQuantity);
  }

  Future<void> _removeItem(ServiceCartItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Text('🗑️', style: TextStyle(fontSize: 20.sp)),
                SizedBox(width: 8.w),
                const Text('确认删除'),
              ],
            ),
            content: const Text('确定要删除该商品吗？'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('删除'),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _cartItems.removeWhere((i) => i.id == item.id);
        _updateSelectAllState();
      });
      await ServiceApi.removeCartItem(item.id);
      _showSuccess('已删除');
    }
  }

  void _checkout() {
    final selectedItems = _cartItems.where((item) => item.selected).toList();
    if (selectedItems.isEmpty) {
      _showError('请选择要结算的商品');
      return;
    }

    final checkoutItems =
        selectedItems
            .map(
              (item) => {'goods_id': item.goodsId, 'quantity': item.quantity},
            )
            .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceCheckoutPage(cartItems: selectedItems),
      ),
    ).then((_) => _loadCart());
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text('✅', style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 8.w),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text('❌', style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 8.w),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  double get _selectedTotalPrice {
    return _cartItems
        .where((item) => item.selected)
        .fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get _selectedCount {
    return _cartItems.where((item) => item.selected).length;
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
        title: Row(
          children: [
            Text('🛒', style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 8.w),
            Text(
              '购物车',
              style: TextStyle(
                color: const Color(0xFFF57C00), // 中橙色
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFFF57C00),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor:
            isDark
                ? theme.ServiceMetalColors.darkBg
                : theme.ServiceMetalColors.lightBg,
        elevation: isDark ? 0 : 4,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _cartItems.isEmpty
              ? _buildEmptyCart(isDark)
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(12.w),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return _buildCartItem(item, isDark);
                      },
                    ),
                  ),
                  _buildBottomBar(isDark),
                ],
              ),
    );
  }

  Widget _buildEmptyCart(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60.sp,
              color: const Color(0xFFF57C00),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '🛒 购物车空空如也',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF57C00),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '快去添加一些商品吧',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.w),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(180.w, 44.h),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.w),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🛍️', style: TextStyle(fontSize: 18.sp)),
                  SizedBox(width: 8.w),
                  Text(
                    '去逛逛',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(ServiceCartItem item, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
                    blurRadius: 4,
                  ),
                ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 选择框 - 中橙色
          GestureDetector(
            onTap: () => _toggleSelectItem(item),
            child: Container(
              width: 24.w,
              height: 24.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      item.selected
                          ? const Color(0xFFF57C00)
                          : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                  width: 2,
                ),
              ),
              child:
                  item.selected
                      ? Icon(
                        Icons.check,
                        size: 16.sp,
                        color: const Color(0xFFF57C00),
                      )
                      : null,
            ),
          ),
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              item.mainImage ?? 'https://picsum.photos/id/0/100/100',
              width: 80.w,
              height: 80.h,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: 80.w,
                    height: 80.h,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  ),
            ),
          ),
          SizedBox(width: 12.w),
          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
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
                  '编号: ${item.goodsNo}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF57C00),
                      ),
                    ),
                    // 数量选择器 - 中橙色边框
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isDark
                                  ? const Color(0xFFF57C00).withOpacity(0.5)
                                  : const Color(0xFFF57C00).withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          _buildQuantityButton(
                            Icons.remove,
                            () => _updateQuantity(item, item.quantity - 1),
                            isDark,
                          ),
                          Container(
                            width: 40.w,
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            Icons.add,
                            () => _updateQuantity(item, item.quantity + 1),
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 删除按钮 - 中橙色
          GestureDetector(
            onTap: () => _removeItem(item),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 18.sp,
                color: const Color(0xFFF57C00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color:
              isDark
                  ? theme.ServiceMetalColors.darkSurface
                  : const Color(0xFFFF6B35).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 16.sp, color: const Color(0xFFF57C00)),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 全选按钮 - 中橙色
            GestureDetector(
              onTap: _toggleSelectAll,
              child: Row(
                children: [
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _isAllSelected
                                ? const Color(0xFFF57C00)
                                : (isDark
                                    ? Colors.grey[600]!
                                    : Colors.grey[400]!),
                        width: 2,
                      ),
                    ),
                    child:
                        _isAllSelected
                            ? Icon(
                              Icons.check,
                              size: 14.sp,
                              color: const Color(0xFFF57C00),
                            )
                            : null,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '全选',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFF57C00),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '合计: ¥${_selectedTotalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF57C00),
                  ),
                ),
                Text(
                  '已选 $_selectedCount 件商品',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            // 结算按钮 - 中橙色渐变
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(100.w, 44.h),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('💳', style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 6.w),
                    Text(
                      '结算',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
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
}
