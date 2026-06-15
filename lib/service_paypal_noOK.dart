// service_paypal.dart
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'app_shared.dart';

class ServicePayPalService {
  // PayPal 配置
  static const String baseUrl = AppConfig.baseWebUrl; // 后端服务器地址

  /// 1. 创建 PayPal 订单
  static Future<Map<String, dynamic>?> createOrder(
    String orderNo,
    double amount,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/paypal/create-order');
      log('📡 创建 PayPal 订单请求: $url');
      log('   订单号: $orderNo, 金额: ${amount.toStringAsFixed(2)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'orderNo': orderNo,
          'amount': amount.toStringAsFixed(2),
        }),
      );

      log('📡 响应状态码: ${response.statusCode}');
      log('📡 响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          log('✅ 创建 PayPal 订单成功 - 订单号: $orderNo');
          log('PayPal Order ID: ${data['orderId']}');
          log('approveUrl: ${data['approveUrl']}');
          return data;
        } else {
          log('❌ 后端返回失败: ${data['message'] ?? data['error'] ?? '未知错误'}');
        }
      } else {
        log('❌ HTTP 状态码异常: ${response.statusCode}');
        log('❌ 响应内容: ${response.body}');
      }

      return null;
    } catch (error) {
      log('❌ 创建 PayPal 订单异常: $error');
      return null;
    }
  }

  /// 处理 PayPal 支付（完整流程）
  static Future<bool> processPayment(
    BuildContext context,
    double amount,
    String orderNo, {
    String itemName = '挪威旅游服务订单',
  }) async {
    // Step 1: 创建 PayPal 订单
    final orderResponse = await createOrder(orderNo, amount);
    if (orderResponse == null || orderResponse['approveUrl'] == null) {
      log('❌ 创建订单失败');
      return false;
    }

    final approveUrl = orderResponse['approveUrl'];
    final paypalOrderId = orderResponse['orderId'];

    log('🌐 打开 WebView: $approveUrl');

    // Step 2: 在 WebView 中打开支付页面，等待用户完成支付
    final paymentResult = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => ServicePayPalPage(
              approveUrl: approveUrl,
              orderNo: orderNo,
              paypalOrderId: paypalOrderId,
            ),
      ),
    );

    log('📤 WebView 返回结果: $paymentResult');
    return paymentResult == true;
  }
}

/// PayPal 沙盒支付页面组件
class ServicePayPalPage extends StatefulWidget {
  final String approveUrl;
  final String orderNo;
  final String paypalOrderId;

  const ServicePayPalPage({
    super.key,
    required this.approveUrl,
    required this.orderNo,
    required this.paypalOrderId,
  });

  @override
  State<ServicePayPalPage> createState() => _ServicePayPalPageState();
}

class _ServicePayPalPageState extends State<ServicePayPalPage> {
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
                log('📄 页面加载开始: $url');
              },
              onPageFinished: (String url) {
                log('✅ 页面加载完成: $url');
                setState(() {
                  _isLoading = false;
                });
                _checkPaymentStatus(url);
              },
              onWebResourceError: (WebResourceError error) {
                log('❌ WebView 错误: $error');
                if (!_hasCompleted) {
                  _handlePaymentFailure();
                }
              },
              // ✅ 关键：在导航请求时拦截自定义 Scheme
              onNavigationRequest: (NavigationRequest request) {
                final url = request.url;
                log('🔗 导航请求: $url');

                if (_hasCompleted) {
                  return NavigationDecision.prevent;
                }

                // 检查自定义 URL scheme 成功回调
                if (url.startsWith('myapp://paypal/success')) {
                  log('✅ 支付成功 - URL scheme: $url');
                  _hasCompleted = true;
                  _handlePaymentSuccess();
                  return NavigationDecision.prevent;
                }

                // 检查自定义 URL scheme 失败回调
                if (url.startsWith('myapp://paypal/failed') ||
                    url.startsWith('myapp://paypal/cancel')) {
                  log('❌ 支付失败/取消 - URL scheme: $url');
                  _hasCompleted = true;
                  _handlePaymentFailure();
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
              onSslAuthError: (SslAuthError error) {
                log('⚠️ SSL 错误，继续加载');
                error.proceed();
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.approveUrl));
  }

  void _handlePaymentSuccess() {
    log('🎉 支付成功，关闭 WebView，返回 true');
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _handlePaymentFailure() {
    log('❌ 支付失败，关闭 WebView，返回 false');
    if (mounted) {
      Navigator.pop(context, false);
    }
  }

  void _checkPaymentStatus(String url) {
    if (_hasCompleted) return;

    log('🔍 检查支付状态 URL: $url');

    // 检查后端成功回调页面
    if (url.contains('/api/paypal/success')) {
      log('⏳ 后端成功回调页面，等待 JavaScript 重定向到 myapp://...');
      return;
    }

    // 检查后端取消回调页面
    if (url.contains('/api/paypal/cancel')) {
      log('⏳ 后端取消回调页面，等待 JavaScript 重定向到 myapp://...');
      return;
    }

    // 检查 PayPal 错误页面
    if (url.contains('paypal.com') &&
        (url.contains('error') ||
            url.contains('denied') ||
            url.contains('failed'))) {
      log('❌ PayPal 错误页面: $url');
      _hasCompleted = true;
      _handlePaymentFailure();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal 支付'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (!_hasCompleted) {
              log('👆 用户点击返回按钮关闭支付页面');
              _hasCompleted = true;
              Navigator.pop(context, false);
            } else {
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

/// 简化的 PayPal 支付方法
class PayPalPayment {
  static Future<bool> pay(
    BuildContext context,
    double amount,
    String orderNo,
  ) async {
    return await ServicePayPalService.processPayment(context, amount, orderNo);
  }
}
