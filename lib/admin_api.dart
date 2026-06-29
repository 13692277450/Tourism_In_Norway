// admin_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_shared.dart' as shared;

class AdminApi {
  static const String baseUrl =
      '${shared.AppConfig.baseWebUrl}:${shared.AppConfig.port3004}/api';

  // ================== 登录相关 ==================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bbs/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded;
      }
      return {'code': response.statusCode, 'message': '登录失败'};
    } catch (e) {
      return {'code': 500, 'message': '网络错误: $e'};
    }
  }

  // ================== 统计数据 ==================
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // 尝试获取统计数据，如果没有则计算默认数据
      final userResponse = await http.get(Uri.parse('$baseUrl/bbs/users'));
      final orderResponse = await http.get(
        Uri.parse(
          '${shared.AppConfig.baseWebUrl}:${shared.AppConfig.port3005}/api/service/orders/admin',
        ),
      );

      int userCount = 0;
      int orderCount = 0;
      double totalRevenue = 0.0;

      if (userResponse.statusCode == 200) {
        final decoded = json.decode(userResponse.body);
        final list = decoded['data'] as List? ?? [];
        userCount = list.length;
      }

      if (orderResponse.statusCode == 200) {
        final decoded = json.decode(orderResponse.body);
        final list = decoded['data'] as List? ?? [];
        orderCount = list.length;
        for (var item in list) {
          totalRevenue += (item['actual_amount'] ?? 0).toDouble();
        }
      }

      return {
        'code': 200,
        'data': {
          'total_users': userCount,
          'total_orders': orderCount,
          'total_revenue': totalRevenue,
          'active_users': (userCount * 0.6).toInt(),
        },
      };
    } catch (e) {
      return {
        'code': 200,
        'data': {
          'total_users': 0,
          'total_orders': 0,
          'total_revenue': 0.0,
          'active_users': 0,
        },
      };
    }
  }

  // ================== 用户管理 ==================
  static Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String keyword = '',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/bbs/users').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (keyword.isNotEmpty) 'keyword': keyword,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {
        'code': response.statusCode,
        'data': {'list': [], 'total': 0},
      };
    } catch (e) {
      return {
        'code': 500,
        'data': {'list': [], 'total': 0},
        'message': '$e',
      };
    }
  }

  static Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bbs/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'code': response.statusCode, 'message': '创建失败'};
    } catch (e) {
      return {'code': 500, 'message': '网络错误: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUser(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bbs/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'code': response.statusCode, 'message': '更新失败'};
    } catch (e) {
      return {'code': 500, 'message': '网络错误: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/bbs/users/$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'code': response.statusCode, 'message': '删除失败'};
    } catch (e) {
      return {'code': 500, 'message': '网络错误: $e'};
    }
  }

  // ================== 订单管理 ==================
  static Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 20,
    String keyword = '',
    int? status,
  }) async {
    try {
      final uri = Uri.parse(
        '${shared.AppConfig.baseWebUrl}:${shared.AppConfig.port3005}/api/service/orders/admin',
      ).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (keyword.isNotEmpty) 'keyword': keyword,
          if (status != null) 'status': status.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {
        'code': response.statusCode,
        'data': {'list': [], 'total': 0},
      };
    } catch (e) {
      return {
        'code': 500,
        'data': {'list': [], 'total': 0},
        'message': '$e',
      };
    }
  }

  static Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${shared.AppConfig.baseWebUrl}:${shared.AppConfig.port3005}/api/service/order/$orderId',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'code': response.statusCode, 'data': null};
    } catch (e) {
      return {'code': 500, 'data': null, 'message': '$e'};
    }
  }

  static Future<Map<String, dynamic>> updateOrder(
    int orderId,
    Map<String, dynamic> orderData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${shared.AppConfig.baseWebUrl}:${shared.AppConfig.port3005}/api/service/order/$orderId',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'code': response.statusCode, 'message': '更新失败'};
    } catch (e) {
      return {'code': 500, 'message': '网络错误: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteOrder(int orderId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${shared.AppConfig.baseWebUrl}:${shared.AppConfig.port3005}/api/service/order/$orderId',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'code': response.statusCode, 'message': '删除失败'};
    } catch (e) {
      return {'code': 500, 'message': '网络错误: $e'};
    }
  }
}
