import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_shared.dart' as shared;

// --- 数据模型 (对应 MySQL 表结构) ---

class Sku {
  final int skuId;
  final String skuName;
  final double price;
  final double originalPrice;
  final Map<String, dynamic> attributes; // JSON field

  Sku({
    required this.skuId,
    required this.skuName,
    required this.price,
    required this.originalPrice,
    required this.attributes,
  });

  factory Sku.fromJson(Map<String, dynamic> json) {
    return Sku(
      skuId: json['sku_id'] ?? 0,
      skuName: json['sku_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: (json['original_price'] ?? 0).toDouble(),
      attributes: json['attributes'] ?? {},
    );
  }
}

class Product {
  final int productId;
  final String name;
  final String description;
  final String imageUrl;
  final bool isOnSale;
  final List<Sku> skus;
  bool isFavorite;

  Product({
    required this.productId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isOnSale,
    required this.skus,
    this.isFavorite = false,
  });

  // 获取最低价格作为展示价格
  double get minPrice {
    if (skus.isEmpty) return 0;
    return skus.map((s) => s.price).reduce((a, b) => a < b ? a : b);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // 注意：实际后端返回可能需要调整，这里假设 skus 是嵌套在 product 里的，
    // 或者你需要分别请求。为了演示，我们假设一个简单的扁平化结构或嵌套结构。
    // 如果后端返回的是分离的表，需要在 State 中组装。
    List<dynamic> skuList = json['skus'] ?? [];
    return Product(
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['main_image_url'] ?? '',
      isOnSale: json['is_on_sale'] ?? true,
      skus: skuList.map((s) => Sku.fromJson(s)).toList(),
      isFavorite: json['is_favorite'] ?? false,
    );
  }
}

class CartItem {
  final Product product;
  final Sku sku;
  int quantity;

  CartItem({
    required this.product,
    required this.sku,
    this.quantity = 1,
  });

