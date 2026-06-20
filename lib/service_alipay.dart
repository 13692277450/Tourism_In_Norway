// service_alipay.dart
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'app_shared.dart';

/// 支付宝沙箱支付服务
class ServiceAlipayService {
  static const String baseUrl = '${AppConfig.baseWebUrl}:${AppConfig.port3007}';

  /// 创建支付宝订单
  static Future<Map<String, dynamic>?> createOrder(
    String orderNo,
    double amount, {
    String subject = '挪威旅游服务订单',
    String body = '订单支付',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/alipay/create-order');

      log('📡 创建支付宝订单请求: $url');
      log('📦 订单号: $orderNo, 金额: $amount');

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

      log('📡 响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('📡 响应内容: $data');

        if (data['success'] == true && data['payUrl'] != null) {
          log('✅ 创建支付宝订单成功');
          log('🔗 支付链接: ${data['payUrl']}');
          return data;
        } else {
          log('❌ 创建订单失败: ${data['message']}');
        }
      }

      return null;
    } catch (error) {
      log('❌ 创建支付宝订单异常: $error');
      return null;
    }
  }

  /// 处理支付宝支付
  static Future<bool> processPayment(
    BuildContext context,
    double amount,
    String orderNo, {
    String subject = '挪威旅游服务订单',
  }) async {
    final orderResponse = await createOrder(orderNo, amount, subject: subject);
    if (orderResponse == null || orderResponse['payUrl'] == null) {
      log('❌ 创建订单失败');
      return false;
    }

    final payUrl = orderResponse['payUrl'];
    log('🌐 打开支付宝支付页面: $payUrl');

    final paymentResult = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => ServiceAlipayPage(payUrl: payUrl, orderNo: orderNo),
      ),
    );

    log('📤 支付页面返回结果: $paymentResult');
    return paymentResult == true;
  }
}

/// 支付宝支付页面组件
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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    // 创建 WebViewController
    final controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                log('📊 加载进度: $progress%');
                setState(() {
                  _isLoading = progress < 100;
                });
              },
              onPageStarted: (String url) {
                log('📄 页面加载开始: $url');
                setState(() {
                  _errorMessage = null;
                });
              },
              onPageFinished: (String url) {
                log('✅ 页面加载完成: $url');
                setState(() {
                  _isLoading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                log('❌ WebView 错误: ${error.description}');
                if (!_hasCompleted) {
                  setState(() {
                    _errorMessage = '加载失败: ${error.description}';
                    _isLoading = false;
                  });
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                final url = request.url;
                log('🔗 导航请求: $url');

                // 支付宝 App 回调
                if (url.startsWith('alipays://') ||
                    url.startsWith('alipay://')) {
                  log('📱 检测到支付宝 App 回调');
                  return NavigationDecision.prevent;
                }

                // 同步回调成功
                if (url.contains('/alipay/success') ||
                    url.contains('trade_status=TRADE_SUCCESS')) {
                  log('✅ 支付成功: $url');
                  _hasCompleted = true;
                  _handlePaymentSuccess();
                  return NavigationDecision.prevent;
                }

                // 同步回调取消
                if (url.contains('/alipay/cancel')) {
                  log('❌ 支付取消: $url');
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
          );

    _webViewController = controller;
    _webViewController.loadRequest(Uri.parse(widget.payUrl));
  }

  void _handlePaymentSuccess() {
    log('🎉 支付成功');
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _handlePaymentFailure() {
    log('❌ 支付失败');
    if (mounted) {
      Navigator.pop(context, false);
    }
  }

  void _retryLoad() {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    _webViewController.loadRequest(Uri.parse(widget.payUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('支付宝支付'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (!_hasCompleted) {
              Navigator.pop(context, false);
            } else {
              Navigator.pop(context, false);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // WebView
          WebViewWidget(controller: _webViewController),

          // 加载指示器
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // 错误提示
          if (_errorMessage != null)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _retryLoad,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
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
