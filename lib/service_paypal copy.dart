// // service_paypal.dart
// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:webview_flutter/webview_flutter.dart';
// import 'app_shared.dart';

// class ServicePayPalService {
//   // PayPal 配置
//   static const String baseUrl = '${AppConfig.baseWebUrl}:3006'; // 后端服务器地址

//   /// 1. 创建 PayPal 订单
//   static Future<Map<String, dynamic>?> createOrder(
//     String orderNo,
//     double amount,
//   ) async {
//     try {
//       final url = Uri.parse('$baseUrl/api/paypal/create-order');
//       log('📡 创建订单请求: $url');

//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'orderNo': orderNo,
//           'amount': amount.toStringAsFixed(2),
//         }),
//       );

//       log('📡 创建订单响应状态: ${response.statusCode}');
//       log('📡 响应内容: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           log('✅ 创建 PayPal 订单成功 - 订单号: $orderNo');
//           log('PayPal Order ID: ${data['orderId']}');
//           log('approveUrl: ${data['approveUrl']}');
//           return data;
//         }
//       }

//       log('❌ 创建 PayPal 订单失败: ${response.body}');
//       return null;
//     } catch (error) {
//       log('❌ 创建 PayPal 订单异常: $error');
//       return null;
//     }
//   }

//   /// 2. 捕获 PayPal 订单（完成扣款）
//   static Future<bool> captureOrder(String orderId, String orderNo) async {
//     try {
//       final url = Uri.parse('$baseUrl/api/paypal/capture-order');
//       log('📡 捕获订单请求: $url');

//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'orderId': orderId, 'orderNo': orderNo}),
//       );

//       log('📡 捕获订单响应状态: ${response.statusCode}');
//       log('📡 响应内容: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           log('✅ 捕获 PayPal 订单成功 - 订单号: $orderNo');
//           return true;
//         }
//       }

//       log('❌ 捕获 PayPal 订单失败: ${response.body}');
//       return false;
//     } catch (error) {
//       log('❌ 捕获 PayPal 订单异常: $error');
//       return false;
//     }
//   }

//   /// 处理 PayPal 支付（完整流程）
//   static Future<bool> processPayment(
//     BuildContext context,
//     double amount,
//     String orderNo, {
//     String itemName = '挪威旅游服务订单',
//   }) async {
//     // Step 1: 创建 PayPal 订单
//     final orderResponse = await createOrder(orderNo, amount);
//     if (orderResponse == null || orderResponse['approveUrl'] == null) {
//       log('❌ 创建订单失败');
//       return false;
//     }

//     final approveUrl = orderResponse['approveUrl'];
//     final paypalOrderId = orderResponse['orderId'];

//     log('🌐 打开 WebView: $approveUrl');

//     // Step 2: 在 WebView 中打开支付页面
//     final paymentResult = await Navigator.push<bool>(
//       context,
//       MaterialPageRoute(
//         builder:
//             (context) => ServicePayPalPage(
//               approveUrl: approveUrl,
//               orderNo: orderNo,
//               paypalOrderId: paypalOrderId,
//             ),
//       ),
//     );

//     log('📤 WebView 返回结果: $paymentResult');

//     // Step 3: 如果用户完成审批，执行捕获订单
//     if (paymentResult == true) {
//       log('🔄 开始捕获订单...');
//       return await captureOrder(paypalOrderId, orderNo);
//     }

//     log('❌ 支付流程未完成');
//     return false;
//   }
// }

// /// PayPal 沙盒支付页面组件
// class ServicePayPalPage extends StatefulWidget {
//   final String approveUrl;
//   final String orderNo;
//   final String paypalOrderId;

//   const ServicePayPalPage({
//     super.key,
//     required this.approveUrl,
//     required this.orderNo,
//     required this.paypalOrderId,
//   });

//   @override
//   State<ServicePayPalPage> createState() => _ServicePayPalPageState();
// }

// class _ServicePayPalPageState extends State<ServicePayPalPage> {
//   late WebViewController _webViewController;
//   bool _isLoading = true;
//   bool _hasCompleted = false;

//   @override
//   void initState() {
//     super.initState();
//     _initWebViewController();
//   }

