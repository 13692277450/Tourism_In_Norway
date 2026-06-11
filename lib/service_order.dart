// service_order.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'service_models.dart';
import 'service_api.dart';
import 'service_theme.dart' as theme;
import 'app_shared.dart' as shared;
import 'user_auth.dart';

class ServiceOrderListPage extends StatefulWidget {
  const ServiceOrderListPage({super.key});

  @override
  State<ServiceOrderListPage> createState() => _ServiceOrderListPageState();
}

class _ServiceOrderListPageState extends State<ServiceOrderListPage> {
  List<ServiceOrder> _orders = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadOrders();
  }

  void _loadUser() {
    final userManager = shared.UserManager();
    _currentUserId = userManager.currentUser?.user_id;
  }

  Future<void> _loadOrders() async {
    if (_currentUserId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    final orders = await ServiceApi.getOrders(_currentUserId!);
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return '待付款';
      case 1:
        return '待发货';
      case 2:
        return '待收货';
      case 3:
        return '已完成';
      case 4:
        return '已取消';
      case 5:
        return '售后';
      default:
        return '未知';
    }
  }

  Color _getStatusColor(int status, bool isDark) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return isDark ? Colors.grey[400]! : Colors.grey[600]!;
      case 4:
        return Colors.red;
      case 5:
        return Colors.purple;
      default:
        return isDark ? Colors.grey[500]! : Colors.grey[500]!;
    }
  }

  void _goLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    ).then((_) {
      _loadUser();
      _loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '我的订单',
          style: TextStyle(
            color:
                isDark
                    ? theme.ServiceMetalColors.primary
                    : theme.ServiceMetalColors.lightText,
          ),
        ),
      ),
      backgroundColor:
          isDark
              ? theme.ServiceMetalColors.darkBg
              : theme.ServiceMetalColors.lightBg,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentUserId == null
              ? _buildNotLoggedIn(isDark)
              : _orders.isEmpty
              ? _buildEmptyOrders(isDark)
              : ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(_orders[index], isDark);
                },
              ),
    );
  }

  Widget _buildNotLoggedIn(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: 64.sp,
            color:
                isDark
                    ? theme.ServiceMetalColors.primary.withOpacity(0.5)
                    : Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            '请先登录查看订单',
            style: TextStyle(
              fontSize: 16.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _goLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.ServiceMetalColors.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64.sp,
            color:
                isDark
                    ? theme.ServiceMetalColors.primary.withOpacity(0.5)
                    : Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无订单',
            style: TextStyle(
              fontSize: 16.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(ServiceOrder order, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
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
                    color: theme.ServiceMetalColors.primary.withOpacity(0.1),
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
      child: Column(
        children: [
          // 订单头部信息
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '订单号: ${order.orderNo}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
                Text(
                  _getStatusText(order.status),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _getStatusColor(order.status, isDark),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 订单商品列表
          for (var item in order.items) _buildOrderItem(item, isDark),
          // 订单底部信息
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '共${order.items.length}件商品',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '实付: ',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                    Text(
                      '¥${order.actualAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.ServiceMetalColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(ServiceOrderItem item, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              item.goodsImage ?? 'https://picsum.photos/id/0/100/100',
              width: 60.w,
              height: 60.w,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: 60.w,
                    height: 60.w,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 24),
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
                  item.goodsName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      '¥${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.ServiceMetalColors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'x${item.quantity}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
