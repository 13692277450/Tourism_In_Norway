// admin_models.dart

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class AdminUser {
  final int id;
  final int? userId;
  final String name;
  final String email;
  final String? telephone;
  final int? active;
  final String? country;
  final String? remark;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdminUser({
    required this.id,
    this.userId,
    required this.name,
    required this.email,
    this.telephone,
    this.active,
    this.country,
    this.remark,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : null,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'],
      active: json['active'],
      country: json['country'],
      remark: json['remark'],
      avatar: json['avatar'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
    );
  }
}

class AdminOrder {
  final int id;
  final String orderNo;
  final int? userId;
  final double totalAmount;
  final double actualAmount;
  final int status;
  final int? payStatus;
  final String? payMethod;
  final DateTime? payTime;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final String? remark;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<AdminOrderItem> items;

  AdminOrder({
    required this.id,
    required this.orderNo,
    this.userId,
    required this.totalAmount,
    required this.actualAmount,
    required this.status,
    this.payStatus,
    this.payMethod,
    this.payTime,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    this.remark,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    List<AdminOrderItem> items = [];
    if (json['items'] is List) {
      items =
          (json['items'] as List)
              .map((e) => AdminOrderItem.fromJson(e))
              .toList();
    }

    return AdminOrder(
      id: json['id'] ?? 0,
      orderNo: json['order_no'] ?? '',
      userId: json['user_id'],
      totalAmount: _toDouble(json['total_amount']),
      actualAmount: _toDouble(json['actual_amount']),
      status: json['status'] ?? 0,
      payStatus: json['pay_status'],
      payMethod: json['pay_method'],
      payTime:
          json['pay_time'] != null ? DateTime.tryParse(json['pay_time']) : null,
      receiverName: json['receiver_name'] ?? '',
      receiverPhone: json['receiver_phone'] ?? '',
      receiverAddress: json['receiver_address'] ?? '',
      remark: json['remark'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
      items: items,
    );
  }
}

class AdminOrderItem {
  final int id;
  final int goodsId;
  final String goodsName;
  final String? goodsImage;
  final double price;
  final int quantity;
  final double totalAmount;

  AdminOrderItem({
    required this.id,
    required this.goodsId,
    required this.goodsName,
    this.goodsImage,
    required this.price,
    required this.quantity,
    required this.totalAmount,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderItem(
      id: json['id'] ?? 0,
      goodsId: json['goods_id'] ?? 0,
      goodsName: json['goods_name'] ?? '',
      goodsImage: json['goods_image'],
      price: _toDouble(json['price']),
      quantity: json['quantity'] ?? 0,
      totalAmount: _toDouble(json['total_amount']),
    );
  }
}
