// service_paypal.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ServicePayPalService {
  // 虚拟的 PayPal API 凭证（实际项目中应从环境变量获取）
  static const String clientId = 'AVirtualClientId1234567890';
  static const String secretKey = 'AVirtualSecretKey1234567890';

  /// 处理 PayPal 支付
  static Future<bool> processPayment(
    BuildContext context,
    double amount,
    String orderNo,
  ) async {
    try {
      // 构建 PayPal 支付链接（简化版）
      final paypalUrl = Uri.parse(
        'https://www.sandbox.paypal.com/cgi-bin/webscr'
        '?cmd=_xclick'
        '&business=your_email@example.com'
        '&item_name=Order%20%23$orderNo'
        '&amount=${amount.toStringAsFixed(2)}'
        '&currency_code=USD'
        '&return=https://yourdomain.com/payment/success'
        '&cancel_return=https://yourdomain.com/payment/cancel',
      );

      // 使用 url_launcher 打开 PayPal 支付页面
      if (await canLaunchUrl(paypalUrl)) {
        await launchUrl(paypalUrl, mode: LaunchMode.externalApplication);

        // 模拟支付流程（实际项目中应等待回调）
        await Future.delayed(const Duration(seconds: 5));

        // 显示支付确认对话框
        final result = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('支付确认'),
                content: const Text('请确认您的 PayPal 支付是否成功？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('支付失败'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('支付成功'),
                  ),
                ],
              ),
        );

        return result == true;
      } else {
        debugPrint('无法打开 PayPal 链接');
        return false;
      }
    } catch (e) {
      debugPrint('PayPal 支付异常: $e');
      return false;
    }
  }
}
