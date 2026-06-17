// service_checkout.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tourism_in_norway/service_wechat.dart';
import 'service_models.dart';
import 'service_api.dart';
import 'service_theme.dart' as theme;
import 'service_address.dart';
import 'service_paypal.dart';
import 'service_alipay.dart';
import 'service_alipay_app.dart';
import 'app_shared.dart';

class ServiceCheckoutPage extends StatefulWidget {
  final List<ServiceCartItem>? cartItems;
  final List<Map<String, dynamic>>? directBuyItems;
  final ServiceGoods? directBuyGoods;
  final int? quantity;

  const ServiceCheckoutPage({
    super.key,
    this.cartItems,
    this.directBuyItems,
    this.directBuyGoods,
    this.quantity,
  });

  @override
  State<ServiceCheckoutPage> createState() => _ServiceCheckoutPageState();
}

class _ServiceCheckoutPageState extends State<ServiceCheckoutPage> {
  List<ServiceCartItem> _checkoutItems = [];
  List<ServiceAddress> _addresses = [];
  ServiceAddress? _selectedAddress;
  bool _isLoading = true;
  bool _isCreatingOrder = false;
  int? _currentUserId;

  // 物流信息
  final String _logisticsCompany = '顺丰速运';
  final int _estimatedDays = 3;

  @override
  void initState() {
    super.initState();
    _initCheckoutItems();
    _loadUserAndAddresses();
  }

  Future<void> _loadUserAndAddresses() async {
    try {
      // 先加载用户信息
      final userManager = UserManager();
      final user = userManager.currentUser;
      setState(() {
        _currentUserId = user?.user_id ?? 0;
      });
      print('✅ 当前用户ID: $_currentUserId');

      // 用户加载完成后再加载地址
      if (_currentUserId != null && _currentUserId != 0) {
        await _loadAddresses();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ 加载用户失败: $e');
      setState(() => _isLoading = false);
    }
  }

  void _initCheckoutItems() {
    // 优先从购物车获取
    if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
      _checkoutItems = widget.cartItems!;
    }
    // 其次从直接购买获取
    else if (widget.directBuyItems != null &&
        widget.directBuyItems!.isNotEmpty) {
      _loadDirectBuyItems();
    }
    // 最后从单个商品获取
    else if (widget.directBuyGoods != null && widget.quantity != null) {
      final item = ServiceCartItem(
        id: 0,
        goodsId: widget.directBuyGoods!.id,
        goodsNo: widget.directBuyGoods!.goodsNo,
        name: widget.directBuyGoods!.name,
        mainImage: widget.directBuyGoods!.mainImage,
        price: widget.directBuyGoods!.price,
        quantity: widget.quantity!,
        selected: true,
        stock: widget.directBuyGoods!.stock,
      );
      _checkoutItems = [item];
    }
  }

  Future<void> _loadDirectBuyItems() async {
    if (widget.directBuyItems == null) return;

    _checkoutItems = [];
    for (var item in widget.directBuyItems!) {
      try {
        final goods = await ServiceApi.getGoodsDetail(item['goods_id']);
        if (goods != null) {
          final cartItem = ServiceCartItem(
            id: 0,
            goodsId: goods.id,
            goodsNo: goods.goodsNo,
            name: goods.name,
            mainImage: goods.mainImage,
            price: goods.price,
            quantity: item['quantity'],
            selected: true,
            stock: goods.stock,
          );
          _checkoutItems.add(cartItem);
        }
      } catch (e) {
        print('加载商品失败: $e');
      }
    }
    setState(() {});
  }

  Future<void> _loadAddresses() async {
    if (_currentUserId == null || _currentUserId == 0) {
      setState(() => _isLoading = false);
      return;
    }

    final addresses = await ServiceApi.getAddresses(_currentUserId!);
    setState(() {
      _addresses = addresses;
      // 优先选择默认地址，否则选择第一个
      try {
        _selectedAddress = addresses.firstWhere((addr) => addr.isDefault);
      } catch (e) {
        _selectedAddress = addresses.isNotEmpty ? addresses.first : null;
      }
      _isLoading = false;
    });
  }

