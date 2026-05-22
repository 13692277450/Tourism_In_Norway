// service_models.dart
import 'dart:convert';

class ServiceCategory {
  final int id;
  final String name;
  final String? nameEn;
  final String? icon;

  ServiceCategory({
    required this.id,
    required this.name,
    this.nameEn,
    this.icon,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      icon: json['icon'],
    );
  }
}

class ServiceGoods {
  final int id;
  final String goodsNo;
  final String name;
  final String? nameEn;
  final double price;
  final double? originalPrice;
  final int stock;
  final int score;
  final String? shortDescription;
  final String? description;
  final String? mainImage;
  final List<String> images;
  final int salesCount;
  final int viewCount;
  final int likeCount;
  final String? categoryName;
  bool isLiked;

  ServiceGoods({
    required this.id,
    required this.goodsNo,
    required this.name,
    this.nameEn,
    required this.price,
    this.originalPrice,
    required this.stock,
    required this.score,
    this.shortDescription,
    this.description,
    this.mainImage,
    this.images = const [],
    this.salesCount = 0,
    this.viewCount = 0,
    this.likeCount = 0,
    this.categoryName,
    this.isLiked = false,
  });

  factory ServiceGoods.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        images = (json['images'] as List).map((e) => e.toString()).toList();
      } else if (json['images'] is String) {
        try {
          final parsed = jsonDecode(json['images']);
          if (parsed is List) {
            images = parsed.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
    }

    return ServiceGoods(
      id: json['id'] ?? 0,
      goodsNo: json['goods_no'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['original_price']?.toDouble(),
      stock: json['stock'] ?? 0,
      score: json['score'] ?? 0,
      shortDescription: json['short_description'],
      description: json['description'],
      mainImage: json['main_image'],
      images: images,
      salesCount: json['sales_count'] ?? 0,
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      categoryName: json['category_name'],
    );
  }

  ServiceGoods copyWith({bool? isLiked}) {
    return ServiceGoods(
      id: id,
      goodsNo: goodsNo,
      name: name,
      nameEn: nameEn,
      price: price,
      originalPrice: originalPrice,
      stock: stock,
      score: score,
      shortDescription: shortDescription,
      description: description,
      mainImage: mainImage,
      images: images,
      salesCount: salesCount,
      viewCount: viewCount,
      likeCount: likeCount,
      categoryName: categoryName,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class ServiceCartItem {
  final int id;
  final int goodsId;
  final String goodsNo;
  final String name;
  final String? mainImage;
  final double price;
  int quantity;
  bool selected;
  final int stock;

  ServiceCartItem({
    required this.id,
    required this.goodsId,
    required this.goodsNo,
    required this.name,
    this.mainImage,
    required this.price,
    required this.quantity,
    required this.selected,
    required this.stock,
  });

  factory ServiceCartItem.fromJson(Map<String, dynamic> json) {
    return ServiceCartItem(
      id: json['id'] ?? 0,
      goodsId: json['goods_id'] ?? 0,
      goodsNo: json['goods_no'] ?? '',
      name: json['name'] ?? '',
      mainImage: json['main_image'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      selected: json['selected'] == 1,
      stock: json['stock'] ?? 0,
    );
  }

  double get totalPrice => price * quantity;
}

class ServiceAddress {
  final int id;
  final String receiverName;
  final String receiverPhone;
  final String province;
  final String city;
  final String district;
  final String detailAddress;
  late final bool isDefault;

  ServiceAddress({
    required this.id,
    required this.receiverName,
    required this.receiverPhone,
    required this.province,
    required this.city,
    required this.district,
    required this.detailAddress,
    required this.isDefault,
  });

  factory ServiceAddress.fromJson(Map<String, dynamic> json) {
    return ServiceAddress(
      id: json['id'] ?? 0,
      receiverName: json['receiver_name'] ?? '',
      receiverPhone: json['receiver_phone'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      detailAddress: json['detail_address'] ?? '',
      isDefault: json['is_default'] == 1,
    );
  }

  String get fullAddress => '$province$city$district$detailAddress';
}

class ServiceOrder {
  final int id;
  final String orderNo;
  final double totalAmount;
  final double actualAmount;
  final int status;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final DateTime createdAt;
  final int? deliveryDays;
  List<ServiceOrderItem> items;

  ServiceOrder({
    required this.id,
    required this.orderNo,
    required this.totalAmount,
    required this.actualAmount,
    required this.status,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.createdAt,
    this.deliveryDays,
    this.items = const [],
  });

  factory ServiceOrder.fromJson(Map<String, dynamic> json) {
    return ServiceOrder(
      id: json['id'] ?? 0,
      orderNo: json['order_no'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      actualAmount: (json['actual_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 0,
      receiverName: json['receiver_name'] ?? '',
      receiverPhone: json['receiver_phone'] ?? '',
      receiverAddress: json['receiver_address'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      deliveryDays: json['delivery_days'],
    );
  }
}

class ServiceOrderItem {
  final int id;
  final int goodsId;
  final String goodsName;
  final String? goodsImage;
  final double price;
  final int quantity;
  final double totalAmount;

  ServiceOrderItem({
    required this.id,
    required this.goodsId,
    required this.goodsName,
    this.goodsImage,
    required this.price,
    required this.quantity,
    required this.totalAmount,
  });

  factory ServiceOrderItem.fromJson(Map<String, dynamic> json) {
    return ServiceOrderItem(
      id: json['id'] ?? 0,
      goodsId: json['goods_id'] ?? 0,
      goodsName: json['goods_name'] ?? '',
      goodsImage: json['goods_image'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
    );
  }
}

class ServiceComment {
  final int id;
  final int userId;
  final String userName;
  final int rating;
  final String content;
  final List<String> images;
  final int likeCount;
  final DateTime createdAt;

  ServiceComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.content,
    this.images = const [],
    required this.likeCount,
    required this.createdAt,
  });

  factory ServiceComment.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['images'] != null) {
      try {
        if (json['images'] is String) {
          final parsed = jsonDecode(json['images']);
          if (parsed is List) {
            images = parsed.map((e) => e.toString()).toList();
          }
        }
      } catch (_) {}
    }

    return ServiceComment(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '匿名用户',
      rating: json['rating'] ?? 5,
      content: json['content'] ?? '',
      images: images,
      likeCount: json['like_count'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}