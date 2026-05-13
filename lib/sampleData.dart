import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 定义品牌数据结构
class BrandItem {
  final String name;
  final String category;
  final Color color;

  const BrandItem({required this.name, required this.category, required this.color});
}

// 生成测试数据
final List<BrandItem> testBrands = [
  // 手机
  BrandItem(name: 'iPhone 15', category: 'Mobile', color: Colors.blueGrey),
  BrandItem(name: 'Samsung S24', category: 'Mobile', color: Colors.black),
  // 笔记本
  BrandItem(name: 'MacBook Pro', category: 'Laptop', color: Colors.grey),
  BrandItem(name: 'ThinkPad X1', category: 'Laptop', color: Colors.black87),
  // Pad
  BrandItem(name: 'iPad Air', category: 'Pad', color: Colors.purpleAccent),
  BrandItem(name: 'Galaxy Tab', category: 'Pad', color: Colors.blue),
  // 电视
  BrandItem(name: 'Sony Bravia', category: 'TV', color: Colors.orange),
  BrandItem(name: 'LG OLED', category: 'TV', color: Colors.redAccent),
  // 洗衣机
  BrandItem(name: 'Siemens Wash', category: 'Washer', color: Colors.teal),
  BrandItem(name: 'Haier Smart', category: 'Washer', color: Colors.cyan),
  // 空调
  BrandItem(name: 'Daikin AC', category: 'AC', color: Colors.lightBlue),
  BrandItem(name: 'Gree Cool', category: 'AC', color: Colors.green),
];

class BrandGrid extends StatelessWidget {
  const BrandGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16.w,
      runSpacing: 16.h,
      children: testBrands.map((brand) => _buildBrandCard(brand)).toList(),
    );
  }

  Widget _buildBrandCard(BrandItem brand) {
    return Container(
      width: 171.w, // 固定宽度
      height: 220.h, // 假设一个固定高度用于展示，或者根据内容自适应
      decoration: BoxDecoration(
        color: brand.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: brand.color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(brand.category),
            size: 48.r,
            color: brand.color,
          ),
          SizedBox(height: 8.h),
          Text(
            brand.name,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            brand.category,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Mobile': return Icons.phone_iphone;
      case 'Laptop': return Icons.laptop_mac;
      case 'Pad': return Icons.tablet_mac;
      case 'TV': return Icons.tv;
      case 'Washer': return Icons.local_laundry_service;
      case 'AC': return Icons.ac_unit;
      default: return Icons.device_unknown;
    }
  }
}