  double get subtotal => sku.price * quantity;
}

// --- 页面主体 ---

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final List<CartItem> _cartItems = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMockData(); // 实际项目中替换为 API 请求
  }

  // 模拟从后端加载数据 (对应 MySQL 查询)
  void _loadMockData() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _allProducts = [
          Product(
            productId: 1,
            name: 'iPhone 15 Pro',
            description: 'Titanium design, A17 Pro chip.',
            imageUrl: 'https://via.placeholder.com/300x300?text=iPhone+15',
            isOnSale: true,
            skus: [
              Sku(skuId: 101, skuName: '128GB Black', price: 7999, originalPrice: 8999, attributes: {'color': 'Black'}),
              Sku(skuId: 102, skuName: '256GB Blue', price: 8999, originalPrice: 9999, attributes: {'color': 'Blue'}),
            ],
          ),
          Product(
            productId: 2,
            name: 'MacBook Air M3',
            description: 'Lean. Mean. M3 machine.',
            imageUrl: 'https://via.placeholder.com/300x300?text=MacBook',
            isOnSale: true,
            skus: [
              Sku(skuId: 201, skuName: '8GB/256GB', price: 8999, originalPrice: 9499, attributes: {}),
            ],
          ),
          Product(
            productId: 3,
            name: 'Sony WH-1000XM5',
            description: 'Industry-leading noise canceling.',
            imageUrl: 'https://via.placeholder.com/300x300?text=Headphones',
            isOnSale: false,
            skus: [
              Sku(skuId: 301, skuName: 'Black', price: 2499, originalPrice: 2499, attributes: {}),
            ],
          ),
           Product(
            productId: 4,
            name: 'Nike Air Jordan',
            description: 'Classic basketball shoes.',
            imageUrl: 'https://via.placeholder.com/300x300?text=Sneakers',
            isOnSale: true,
            skus: [
              Sku(skuId: 401, skuName: 'US 10', price: 1299, originalPrice: 1599, attributes: {}),
            ],
          ),
        ];
        _filteredProducts = _allProducts;
        _isLoading = false;
      });
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((p) =>
          p.name.toLowerCase().contains(query.toLowerCase()) ||
          p.description.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  void _toggleFavorite(Product product) {
    setState(() {
      product.isFavorite = !product.isFavorite;
      // TODO: 调用 API 更新数据库 favorites 表
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(product.isFavorite ? '已加入收藏夹' : '已取消收藏'),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  void _addToCart(Product product) {
    // 简单逻辑：默认添加第一个 SKU
    if (product.skus.isEmpty) return;
    
    final sku = product.skus.first;
    
    setState(() {
      final existingItem = _cartItems.firstWhere(
        (item) => item.product.productId == product.productId && item.sku.skuId == sku.skuId,
        orElse: () => CartItem(product: product, sku: sku, quantity: 0),
      );

      if (existingItem.quantity > 0) {
        existingItem.quantity++;
      } else {
        _cartItems.add(CartItem(product: product, sku: sku, quantity: 1));
      }
      
      // TODO: 调用 API 插入/更新 cart_items 表
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已添加 ${product.name} 到购物车'),
        action: SnackBarAction(
          label: '查看',
          onPressed: _showCartSheet,
        ),
      ),
    );
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => _CartList(
          cartItems: _cartItems,
          onRemove: (item) {
            setState(() {
              _cartItems.remove(item);
              // TODO: 调用 API 删除 cart_items
            });
          },
          onCheckout: () {
            Navigator.pop(context);
            _placeOrder();
          },
        ),
      ),
    );
  }

  void _placeOrder() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('购物车为空')));
      return;
    }

    // 模拟下单
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认订单'),
        content: Text('共 ${_cartItems.length} 件商品，总金额: ¥${_calculateTotal().toStringAsFixed(2)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _cartItems.clear(); // 清空购物车
                // TODO: 调用 API 创建 orders 和 order_items
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('下单成功！正在跳转支付...')),
              );
            },
            child: const Text('立即支付'),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    return _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  @override
  Widget build(BuildContext context) {
    final loc = shared.AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(loc.shopTitle, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: 跳转到收藏夹页面
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('收藏夹功能开发中...')));
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: _showCartSheet,
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${_cartItems.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索商品...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
              ),
              onChanged: _filterProducts,
            ),
          ),
          
          // 商品列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? Center(child: Text('未找到相关商品', style: TextStyle(color: Colors.grey)))
                    : GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return _ProductCard(
                            product: product,
                            onFavorite: () => _toggleFavorite(product),
                            onAddToCart: () => _addToCart(product),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// --- 子组件: 商品卡片 ---

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onFavorite;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.onFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Image.network(
                  product.imageUrl,
                  height: 140.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 140.h, color: Colors.grey[200]),
                ),
              ),
              // 收藏按钮
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: onFavorite,
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      product.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: product.isFavorite ? Colors.red : Colors.grey,
                      size: 18.r,
                    ),
                  ),
                ),
              ),
              // 促销标签
              if (product.minPrice < product.skus.first.originalPrice)
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Text(
                      'SALE',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          
          // 信息区域
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      '¥${product.minPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    if (product.minPrice < product.skus.first.originalPrice)
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Text(
                          '¥${product.skus.first.originalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAddToCart,
                    icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D5AFE),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 子组件: 购物车列表 (Bottom Sheet) ---

class _CartList extends StatelessWidget {
  final List<CartItem> cartItems;
  final Function(CartItem) onRemove;
  final VoidCallback onCheckout;

  const _CartList({
    required this.cartItems,
    required this.onRemove,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shopping Cart (${cartItems.length})', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          Divider(),
          
          // 列表
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text('Your cart is empty'))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: Image.network(item.product.imageUrl, width: 50.w, height: 50.h, fit: BoxFit.cover),
                        title: Text(item.product.name, style: TextStyle(fontSize: 14.sp)),
                        subtitle: Text('${item.sku.skuName} x${item.quantity}', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('¥${item.subtotal.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 8.w),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => onRemove(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // 底部结算栏
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total', style: TextStyle(color: Colors.grey)),
                    Text('¥${cartItems.fold(0.0, (sum, i) => sum + i.subtotal).toStringAsFixed(2)}', 
                         style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
                ElevatedButton(
                  onPressed: cartItems.isEmpty ? null : onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D5AFE),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                  ),
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}