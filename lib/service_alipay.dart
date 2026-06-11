// service_alipay.dart
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'app_shared.dart';

/// 支付宝沙箱支付服务
class ServiceAlipayService {
  // 支付宝沙箱配置
  static const String baseUrl = '${AppConfig.baseWebUrl}:3000'; // 后端服务器地址
  static const String alipayGateway =
      'https://openapi.alipaydev.com/gateway.do'; // 沙箱网关

  /// 1. 创建支付宝订单（后端生成签名后返回支付链接）
  static Future<Map<String, dynamic>?> createOrder(
    String orderNo,
    double amount, {
    String subject = '挪威旅游服务订单',
    String body = '订单支付',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/alipay/create-order');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'orderNo': orderNo,
          'amount': amount.toStringAsFixed(2),
          'subject': subject,
          'body': body,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['payUrl'] != null) {
          log('✅ 创建支付宝订单成功 - 订单号: $orderNo');
          return data;
        }
      }

      log('❌ 创建支付宝订单失败: ${response.body}');
      return null;
    } catch (error) {
      log('❌ 创建支付宝订单异常: $error');
      return null;
    }
  }

  /// 2. 查询支付宝订单状态
  static Future<Map<String, dynamic>?> queryOrder(String orderNo) async {
    try {
      final url = Uri.parse('$baseUrl/api/alipay/query-order');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'orderNo': orderNo}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          log('✅ 查询支付宝订单状态成功 - 订单号: $orderNo, 状态: ${data['status']}');
          return data;
        }
      }

      log('❌ 查询支付宝订单失败: ${response.body}');
      return null;
    } catch (error) {
      log('❌ 查询支付宝订单异常: $error');
      return null;
    }
  }

  /// 处理支付宝支付（完整流程）
  static Future<bool> processPayment(
    BuildContext context,
    double amount,
    String orderNo, {
    String subject = '挪威旅游服务订单',
  }) async {
    // Step 1: 创建支付宝订单
    final orderResponse = await createOrder(orderNo, amount, subject: subject);
    if (orderResponse == null || orderResponse['payUrl'] == null) {
      log('❌ 创建订单失败');
      return false;
    }

    final payUrl = orderResponse['payUrl'];

    // Step 2: 在 WebView 中打开支付页面
    final paymentResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ServiceAlipayPage(payUrl: payUrl, orderNo: orderNo),
      ),
    );

    // Step 3: 检查支付结果
    if (paymentResult == true) {
      // 查询订单最终状态确认
      final queryResult = await queryOrder(orderNo);
      if (queryResult != null && queryResult['status'] == 'TRADE_SUCCESS') {
        return true;
      }
    }

    return false;
  }
}

/// 支付宝沙盒支付页面组件
class ServiceAlipayPage extends StatefulWidget {
  final String payUrl;
  final String orderNo;

  const ServiceAlipayPage({
    super.key,
    required this.payUrl,
    required this.orderNo,
  });

  @override
  State<ServiceAlipayPage> createState() => _ServiceAlipayPageState();
}

class _ServiceAlipayPageState extends State<ServiceAlipayPage> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                setState(() {
                  _isLoading = progress < 100;
                });
              },
              onPageStarted: (String url) {
                log('页面加载开始: $url');
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
                _checkPaymentStatus(url);
              },
              onWebResourceError: (WebResourceError error) {
                log('WebView 错误: $error');
                if (!_hasCompleted) {
                  _handlePaymentFailure();
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                log('导航请求: ${request.url}');
                _checkPaymentStatus(request.url);
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.payUrl));
  }

  void _checkPaymentStatus(String url) {
    if (_hasCompleted) return;

    // 检查是否跳转到成功页面（根据后端配置的同步回调地址）
    if (url.contains('/alipay/success') ||
        url.contains('trade_status=TRADE_SUCCESS')) {
      log('✅ 用户完成支付宝支付 - 订单号: ${widget.orderNo}');
      _hasCompleted = true;
      _handlePaymentSuccess();
      return;
    }

    // 检查是否跳转到取消页面
    if (url.contains('/alipay/cancel')) {
      log('❌ 用户取消支付宝支付 - 订单号: ${widget.orderNo}');
      _hasCompleted = true;
      _handlePaymentFailure();
      return;
    }
  }

  void _handlePaymentSuccess() {
    Navigator.pop(context, true);
  }

  void _handlePaymentFailure() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('支付宝支付'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (!_hasCompleted) {
              log('用户关闭支付页面');
              _hasCompleted = true;
              Navigator.pop(context, false);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

/// 简化的支付宝支付方法
class AlipayPayment {
  static Future<bool> pay(
    BuildContext context,
    double amount,
    String orderNo, {
    String subject = '挪威旅游服务订单',
  }) async {
    return await ServiceAlipayService.processPayment(
      context,
      amount,
      orderNo,
      subject: subject,
    );
  }
}

/// 支付宝沙箱测试配置说明
/// 
/// 沙箱环境配置（需要在后端配置）:
/// 1. APPID: 在支付宝开放平台沙箱环境获取
/// 2. 商户私钥: 自行生成的RSA私钥
/// 3. 支付宝公钥: 沙箱环境提供的公钥
/// 4. 网关地址: https://openapi.alipaydev.com/gateway.do
/// 
/// 沙箱测试账号:
/// - 沙箱商家账号: 在开放平台沙箱环境查看
/// - 沙箱买家账号: 在开放平台沙箱环境生成（含登录密码和支付密码）
/// 
/// 支付流程:
/// 1. 客户端调用 createOrder 创建订单
/// 2. 后端生成签名，调用支付宝接口获取支付链接
/// 3. 客户端通过 WebView 打开支付链接
/// 4. 用户完成支付后，支付宝同步回调后端
/// 5. 客户端查询订单状态确认支付结果
/// 6. 客户端根据支付结果更新订单状态