  Future<void> _createOrder() async {
    if (_selectedAddress == null) {
      _showError('请选择收货地址');
      return;
    }

    if (_checkoutItems.isEmpty) {
      _showError('没有商品');
      return;
    }

    if (_currentUserId == null || _currentUserId == 0) {
      _showError('请先登录');
      return;
    }

    setState(() => _isCreatingOrder = true);

    final items =
        _checkoutItems
            .map(
              (item) => {'goods_id': item.goodsId, 'quantity': item.quantity},
            )
            .toList();

    final result = await ServiceApi.createOrder(
      userId: _currentUserId!,
      addressId: _selectedAddress!.id,
      items: items,
    );

    setState(() => _isCreatingOrder = false);

    if (result['code'] == 200) {
      final orderId = result['data']['order_id'];
      final orderNo = result['data']['order_no'];
      _showPaymentDialog(orderId, orderNo);
    } else {
      _showError(result['message'] ?? '创建订单失败');
    }
  }

  void _showPaymentDialog(int orderId, String orderNo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            backgroundColor:
                isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
            title: Text(
              '选择支付方式',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPaymentMethod(
                  '支付宝',
                  Icons.account_balance_wallet,
                  () => _processAlipayPayment(orderId, orderNo),
                  isDark,
                ),
                SizedBox(height: 12.h),
                _buildPaymentMethod(
                  '支付宝App',
                  Icons.phone_android,
                  () => _processAlipayAppPayment(orderId, orderNo),
                  isDark,
                ),
                SizedBox(height: 12.h),
                _buildPaymentMethod(
                  '微信支付',
                  Icons.wechat,
                  () => _processWeChatPayment(orderId, orderNo),
                  isDark,
                ),
                SizedBox(height: 12.h),
                _buildPaymentMethod(
                  'PayPal',
                  Icons.payment,
                  () => _processPayPalPayment(orderId, orderNo),
                  isDark,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildPaymentMethod(
    String name,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isDark
                    ? theme.ServiceMetalColors.primary.withOpacity(0.3)
                    : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30.sp, color: theme.ServiceMetalColors.primary),
            SizedBox(width: 16.w),
            Text(
              name,
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayPalPayment(int orderId, String orderNo) async {
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    final amount = _totalPrice;
    print('💰 PayPal 支付 - 订单号: $orderNo, 金额: ¥$amount');

    if (amount <= 0) {
      _showError('订单金额无效');
      return;
    }

    _showLoading('正在跳转到PayPal...');

    try {
      final success = await ServicePayPalService.processPayment(
        context,
        amount,
        orderNo,
      );

      print('📤 PayPal 支付结果: $success');

      if (success && mounted) {
        _showSuccess('PayPal 支付成功！');
        _navigateToOrderResult(orderId, orderNo);
      } else if (mounted) {
        _showError('PayPal 支付失败或已取消');
      }
    } catch (e) {
      print('❌ PayPal 支付异常: $e');
      if (mounted) {
        _showError('支付过程中发生错误');
      }
    }
  }

  Future<void> _processAlipayPayment(int orderId, String orderNo) async {
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    final amount = _totalPrice;
    print('💰 支付宝支付 - 订单号: $orderNo, 金额: ¥$amount');

    if (amount <= 0) {
      _showError('订单金额无效');
      return;
    }

    _showLoading('正在跳转到支付宝...');

    try {
      final success = await ServiceAlipayService.processPayment(
        context,
        amount,
        orderNo,
      );

      if (success && mounted) {
        _showSuccess('支付宝支付成功！');
        _navigateToOrderResult(orderId, orderNo);
      } else if (mounted) {
        _showError('支付宝支付失败或已取消');
      }
    } catch (e) {
      print('❌ 支付宝支付异常: $e');
      if (mounted) {
        _showError('支付过程中发生错误');
      }
    }
  }

  Future<void> _processAlipayAppPayment(int orderId, String orderNo) async {
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    final amount = _totalPrice;
    print('💰 支付宝App支付 - 订单号: $orderNo, 金额: ¥$amount');

    if (amount <= 0) {
      _showError('订单金额无效');
      return;
    }

    _showLoading('正在调用支付宝App...');

    try {
      final success = await ServiceAlipayAppService.processPayment(
        context,
        amount,
        orderNo,
      );

      if (success && mounted) {
        _showSuccess('支付宝支付成功！');
        _navigateToOrderResult(orderId, orderNo);
      } else if (mounted) {
        _showError('支付宝支付失败或已取消');
      }
    } catch (e) {
      print('❌ 支付宝App支付异常: $e');
      if (mounted) {
        _showError('支付过程中发生错误');
      }
    }
  }

  Future<void> _processWeChatPayment(int orderId, String orderNo) async {
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    final amount = _totalPrice;
    print('💰 微信支付 - 订单号: $orderNo, 金额: ¥$amount');

    if (amount <= 0) {
      _showError('订单金额无效');
      return;
    }

    _showLoading('正在跳转到微信支付...');

    try {
      final success = await ServiceWeChatService.processPayment(
        amount,
        orderNo,
      );

      if (success && mounted) {
        _showSuccess('微信支付成功！');
        _navigateToOrderResult(orderId, orderNo);
      } else if (mounted) {
        _showError('微信支付失败或已取消');
      }
    } catch (e) {
      print('❌ 微信支付异常: $e');
      if (mounted) {
        _showError('支付过程中发生错误');
      }
    }
  }

  void _navigateToOrderResult(int orderId, String orderNo) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder:
            (context) => ServiceOrderResultPage(
              orderId: orderId,
              orderNo: orderNo,
              estimatedDays: _estimatedDays,
            ),
      ),
      (route) => route.isFirst,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showLoading(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  double get _totalPrice {
    return _checkoutItems.fold(0, (sum, item) => sum + item.totalPrice);
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
          '确认订单',
          style: TextStyle(
            color:
                isDark
                    ? theme.ServiceMetalColors.primary
                    : theme.ServiceMetalColors.lightText,
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAddressSection(isDark),
                          SizedBox(height: 16.h),
                          _buildProductsSection(isDark),
                          SizedBox(height: 16.h),
                          _buildLogisticsSection(isDark),
                          SizedBox(height: 16.h),
                          _buildOrderInfoSection(isDark),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(isDark),
                ],
              ),
    );
  }

  Widget _buildAddressSection(bool isDark) {
    return GestureDetector(
      onTap: () async {
        print('🔘 点击地址选择，当前选中地址ID: ${_selectedAddress?.id}');

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    ServiceAddressPage(selectedAddressId: _selectedAddress?.id),
          ),
        );

        print('📤 从地址页面返回: $result');

        // ✅ 正确处理返回的地址
        if (result != null && result is ServiceAddress) {
          print('✅ 收到返回的地址: ${result.receiverName}, ${result.fullAddress}');
          setState(() {
            _selectedAddress = result;
          });
        } else if (result != null) {
          print('⚠️ 返回的数据类型错误: ${result.runtimeType}');
        } else {
          print('⚠️ 用户取消选择地址');
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
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
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: theme.ServiceMetalColors.primary,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child:
                  _selectedAddress == null
                      ? Text(
                        '请选择收货地址',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedAddress!.receiverName}  ${_selectedAddress!.receiverPhone}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _selectedAddress!.fullAddress,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          Text(
            '商品清单',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _checkoutItems.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final item = _checkoutItems[index];
              return _buildProductItem(item, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(ServiceCartItem item, bool isDark) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.network(
            item.mainImage ?? 'https://picsum.photos/id/0/60/60',
            width: 60.w,
            height: 60.h,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  width: 60.w,
                  height: 60.h,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    size: 30,
                    color: Colors.grey[400],
                  ),
                ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '数量: ${item.quantity}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Text(
          '¥${item.totalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color:
                isDark
                    ? theme.ServiceMetalColors.primary
                    : theme.ServiceMetalColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildLogisticsSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
            Icons.local_shipping,
            color: theme.ServiceMetalColors.primary,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '配送方式',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$_logisticsCompany  ·  预计 $_estimatedDays 天内送达',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border:
            isDark
                ? Border.all(
                  color: theme.ServiceMetalColors.primary.withOpacity(0.3),
                )
                : null,
      ),
      child: Column(
        children: [
          _buildInfoRow('商品总价', '¥${_totalPrice.toStringAsFixed(2)}', isDark),
          SizedBox(height: 8.h),
          _buildInfoRow('运费', '¥0.00', isDark),
          SizedBox(height: 8.h),
          _buildInfoRow('优惠', '-¥0.00', isDark),
          SizedBox(height: 12.h),
          _buildMetalDivider(isDark),
          SizedBox(height: 12.h),
          _buildInfoRow(
            '实付金额',
            '¥${_totalPrice.toStringAsFixed(2)}',
            isDark,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    bool isDark, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20.sp : 16.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color:
                isTotal
                    ? theme.ServiceMetalColors.primary
                    : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildMetalDivider(bool isDark) {
    return Container(
      height: 1,
      color: isDark ? Colors.grey[700] : Colors.grey[300],
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '共 ${_checkoutItems.length} 件商品',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
                Text(
                  '合计: ¥${_totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.ServiceMetalColors.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _isCreatingOrder
                ? Container(
                  width: 120.w,
                  height: 48.h,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                )
                : _buildMetalButton('提交订单', _createOrder, isDark, width: 120.w),
          ],
        ),
      ),
    );
  }

  Widget _buildMetalButton(
    String text,
    VoidCallback onTap,
    bool isDark, {
    double? width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 48.h,
        decoration: BoxDecoration(
          color: theme.ServiceMetalColors.primary,
          borderRadius: BorderRadius.circular(24.r),
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
}

// 订单结果页面
class ServiceOrderResultPage extends StatelessWidget {
  final int orderId;
  final String orderNo;
  final int estimatedDays;

  const ServiceOrderResultPage({
    super.key,
    required this.orderId,
    required this.orderNo,
    required this.estimatedDays,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? theme.ServiceMetalColors.darkBg
              : theme.ServiceMetalColors.lightBg,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      theme.ServiceMetalColors.primary,
                      theme.ServiceMetalColors.accent,
                    ],
                  ),
                  boxShadow:
                      isDark
                          ? [
                            BoxShadow(
                              color: theme.ServiceMetalColors.primary,
                              blurRadius: 20,
                            ),
                            BoxShadow(
                              color: theme.ServiceMetalColors.accent,
                              blurRadius: 15,
                            ),
                          ]
                          : null,
                ),
                child: Icon(Icons.check, size: 50.sp, color: Colors.black),
              ),
              SizedBox(height: 24.h),
              Text(
                '订单提交成功！',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? theme.ServiceMetalColors.darkSurface
                          : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                      isDark
                          ? Border.all(
                            color: theme.ServiceMetalColors.primary.withOpacity(
                              0.3,
                            ),
                          )
                          : null,
                ),
                child: Column(
                  children: [
                    Text(
                      '订单号: $orderNo',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '预计 $estimatedDays 天内送达',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.ServiceMetalColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      '查看订单',
                      () => Navigator.pop(context),
                      isDark,
                      outlined: true,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildButton(
                      '继续购物',
                      () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String text,
    VoidCallback onTap,
    bool isDark, {
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          gradient:
              outlined
                  ? null
                  : const LinearGradient(
                    colors: [
                      theme.ServiceMetalColors.primary,
                      theme.ServiceMetalColors.accent,
                    ],
                  ),
          color:
              outlined
                  ? (isDark
                      ? theme.ServiceMetalColors.darkSurface
                      : Colors.white)
                  : null,
          borderRadius: BorderRadius.circular(24.r),
          border:
              outlined
                  ? Border.all(color: theme.ServiceMetalColors.primary)
                  : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: outlined ? theme.ServiceMetalColors.primary : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