//   void _initWebViewController() {
//     _webViewController =
//         WebViewController()
//           ..setJavaScriptMode(JavaScriptMode.unrestricted)
//           ..setBackgroundColor(const Color(0x00000000))
//           ..setNavigationDelegate(
//             NavigationDelegate(
//               onProgress: (int progress) {
//                 setState(() {
//                   _isLoading = progress < 100;
//                 });
//               },
//               onPageStarted: (String url) {
//                 log('📄 页面加载开始: $url');
//               },
//               onPageFinished: (String url) {
//                 log('✅ 页面加载完成: $url');
//                 setState(() {
//                   _isLoading = false;
//                 });
//               },
//               onWebResourceError: (WebResourceError error) {
//                 log('❌ WebView 错误: $error');
//                 if (!_hasCompleted) {
//                   _handlePaymentFailure();
//                 }
//               },
//               onNavigationRequest: (NavigationRequest request) {
//                 log('🔗 导航请求: ${request.url}');

//                 // 🔑 关键：检测是否跳转到成功或取消页面
//                 final url = request.url;

//                 // 方式1：检测后端回调 URL
//                 if (url.contains('/api/payment/success') ||
//                     url.contains('/api/payment/cancel') ||
//                     url.contains('/api/payment/failed')) {
//                   _handleBackendCallback(url);
//                   return NavigationDecision.prevent;
//                 }

//                 // 方式2：检测自定义 scheme（备用）
//                 if (url.startsWith('myapp://')) {
//                   _handleDeepLink(url);
//                   return NavigationDecision.prevent;
//                 }

//                 return NavigationDecision.navigate;
//               },
//             ),
//           )
//           ..loadRequest(Uri.parse(widget.approveUrl));
//   }

//   /// 处理后端回调 URL
//   void _handleBackendCallback(String url) async {
//     if (_hasCompleted) return;

//     log('📞 检测到后端回调: $url');

//     if (url.contains('/api/payment/success')) {
//       log('✅ 支付审批成功 - 订单号: ${widget.orderNo}');
//       log('PayPal Order ID: ${widget.paypalOrderId}');
//       _hasCompleted = true;
//       _handlePaymentSuccess();
//     } else if (url.contains('/api/payment/cancel')) {
//       log('❌ 用户取消支付 - 订单号: ${widget.orderNo}');
//       _hasCompleted = true;
//       _handlePaymentFailure();
//     } else if (url.contains('/api/payment/failed')) {
//       log('❌ 支付失败 - 订单号: ${widget.orderNo}');
//       _hasCompleted = true;
//       _handlePaymentFailure();
//     }
//   }

//   /// 处理自定义 scheme 回调
//   void _handleDeepLink(String url) {
//     if (_hasCompleted) return;

//     log('🔗 检测到自定义 scheme: $url');

//     if (url.contains('/payment/success')) {
//       log('✅ 支付成功（scheme） - 订单号: ${widget.orderNo}');
//       _hasCompleted = true;
//       _handlePaymentSuccess();
//     } else if (url.contains('/payment/cancel')) {
//       log('❌ 支付取消（scheme） - 订单号: ${widget.orderNo}');
//       _hasCompleted = true;
//       _handlePaymentFailure();
//     } else if (url.contains('/payment/failed')) {
//       log('❌ 支付失败（scheme） - 订单号: ${widget.orderNo}');
//       _hasCompleted = true;
//       _handlePaymentFailure();
//     }
//   }

//   void _handlePaymentSuccess() {
//     log('🎉 支付成功，关闭 WebView，返回 true');
//     Navigator.pop(context, true);
//   }

//   void _handlePaymentFailure() {
//     log('❌ 支付失败，关闭 WebView，返回 false');
//     Navigator.pop(context, false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PayPal 支付'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             if (!_hasCompleted) {
//               log('👆 用户点击返回按钮关闭支付页面');
//               _hasCompleted = true;
//               Navigator.pop(context, false);
//             } else {
//               Navigator.pop(context, false);
//             }
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _webViewController),
//           if (_isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }

// /// 简化的 PayPal 支付方法
// class PayPalPayment {
//   static Future<bool> pay(
//     BuildContext context,
//     double amount,
//     String orderNo,
//   ) async {
//     return await ServicePayPalService.processPayment(context, amount, orderNo);
//   }
// }
