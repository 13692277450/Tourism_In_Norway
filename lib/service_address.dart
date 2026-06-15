// service_address.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'service_models.dart';
import 'service_api.dart';
import 'service_theme.dart' as theme;
import 'app_shared.dart';

class ServiceAddressPage extends StatefulWidget {
  final int? selectedAddressId;

  const ServiceAddressPage({super.key, this.selectedAddressId});

  @override
  State<ServiceAddressPage> createState() => _ServiceAddressPageState();
}

class _ServiceAddressPageState extends State<ServiceAddressPage> {
  List<ServiceAddress> _addresses = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    try {
      // ✅ 从 UserManager 获取真实用户ID
      final userManager = UserManager();
      final user = userManager.currentUser;
      setState(() {
        _currentUserId = user?.user_id ?? 0;
      });
      print('✅ 地址页面 - 当前用户ID: $_currentUserId');

      // 用户加载完成后再加载地址
      if (_currentUserId != null && _currentUserId != 0) {
        await _loadAddresses();
      } else {
        setState(() => _isLoading = false);
        // 如果未登录，提示用户登录
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('请先登录')));
        }
      }
    } catch (e) {
      print('❌ 加载用户失败: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAddresses() async {
    if (_currentUserId == null || _currentUserId == 0) {
      print('⚠️ 用户未登录，无法加载地址');
      return;
    }

    print('📡 开始加载用户 $_currentUserId 的地址列表...');
    final addresses = await ServiceApi.getAddresses(_currentUserId!);
    print('✅ 加载到 ${addresses.length} 个地址');

    setState(() {
      _addresses = addresses;
      _isLoading = false;
    });
  }

  Future<void> _setDefaultAddress(ServiceAddress address) async {
    if (address.isDefault) return;

    setState(() {
      for (var a in _addresses) {
        a.isDefault = false;
      }
      address.isDefault = true;
    });

    await ServiceApi.saveAddress(address, _currentUserId!, id: address.id);
    await _loadAddresses();
    _showSuccess('已设为默认地址');
  }

  Future<void> _deleteAddress(ServiceAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除该地址吗？'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('删除'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await ServiceApi.deleteAddress(address.id);
      await _loadAddresses();
      _showSuccess('已删除');
    }
  }

  void _addOrEditAddress({ServiceAddress? address}) {
    if (_currentUserId == null || _currentUserId == 0) {
      _showError('请先登录');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ServiceAddressEditPage(
              address: address,
              userId: _currentUserId!,
            ),
      ),
    ).then((_) => _loadAddresses());
  }

  void _selectAddress(ServiceAddress address) {
    print('✅ 选择地址: ${address.receiverName}, ID: ${address.id}');
    Navigator.pop(context, address);
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? theme.ServiceMetalColors.darkBg
              : theme.ServiceMetalColors.lightBg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '收货地址',
          style: TextStyle(
            color:
                isDark
                    ? theme.ServiceMetalColors.primary
                    : theme.ServiceMetalColors.lightText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? theme.ServiceMetalColors.primary : null,
            ),
            onPressed: () => _addOrEditAddress(),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _addresses.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final address = _addresses[index];
                  return _buildAddressCard(address, isDark);
                },
              ),
      floatingActionButton:
          _addresses.isNotEmpty
              ? FloatingActionButton(
                onPressed: () => _addOrEditAddress(),
                backgroundColor:
                    isDark
                        ? theme.ServiceMetalColors.darkSurface
                        : theme.ServiceMetalColors.primary,
                child: Icon(
                  Icons.add,
                  color:
                      isDark ? theme.ServiceMetalColors.primary : Colors.white,
                ),
              )
              : null,
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 80.sp,
            color:
                isDark
                    ? theme.ServiceMetalColors.primary.withOpacity(0.5)
                    : Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无收货地址',
            style: TextStyle(
              fontSize: 16.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),
          _buildMetalButton('添加新地址', () => _addOrEditAddress(), isDark),
        ],
      ),
    );
  }

  Widget _buildAddressCard(ServiceAddress address, bool isDark) {
    final isSelected = widget.selectedAddressId == address.id;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              isSelected
                  ? theme.ServiceMetalColors.primary
                  : (isDark
                      ? theme.ServiceMetalColors.primary.withOpacity(0.3)
                      : Colors.grey[200]!),
          width: isSelected ? 2 : 1,
        ),
        boxShadow:
            isDark
                ? [
                  BoxShadow(
                    color: theme.ServiceMetalColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAddress(address),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            address.receiverName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Text(
                            address.receiverPhone,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (address.isDefault)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              theme.ServiceMetalColors.primary,
                              theme.ServiceMetalColors.accent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '默认',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  address.fullAddress,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!address.isDefault)
                      TextButton(
                        onPressed: () => _setDefaultAddress(address),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.ServiceMetalColors.primary,
                        ),
                        child: const Text('设为默认'),
                      ),
                    TextButton(
                      onPressed: () => _addOrEditAddress(address: address),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.ServiceMetalColors.primary,
                      ),
                      child: const Text('编辑'),
                    ),
                    TextButton(
                      onPressed: () => _deleteAddress(address),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.ServiceMetalColors.primary,
                      ),
                      child: const Text('删除'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetalButton(String text, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.w,
        height: 44.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              theme.ServiceMetalColors.primary,
              theme.ServiceMetalColors.accent,
            ],
          ),
          borderRadius: BorderRadius.circular(22.r),
          boxShadow:
              isDark
                  ? [
                    BoxShadow(
                      color: theme.ServiceMetalColors.primary,
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: theme.ServiceMetalColors.accent,
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                  : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// 地址编辑页面（保持不变）
class ServiceAddressEditPage extends StatefulWidget {
  final ServiceAddress? address;
  final int userId;

  const ServiceAddressEditPage({super.key, this.address, required this.userId});

  @override
  State<ServiceAddressEditPage> createState() => _ServiceAddressEditPageState();
}

class _ServiceAddressEditPageState extends State<ServiceAddressEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _detailController = TextEditingController();
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _nameController.text = widget.address!.receiverName;
      _phoneController.text = widget.address!.receiverPhone;
      _provinceController.text = widget.address!.province;
      _cityController.text = widget.address!.city;
      _districtController.text = widget.address!.district;
      _detailController.text = widget.address!.detailAddress;
      _isDefault = widget.address!.isDefault;
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final address = ServiceAddress(
      id: widget.address?.id ?? 0,
      receiverName: _nameController.text.trim(),
      receiverPhone: _phoneController.text.trim(),
      province: _provinceController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      detailAddress: _detailController.text.trim(),
      isDefault: _isDefault,
    );

    final success = await ServiceApi.saveAddress(
      address,
      widget.userId,
      id: widget.address?.id,
    );

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存失败'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? theme.ServiceMetalColors.darkBg
              : theme.ServiceMetalColors.lightBg,
      appBar: AppBar(
        title: Text(
          widget.address == null ? '添加地址' : '编辑地址',
          style: TextStyle(
            color:
                isDark
                    ? theme.ServiceMetalColors.primary
                    : theme.ServiceMetalColors.lightText,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            _buildTextField(
              controller: _nameController,
              label: '收货人姓名',
              hint: '请输入姓名',
              icon: Icons.person_outline,
              isDark: isDark,
              validator: (v) => v?.isEmpty == true ? '请输入姓名' : null,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _phoneController,
              label: '手机号码',
              hint: '请输入手机号',
              icon: Icons.phone_outlined,
              isDark: isDark,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v?.isEmpty == true) return '请输入手机号';
                if (v!.length != 11) return '请输入正确的手机号';
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _provinceController,
              label: '省份',
              hint: '请输入省份',
              icon: Icons.location_city,
              isDark: isDark,
              validator: (v) => v?.isEmpty == true ? '请输入省份' : null,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _cityController,
              label: '城市',
              hint: '请输入城市',
              icon: Icons.location_city,
              isDark: isDark,
              validator: (v) => v?.isEmpty == true ? '请输入城市' : null,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _districtController,
              label: '区/县',
              hint: '请输入区/县',
              icon: Icons.location_on_outlined,
              isDark: isDark,
              validator: (v) => v?.isEmpty == true ? '请输入区/县' : null,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _detailController,
              label: '详细地址',
              hint: '请输入街道、门牌号等',
              icon: Icons.home_outlined,
              isDark: isDark,
              maxLines: 3,
              validator: (v) => v?.isEmpty == true ? '请输入详细地址' : null,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Checkbox(
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v ?? false),
                  activeColor: theme.ServiceMetalColors.primary,
                  checkColor: Colors.black,
                ),
                Text(
                  '设为默认地址',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : _buildMetalButton('保存地址', _saveAddress, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: theme.ServiceMetalColors.primary),
        filled: true,
        fillColor: isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              isDark
                  ? BorderSide(
                    color: theme.ServiceMetalColors.primary.withOpacity(0.3),
                  )
                  : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: theme.ServiceMetalColors.primary,
            width: 2,
          ),
        ),
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildMetalButton(String text, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              theme.ServiceMetalColors.primary,
              theme.ServiceMetalColors.accent,
            ],
          ),
          borderRadius: BorderRadius.circular(25.r),
          boxShadow:
              isDark
                  ? [
                    BoxShadow(
                      color: theme.ServiceMetalColors.primary,
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: theme.ServiceMetalColors.accent,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                  : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _detailController.dispose();
    super.dispose();
  }
}
