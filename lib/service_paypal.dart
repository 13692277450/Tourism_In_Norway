import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'app_shared.dart';

class ServicePayPalService {
  static const String clientId =
      'AdjY4PDq9K4D1BXdU0GtusDJyMjsLQwyiUOe3wd9B5SXb582bM2bqEqfczsEskSlcOnif4VTfX5T9MH-';
  static const String baseUrl = AppConfig.baseWebUrl;

  static Future<String?> createOrder(double amount, String orderNo) async {
    try {
      final url = Uri.parse('$baseUrl/api/paypal/create-order');
      log('📡 创建 PayPal 订单: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'orderNo': orderNo,
          'amount': amount.toStringAsFixed(2),
        }),
      );

      log('📡 响应: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          log('✅ 订单创建成功: ${data['orderId']}');
          return data['orderId'];
        }
      }
      log('❌ 创建订单失败');
      return null;
    } catch (e) {
      log('❌ 创建订单异常: $e');
      return null;
    }
  }

  static Future<bool> captureOrder(String orderId) async {
    try {
      final url = Uri.parse('$baseUrl/api/paypal/capture-order');
      log('📡 捕获 PayPal 订单: $orderId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'orderId': orderId}),
      );

      log('📡 捕获响应: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          log('✅ 捕获成功');
          return true;
        }
      }
      log('❌ 捕获失败');
      return false;
    } catch (e) {
      log('❌ 捕获异常: $e');
      return false;
    }
  }

  static Future<bool> processPayment(
    BuildContext context,
    double amount,
    String orderNo,
  ) async {
    final orderId = await createOrder(amount, orderNo);
    if (orderId == null) {
      log('❌ 无法创建订单');
      return false;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => _PayPalCheckoutPage(
              orderId: orderId,
              amount: amount,
              orderNo: orderNo,
            ),
      ),
    );

    return result ?? false;
  }
}

class _PayPalCheckoutPage extends StatefulWidget {
  final String orderId;
  final double amount;
  final String orderNo;

  const _PayPalCheckoutPage({
    required this.orderId,
    required this.amount,
    required this.orderNo,
  });

  @override
  State<_PayPalCheckoutPage> createState() => _PayPalCheckoutPageState();
}

class _PayPalCheckoutPageState extends State<_PayPalCheckoutPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (progress) {
                setState(() {
                  _isLoading = progress < 100;
                });
              },
              onPageStarted: (url) {
                log('📄 页面加载: $url');
              },
              onPageFinished: (url) {
                log('✅ 页面完成: $url');
                setState(() {
                  _isLoading = false;
                });
              },
              onWebResourceError: (error) {
                log('❌ WebView 错误: ${error.description}');
                if (!_hasCompleted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onSslAuthError: (error) {
                log('⚠️ SSL 错误，继续加载');
                error.proceed();
              },
            ),
          );

    _controller = controller;
    _loadPayPalSDK();
  }

  void _loadPayPalSDK() {
    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PayPal Payment</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
      background: #f5f5f5;
    }
    .container {
      text-align: center;
      padding: 20px;
    }
    .loading {
      color: #666;
      font-size: 16px;
      margin-top: 20px;
    }
    #paypal-button-container {
      max-width: 400px;
      margin: 0 auto;
    }
  </style>
</head>
<body>
  <div class="container">
    <div id="paypal-button-container">
      <p class="loading">Loading PayPal...</p>
    </div>
  </div>

  <script src="https://www.paypal.com/sdk/js?client-id=${ServicePayPalService.clientId}&currency=USD&intent=capture"></script>

  <script>
    paypal.Buttons({
      createOrder: function() {
        return "${widget.orderId}";
      },

      onApprove: function(data) {
        fetch("${ServicePayPalService.baseUrl}/api/paypal/capture-order", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ orderId: data.orderID })
        })
        .then(function(res) { return res.json(); })
        .then(function(result) {
          if (result.success) {
            document.body.innerHTML = '<div style="text-align:center;padding:40px;"><h1 style="color:green;">✅ Payment Successful!</h1><p>Order: ${widget.orderNo}</p></div>';
            setTimeout(function() {
              FlutterChannel.postMessage(JSON.stringify({status: "success", orderId: data.orderID}));
            }, 1500);
          } else {
            document.body.innerHTML = '<div style="text-align:center;padding:40px;"><h1 style="color:red;">❌ Payment Failed</h1><p>' + (result.message || 'Unknown error') + '</p></div>';
            setTimeout(function() {
              FlutterChannel.postMessage(JSON.stringify({status: "error", message: result.message}));
            }, 1500);
          }
        })
        .catch(function(err) {
          FlutterChannel.postMessage(JSON.stringify({status: "error", message: err.toString()}));
        });
      },

      onCancel: function() {
        FlutterChannel.postMessage(JSON.stringify({status: "cancel"}));
      },

      onError: function(err) {
        FlutterChannel.postMessage(JSON.stringify({status: "error", message: err.toString()}));
      }
    }).render("#paypal-button-container");
  </script>
</body>
</html>
''';

    _controller.loadHtmlString(html);

    _controller.addJavaScriptChannel(
      'FlutterChannel',
      onMessageReceived: (message) {
        log('📩 收到 JS 消息: ${message.message}');
        _handleJsMessage(message.message);
      },
    );
  }

  void _handleJsMessage(String msg) {
    if (_hasCompleted) return;

    try {
      final data = json.decode(msg);
      final status = data['status'] as String;

      switch (status) {
        case 'success':
          log('✅ 支付成功');
          _hasCompleted = true;
          if (mounted) Navigator.pop(context, true);
          break;
        case 'cancel':
          log('❌ 用户取消支付');
          _hasCompleted = true;
          if (mounted) Navigator.pop(context, false);
          break;
        case 'error':
          log('❌ 支付错误: ${data['message']}');
          _hasCompleted = true;
          if (mounted) Navigator.pop(context, false);
          break;
      }
    } catch (e) {
      log('❌ 解析 JS 消息失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (!_hasCompleted) {
              Navigator.pop(context, false);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
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
