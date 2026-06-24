import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'app_shared.dart';

class ServiceAlipayAppService {
  static const String baseUrl = AppConfig.baseWebUrl;

  static Future<Map<String, dynamic>?> createOrder(
    String orderNo,
    double amount, {
    String subject = '挪威旅游服务订单',
    String body = '订单支付',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/alipay/create-order');
      log('📡 创建支付宝App订单请求: $url');
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

    final payUrl = orderResponse['payUrl'] as String;
    log('📱 尝试调用支付宝App: $payUrl');

    final bool alipayInstalled = await _isAlipayInstalled();

    if (alipayInstalled) {
      log('✅ 检测到支付宝App已安装');
      return await _launchAlipayApp(payUrl, orderNo);
    } else {
      log('⚠️ 未检测到支付宝App，使用WebView方式');
      return await _launchAlipayWebView(context, payUrl, orderNo);
    }
  }

  static Future<bool> _isAlipayInstalled() async {
    try {
      final uri = Uri.parse('alipays://platformapi/startapp');
      final canLaunch = await canLaunchUrl(uri);
      log('🔍 支付宝App安装检测: $canLaunch');
      return canLaunch;
    } catch (e) {
      log('❌ 检测支付宝App失败: $e');
      return false;
    }
  }

  static Future<bool> _launchAlipayApp(String payUrl, String orderNo) async {
    try {
      final uri = Uri.parse(payUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        log('✅ 成功调用支付宝App');
        final result = await _waitForAlipayResult(orderNo);
        return result;
      } else {
        log('❌ 调用支付宝App失败');
        return false;
      }
    } catch (e) {
      log('❌ 调用支付宝App异常: $e');
      return false;
    }
  }

  static Future<bool> _waitForAlipayResult(String orderNo) async {
    log('⏳ 等待用户完成支付宝操作，3秒后查询订单状态...');
    await Future.delayed(const Duration(seconds: 3));

    for (int i = 0; i < 5; i++) {
      log('🔍 第${i + 1}次查询订单状态...');
      final status = await _queryOrderStatus(orderNo);
      if (status != null) {
        if (status == 'TRADE_SUCCESS' || status == 'TRADE_FINISHED') {
          log('✅ 支付成功！');
          return true;
        } else if (status == 'TRADE_CLOSED') {
          log('❌ 交易已关闭');
          return false;
        }
      }

      if (i < 4) {
        log('⏳ 订单状态未更新，2秒后重试...');
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    log('⚠️ 查询超时，请手动确认支付结果');
    return false;
  }

  static Future<String?> _queryOrderStatus(String orderNo) async {
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
          return data['status'];
        }
      }
      return null;
    } catch (e) {
      log('❌ 查询订单状态异常: $e');
      return null;
    }
  }

  static Future<bool> _launchAlipayWebView(
    BuildContext context,
    String payUrl,
    String orderNo,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                _AlipayAppFallbackPage(payUrl: payUrl, orderNo: orderNo),
      ),
    );
    return result == true;
  }
}

class _AlipayAppFallbackPage extends StatefulWidget {
  final String payUrl;
  final String orderNo;

  const _AlipayAppFallbackPage({required this.payUrl, required this.orderNo});

  @override
  State<_AlipayAppFallbackPage> createState() => _AlipayAppFallbackPageState();
}

class _AlipayAppFallbackPageState extends State<_AlipayAppFallbackPage> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    final controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
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
                log('❌ WebView 错误: ${error.description}');
                if (!_hasCompleted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                final url = request.url;
                log('🔗 导航请求: $url');

                if (_hasCompleted) {
                  return NavigationDecision.prevent;
                }

                if (url.startsWith('alipays://') ||
                    url.startsWith('alipay://')) {
                  log('📱 检测到支付宝App回调');
                  _tryLaunchAlipayApp(url);
                  return NavigationDecision.prevent;
                }

                if (url.startsWith('myapp://alipay/success')) {
                  log('✅ 支付成功 - URL scheme');
                  _hasCompleted = true;
                  _handlePaymentSuccess();
                  return NavigationDecision.prevent;
                }

                if (url.startsWith('myapp://alipay/cancel') ||
                    url.startsWith('myapp://alipay/failed')) {
                  log('❌ 支付失败/取消 - URL scheme');
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

  Future<void> _tryLaunchAlipayApp(String url) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        log('✅ 成功调用支付宝App');
      } else {
        log('❌ 调用支付宝App失败');
      }
    } catch (e) {
      log('❌ 调用支付宝App异常: $e');
    }
  }

  void _checkPaymentStatus(String url) {
    if (_hasCompleted) return;

    if (url.contains('/alipay/success') ||
        url.contains('trade_status=TRADE_SUCCESS')) {
      log('✅ 支付成功');
      _hasCompleted = true;
      _handlePaymentSuccess();
      return;
    }

    if (url.contains('/alipay/cancel')) {
      log('❌ 支付取消');
      _hasCompleted = true;
      _handlePaymentFailure();
      return;
    }
  }

  void _handlePaymentSuccess() {
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _handlePaymentFailure() {
    if (mounted) {
      Navigator.pop(context, false);
    }
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
              Navigator.pop(context, false);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
