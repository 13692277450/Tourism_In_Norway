// service_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_in_norway/service_models.dart';

class ServiceApi {
  // 使用您的服务器地址
  static const String baseUrl = 'http://pavogroup.top:3005/api/service';

  // 获取分类列表
  static Future<List<ServiceCategory>> getCategories() async {
    try {
      final url = Uri.parse('$baseUrl/categories');
      print('📡 请求分类URL: $url');
      
      final response = await http.get(url);
      print('📡 分类响应状态码: ${response.statusCode}');
      print('📡 分类响应内容: ${response.body}');
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final list = decoded['data'] as List? ?? [];
        return list.map((item) => ServiceCategory.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ 获取分类失败: $e');
      return [];
    }
  }

  // 获取商品列表
  static Future<Map<String, dynamic>> getGoods({
    int page = 1,
    int limit = 20,
    String? keyword,
    int? categoryId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/goods').replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        if (categoryId != null && categoryId > 0) 'category_id': categoryId.toString(),
      });
      
      print('📡 请求商品URL: $uri');
      
      final response = await http.get(uri);
      print('📡 商品响应状态码: ${response.statusCode}');
      print('📡 商品响应内容前200字符: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded;
      }
      return {'code': response.statusCode, 'data': {'list': [], 'total': 0}};
    } catch (e) {
      print('❌ 获取商品失败: $e');
      return {'code': 500, 'data': {'list': [], 'total': 0}};
    }
  }

  // 获取商品详情
  static Future<ServiceGoods?> getGoodsDetail(int id) async {
    try {
      final url = Uri.parse('$baseUrl/goods/$id');
      print('📡 请求商品详情URL: $url');
      
      final response = await http.get(url);
      print('📡 商品详情响应状态码: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return ServiceGoods.fromJson(decoded['data']);
      }
      return null;
    } catch (e) {
      print('❌ 获取商品详情失败: $e');
      return null;
    }
  }

  // 获取商品评论
  static Future<Map<String, dynamic>> getComments(int goodsId, {int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/goods/$goodsId/comments?page=$page&limit=$limit'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'data': {'list': [], 'total': 0}};
    } catch (e) {
      print('❌ 获取评论失败: $e');
      return {'data': {'list': [], 'total': 0}};
    }
  }

  // 点赞/取消点赞
  static Future<bool> toggleLike(int goodsId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/goods/$goodsId/like'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ 点赞失败: $e');
      return false;
    }
  }

  // 获取购物车
  static Future<List<ServiceCartItem>> getCart(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart?user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final list = decoded['data']['list'] as List? ?? [];
        return list.map((item) => ServiceCartItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ 获取购物车失败: $e');
      return [];
    }
  }

  // 添加购物车
  static Future<bool> addToCart(int userId, int goodsId, {int quantity = 1}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'goods_id': goodsId,
          'quantity': quantity,
        }),
      );
      
      final decoded = json.decode(response.body);
      return decoded['code'] == 200;
    } catch (e) {
      print('❌ 添加购物车失败: $e');
      return false;
    }
  }

  // 更新购物车
  static Future<bool> updateCart({int? cartId, int? quantity, bool? selected}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cart/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          if (cartId != null) 'cart_id': cartId,
          if (quantity != null) 'quantity': quantity,
          if (selected != null) 'selected': selected,
        }),
      );
      
      final decoded = json.decode(response.body);
      return decoded['code'] == 200;
    } catch (e) {
      print('❌ 更新购物车失败: $e');
      return false;
    }
  }

  // 删除购物车项
  static Future<bool> removeCartItem(int cartId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/remove/$cartId'),
      );
      
      final decoded = json.decode(response.body);
      return decoded['code'] == 200;
    } catch (e) {
      print('❌ 删除购物车失败: $e');
      return false;
    }
  }

  // 获取地址列表
  static Future<List<ServiceAddress>> getAddresses(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/address?user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final list = decoded['data'] as List? ?? [];
        return list.map((item) => ServiceAddress.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ 获取地址失败: $e');
      return [];
    }
  }

  // 保存地址
  static Future<bool> saveAddress(ServiceAddress address, int userId, {int? id}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/address'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          if (id != null) 'id': id,
          'receiver_name': address.receiverName,
          'receiver_phone': address.receiverPhone,
          'province': address.province,
          'city': address.city,
          'district': address.district,
          'detail_address': address.detailAddress,
          'is_default': address.isDefault,
        }),
      );
      
      final decoded = json.decode(response.body);
      return decoded['code'] == 200;
    } catch (e) {
      print('❌ 保存地址失败: $e');
      return false;
    }
  }

  // 删除地址
  static Future<bool> deleteAddress(int addressId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/address/$addressId'),
      );
      
      final decoded = json.decode(response.body);
      return decoded['code'] == 200;
    } catch (e) {
      print('❌ 删除地址失败: $e');
      return false;
    }
  }

  // 创建订单
  static Future<Map<String, dynamic>> createOrder({
    required int userId,
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? remark,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/order/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'address_id': addressId,
          'items': items,
          'remark': remark,
        }),
      );
      
      return json.decode(response.body);
    } catch (e) {
      print('❌ 创建订单失败: $e');
      return {'code': 500, 'message': '创建失败'};
    }
  }

  // 获取订单详情
  static Future<ServiceOrder?> getOrder(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/order/$orderId'),
      );
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final order = ServiceOrder.fromJson(decoded['data']);
        final items = decoded['data']['items'] as List? ?? [];
        order.items = items.map((item) => ServiceOrderItem.fromJson(item)).toList();
        return order;
      }
      return null;
    } catch (e) {
      print('❌ 获取订单失败: $e');
      return null;
    }
  }
}