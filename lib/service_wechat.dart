// service_wechat.dart
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:tourism_in_norway/user_auth.dart';

class ServiceWeChatService {
  // 初始化微信支付
  static Future<void> initWeChat() async {
    final fluwxInstance = fluwx.Fluwx();

    await fluwxInstance.registerApi(
      appId: "wx1234567890abcdef", // 替换为您的微信支付AppID
      universalLink: "$baseUrl/wechatpay", // 替换为您的微信支付Universal Link
    );
  }

  // 处理微信支付
  static Future<bool> processPayment(double amount, String orderNo) async {
    try {
      // 构建支付参数
      final fluwxInstance = fluwx.Fluwx();
      final payParams = fluwx.Payment(
        appId: "wx1234567890abcdef", // 替换为您的微信支付AppID
        partnerId: "1234567890", // 替换为商户ID
        prepayId: "wx_prepay_$orderNo", // 替换为从服务端获取的prepayId
        packageValue: "Sign=WXPay",
        nonceStr: _generateNonceStr(),
        timestamp: _generateTimestamp(),
        sign: "", // 替换为从服务端获取的签名
      );

      // 发起微信支付
      final result = await fluwxInstance.pay(which: payParams);

      // 检查支付结果
      return result;
    } catch (e) {
      print('❌ 微信支付失败: $e');
      return false;
    }
  }

  // 生成随机字符串
  static String _generateNonceStr() {
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    return random.substring(0, 16);
  }

  // 生成时间戳
  static int _generateTimestamp() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
}
