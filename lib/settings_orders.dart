// service_settings_orders.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'service_theme.dart' as theme;

class ServiceOrderListPage extends StatelessWidget {
  final int initialTab;
  final String title;

  const ServiceOrderListPage({
    super.key,
    this.initialTab = 0,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor:
            isDark
                ? theme.ServiceMetalColors.darkBg
                : theme.ServiceMetalColors.lightBg,
        appBar: AppBar(
          title: Row(
            children: [
              Text('📋', style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  color:
                      isDark
                          ? theme.ServiceMetalColors.primary
                          : theme.ServiceMetalColors.lightText,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          backgroundColor:
              isDark
                  ? theme.ServiceMetalColors.darkBg
                  : theme.ServiceMetalColors.lightBg,
          bottom: TabBar(
            labelColor: const Color(0xFF3D5AFE),
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            indicatorColor: const Color(0xFF3D5AFE),
            tabs: const [
              Tab(text: '待付款'),
              Tab(text: '待发货'),
              Tab(text: '待收货'),
              Tab(text: '待评价'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrderListTab(status: '待付款', emoji: '💳'),
            OrderListTab(status: '待发货', emoji: '📦'),
            OrderListTab(status: '待收货', emoji: '🚚'),
            OrderListTab(status: '待评价', emoji: '⭐'),
          ],
        ),
      ),
    );
  }
}

// ==================== 订单列表Tab ====================
class OrderListTab extends StatelessWidget {
  final String status;
  final String emoji;

  const OrderListTab({super.key, required this.status, required this.emoji});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 模拟订单数据
    final orders = _getMockOrders(status);

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(context, order, isDark);
      },
    );
  }

  List<Map<String, dynamic>> _getMockOrders(String status) {
    final allOrders = [
      {
        'id': 'PAYPAL-001',
        'orderNo': 'TRV-2024-001',
        'amount': '\$299.00',
        'date': '2024-01-15',
        'status': '待付款',
        'product': '挪威峡湾之旅 7天6晚',
        'image': 'https://picsum.photos/seed/travel1/200/200',
      },
      {
        'id': 'PAYPAL-002',
        'orderNo': 'TRV-2024-002',
        'amount': '\$459.00',
        'date': '2024-01-14',
        'status': '待付款',
        'product': '极光摄影之旅 5天4晚',
        'image': 'https://picsum.photos/seed/travel2/200/200',
      },
      {
        'id': 'PAYPAL-003',
        'orderNo': 'TRV-2024-003',
        'amount': '\$189.00',
        'date': '2024-01-13',
        'status': '待发货',
        'product': '卑尔根城市探索 3天2晚',
        'image': 'https://picsum.photos/seed/travel3/200/200',
      },
      {
        'id': 'PAYPAL-004',
        'orderNo': 'TRV-2024-004',
        'amount': '\$599.00',
        'date': '2024-01-12',
        'status': '待发货',
        'product': '罗弗敦群岛自驾 8天7晚',
        'image': 'https://picsum.photos/seed/travel4/200/200',
      },
      {
        'id': 'PAYPAL-005',
        'orderNo': 'TRV-2024-005',
        'amount': '\$349.00',
        'date': '2024-01-11',
        'status': '待收货',
        'product': '特罗姆瑟极光团 4天3晚',
        'image': 'https://picsum.photos/seed/travel5/200/200',
      },
      {
        'id': 'PAYPAL-006',
        'orderNo': 'TRV-2024-006',
        'amount': '\$279.00',
        'date': '2024-01-10',
        'status': '待评价',
        'product': '奥斯陆文化之旅 3天2晚',
        'image': 'https://picsum.photos/seed/travel6/200/200',
      },
      {
        'id': 'PAYPAL-007',
        'orderNo': 'TRV-2024-007',
        'amount': '\$529.00',
        'date': '2024-01-09',
        'status': '待评价',
        'product': '挪威缩影一日游',
        'image': 'https://picsum.photos/seed/travel7/200/200',
      },
    ];

    return allOrders.where((order) => order['status'] == status).toList();
  }

  Widget _buildOrderCard(
    BuildContext context,
    Map<String, dynamic> order,
    bool isDark,
  ) {
    final statusColor = _getStatusColor(order['status']);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isDark ? Border.all(color: Colors.grey[700]!) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 订单头部
          Row(
            children: [
              Text(
                '${order['emoji'] ?? '📋'} ${order['orderNo']}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 商品信息
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  order['image'],
                  width: 60.w,
                  height: 60.h,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        width: 60.w,
                        height: 60.h,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['product'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '订单日期: ${order['date']}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 底部
          Row(
            children: [
              Text(
                '总计: ',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
              Text(
                order['amount'],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3D5AFE),
                ),
              ),
              const Spacer(),
              _buildActionButton(context, order['status'], isDark),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '待付款':
        return const Color(0xFFFF6B35);
      case '待发货':
        return const Color(0xFF3D5AFE);
      case '待收货':
        return const Color(0xFF00C853);
      case '待评价':
        return const Color(0xFFFFD600);
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionButton(BuildContext context, String status, bool isDark) {
    String label;
    Color color;
    IconData icon;

    switch (status) {
      case '待付款':
        label = '去支付';
        color = const Color(0xFFFF6B35);
        icon = Icons.payment;
        break;
      case '待发货':
        label = '查看物流';
        color = const Color(0xFF3D5AFE);
        icon = Icons.local_shipping;
        break;
      case '待收货':
        label = '确认收货';
        color = const Color(0xFF00C853);
        icon = Icons.check_circle;
        break;
      case '待评价':
        label = '去评价';
        color = const Color(0xFFFFD600);
        icon = Icons.rate_review;
        break;
      default:
        label = '查看';
        color = Colors.grey;
        icon = Icons.visibility;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(icon, color: Colors.white),
                  SizedBox(width: 8.w),
                  Text('跳转到$status页面'),
                ],
              ),
              backgroundColor: color,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
