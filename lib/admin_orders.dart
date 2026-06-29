// admin_orders.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_shared.dart' as shared;
import 'admin_api.dart';
import 'admin_models.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final List<AdminOrder> _orders = [];
  int _total = 0;
  int _page = 1;
  final int _limit = 10;
  bool _isLoading = false;
  int? _statusFilter;
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  static const List<int> _statusList = [0, 1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final result = await AdminApi.getOrders(
        page: _page,
        limit: _limit,
        keyword: _searchCtrl.text.trim(),
        status: _statusFilter,
      );
      final data = result['data'];
      final listRaw =
          data is Map && data.containsKey('list')
              ? data['list'] as List? ?? []
              : (data is List ? data : []);
      final parsedList = listRaw.map((e) => AdminOrder.fromJson(e)).toList();
      final total =
          (data is Map && data.containsKey('total')
                  ? (data['total'] ?? parsedList.length)
                  : parsedList.length)
              as int;
      setState(() {
        _orders
          ..clear()
          ..addAll(parsedList);
        _total = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _setStatusFilter(int? value) {
    setState(() {
      _statusFilter = value;
      _page = 1;
    });
    _loadOrders();
  }

  void _onSearch() {
    setState(() => _page = 1);
    _loadOrders();
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    _loadOrders();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _statusText(shared.AppLocalizations loc, int status) {
    switch (status) {
      case 1:
        return loc.translate('order_status_1');
      case 2:
        return loc.translate('order_status_2');
      case 3:
        return loc.translate('order_status_3');
      case 4:
        return loc.translate('order_status_4');
      case 0:
      default:
        return loc.translate('order_status_0');
    }
  }

  Color _statusColor(int status, bool isDark) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.indigo;
      case 3:
        return Colors.green;
      case 4:
      default:
        return Colors.red;
    }
  }

  String _payStatusText(shared.AppLocalizations loc, int? payStatus) {
    if (payStatus == null || payStatus == 0) {
      return loc.translate('order_unpaid');
    }
    return loc.translate('order_paid');
  }

  @override
  Widget build(BuildContext context) {
    final loc = shared.AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      color: surface,
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题与搜索栏
          _buildToolbar(
            loc,
            isDark,
            cardBg,
            borderColor,
            textPrimary,
            textSecondary,
          ),
          SizedBox(height: 16.h),
          // 表格
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.w),
                child:
                    _isLoading && _orders.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _orders.isEmpty
                        ? _buildEmptyState(loc, isDark, textSecondary)
                        : _buildOrderTable(
                          loc,
                          isDark,
                          cardBg,
                          borderColor,
                          textPrimary,
                          textSecondary,
                        ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // 分页
          _buildPagination(
            loc,
            isDark,
            cardBg,
            borderColor,
            textPrimary,
            textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(
    shared.AppLocalizations loc,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            loc.translate('admin_orders'),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
        Container(
          width: 280.w,
          height: 42.h,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: _searchCtrl,
            style: TextStyle(color: textPrimary, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: loc.translate('order_search_hint'),
              hintStyle: TextStyle(color: textSecondary, fontSize: 13.sp),
              prefixIcon: Icon(Icons.search, size: 18.sp, color: textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
            ),
            onSubmitted: (_) => _onSearch(),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          height: 42.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _statusFilter,
              dropdownColor: cardBg,
              icon: Icon(Icons.filter_list, size: 16.sp, color: textSecondary),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(
                    loc.translate('filter_all'),
                    style: TextStyle(color: textPrimary, fontSize: 13.sp),
                  ),
                ),
                ..._statusList.map(
                  (s) => DropdownMenuItem<int?>(
                    value: s,
                    child: Text(
                      _statusText(loc, s),
                      style: TextStyle(color: textPrimary, fontSize: 13.sp),
                    ),
                  ),
                ),
              ],
              onChanged: (v) => _setStatusFilter(v),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          height: 42.h,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => _page = 1);
              _loadOrders();
            },
            icon: Icon(Icons.refresh, size: 16.sp),
            label: Text(
              loc.translate('admin_refresh'),
              style: TextStyle(fontSize: 13.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? const Color(0xFF3B82F6) : const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.w),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    shared.AppLocalizations loc,
    bool isDark,
    Color textSecondary,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80.sp,
            color: textSecondary.withOpacity(0.4),
          ),
          SizedBox(height: 16.h),
          Text(
            loc.translate('admin_no_data'),
            style: TextStyle(color: textSecondary, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTable(
    shared.AppLocalizations loc,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final headerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(color: headerBg),
          child: Row(
            children: [
              _headerCell(
                loc.translate('order_no'),
                flex: 2,
                color: textPrimary,
                fontSize: 13.sp,
              ),
              _headerCell(
                loc.translate('order_user'),
                flex: 2,
                color: textPrimary,
                fontSize: 13.sp,
              ),
              _headerCell(
                loc.translate('order_total'),
                flex: 1,
                color: textPrimary,
                fontSize: 13.sp,
              ),
              _headerCell(
                loc.translate('order_status'),
                flex: 1,
                color: textPrimary,
                fontSize: 13.sp,
              ),
              _headerCell(
                loc.translate('order_pay_status'),
                flex: 1,
                color: textPrimary,
                fontSize: 13.sp,
              ),
              _headerCell(
                loc.translate('order_created'),
                flex: 1,
                color: textPrimary,
                fontSize: 13.sp,
              ),
              _headerCell(
                loc.translate('admin_actions'),
                flex: 1,
                color: textPrimary,
                fontSize: 13.sp,
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: ListView.separated(
            controller: _scrollCtrl,
            itemCount: _orders.length,
            separatorBuilder:
                (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: borderColor.withOpacity(0.4),
                ),
            itemBuilder:
                (context, index) => _buildOrderRow(
                  _orders[index],
                  loc,
                  isDark,
                  cardBg,
                  textPrimary,
                  textSecondary,
                ),
          ),
        ),
      ],
    );
  }

  Widget _headerCell(
    String text, {
    required int flex,
    required Color color,
    required double fontSize,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: fontSize.sp,
        ),
      ),
    );
  }

  Widget _buildOrderRow(
    AdminOrder order,
    shared.AppLocalizations loc,
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
  ) {
    return InkWell(
      onTap:
          () =>
              _showOrderDetail(order, loc, isDark, textPrimary, textSecondary),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                order.orderNo,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  fontSize: 13.sp,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'ID:${order.userId ?? '-'}',
                style: TextStyle(color: textPrimary, fontSize: 13.sp),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '¥${order.actualAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                  fontSize: 13.sp,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _statusColor(order.status, isDark).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child: Text(
                  _statusText(loc, order.status),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _statusColor(order.status, isDark),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                _payStatusText(loc, order.payStatus),
                style: TextStyle(
                  color:
                      (order.payStatus ?? 0) > 0 ? Colors.green : Colors.orange,
                  fontSize: 13.sp,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                _formatDate(order.createdAt),
                style: TextStyle(color: textSecondary, fontSize: 12.sp),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionChip(
                    Icons.visibility,
                    loc.translate('admin_view'),
                    isDark,
                    cardBg,
                    textPrimary,
                    () => _showOrderDetail(
                      order,
                      loc,
                      isDark,
                      textPrimary,
                      textSecondary,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  _buildActionChip(
                    Icons.edit,
                    loc.translate('admin_edit'),
                    isDark,
                    cardBg,
                    textPrimary,
                    () => _showEditDialog(
                      order,
                      loc,
                      isDark,
                      textPrimary,
                      textSecondary,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  _buildActionChip(
                    Icons.delete_outline,
                    loc.translate('admin_delete'),
                    isDark,
                    cardBg,
                    const Color(0xFFEF4444),
                    () => _confirmDelete(
                      order,
                      loc,
                      isDark,
                      textPrimary,
                      textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(
    IconData icon,
    String label,
    bool isDark,
    Color cardBg,
    Color textPrimary,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: textPrimary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(6.w),
          ),
          child: Icon(icon, size: 14.sp, color: textPrimary),
        ),
      ),
    );
  }

  Widget _buildPagination(
    shared.AppLocalizations loc,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final totalPages = (_total / _limit).ceil();
    final displayPages = <int>[];
    final startPage = (_page - 2).clamp(1, totalPages > 0 ? totalPages : 1);
    final endPage = startPage + 4;
    for (int i = startPage; i <= endPage && i <= totalPages; i++) {
      displayPages.add(i);
    }

    return Row(
      children: [
        Text(
          '${loc.translate('admin_total')}: $_total',
          style: TextStyle(color: textSecondary, fontSize: 13.sp),
        ),
        const Spacer(),
        IconButton(
          onPressed: _page > 1 ? () => _onPageChanged(_page - 1) : null,
          icon: const Icon(Icons.chevron_left),
          color: textPrimary,
        ),
        ...displayPages.map(
          (p) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: InkWell(
              onTap: () => _onPageChanged(p),
              borderRadius: BorderRadius.circular(6.w),
              child: Container(
                width: 32.w,
                height: 32.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      p == _page ? const Color(0xFF3B82F6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child: Text(
                  '$p',
                  style: TextStyle(
                    color: p == _page ? Colors.white : textPrimary,
                    fontSize: 13.sp,
                    fontWeight: p == _page ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed:
              _page < totalPages ? () => _onPageChanged(_page + 1) : null,
          icon: const Icon(Icons.chevron_right),
          color: textPrimary,
        ),
      ],
    );
  }

  // ========== 查看订单详情 ==========
  Future<void> _showOrderDetail(
    AdminOrder order,
    shared.AppLocalizations loc,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) async {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.w),
            ),
            title: Text(
              loc.translate('order_detail'),
              style: TextStyle(color: textPrimary, fontSize: 18.sp),
            ),
            content: SizedBox(
              width: 600.w,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(
                      loc.translate('order_no'),
                      order.orderNo,
                      textPrimary,
                      textSecondary,
                    ),
                    _infoRow(
                      loc.translate('order_amount'),
                      '¥${order.actualAmount.toStringAsFixed(2)}',
                      textPrimary,
                      textSecondary,
                    ),
                    _infoRow(
                      loc.translate('order_status'),
                      _statusText(loc, order.status),
                      textPrimary,
                      textSecondary,
                    ),
                    _infoRow(
                      loc.translate('order_pay_status'),
                      _payStatusText(loc, order.payStatus),
                      textPrimary,
                      textSecondary,
                    ),
                    _infoRow(
                      loc.translate('order_receiver'),
                      order.receiverName,
                      textPrimary,
                      textSecondary,
                    ),
                    _infoRow(
                      loc.translate('order_phone'),
                      order.receiverPhone,
                      textPrimary,
                      textSecondary,
                    ),
                    _infoRow(
                      loc.translate('order_address'),
                      order.receiverAddress,
                      textPrimary,
                      textSecondary,
                    ),
                    _infoRow(
                      loc.translate('order_created'),
                      _formatDate(order.createdAt),
                      textPrimary,
                      textSecondary,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      loc.translate('order_items'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (order.items.isEmpty)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        child: Text(
                          loc.translate('admin_no_data'),
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 13.sp,
                          ),
                        ),
                      )
                    else
                      ...order.items.map(
                        (item) => Container(
                          padding: EdgeInsets.all(12.w),
                          margin: EdgeInsets.only(bottom: 8.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                          child: Row(
                            children: [
                              if (item.goodsImage != null &&
                                  item.goodsImage!.isNotEmpty)
                                Container(
                                  width: 50.w,
                                  height: 50.h,
                                  margin: EdgeInsets.only(right: 12.w),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8.w),
                                    image: DecorationImage(
                                      image: NetworkImage(item.goodsImage!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 50.w,
                                  height: 50.h,
                                  margin: EdgeInsets.only(right: 12.w),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8.w),
                                  ),
                                  child: Icon(
                                    Icons.shop,
                                    color: textSecondary,
                                    size: 24.sp,
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.goodsName,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '¥${item.price.toStringAsFixed(2)} × ${item.quantity}',
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                '¥${item.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: const Color(0xFF3B82F6),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  loc.translate('admin_close'),
                  style: TextStyle(color: textPrimary, fontSize: 14.sp),
                ),
              ),
            ],
          ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: TextStyle(color: textSecondary, fontSize: 13.sp),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textPrimary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== 编辑订单状态 ==========
  Future<void> _showEditDialog(
    AdminOrder order,
    shared.AppLocalizations loc,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) async {
    int newStatus = order.status;
    int? newPayStatus = order.payStatus;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctxDialog, setDialogState) => AlertDialog(
                  backgroundColor: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                  title: Text(
                    loc.translate('order_edit'),
                    style: TextStyle(color: textPrimary, fontSize: 18.sp),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<int>(
                        value: newStatus,
                        dropdownColor: cardBg,
                        decoration: InputDecoration(
                          labelText: loc.translate('order_status'),
                          labelStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 13.sp,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                            ),
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF3B82F6),
                            ),
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                        ),
                        style: TextStyle(color: textPrimary, fontSize: 14.sp),
                        items:
                            _statusList
                                .map<DropdownMenuItem<int>>(
                                  (s) => DropdownMenuItem<int>(
                                    value: s,
                                    child: Text(_statusText(loc, s)),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => newStatus = v);
                        },
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<int?>(
                        value: newPayStatus,
                        dropdownColor: cardBg,
                        decoration: InputDecoration(
                          labelText: loc.translate('order_pay_status'),
                          labelStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 13.sp,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                            ),
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF3B82F6),
                            ),
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                        ),
                        style: TextStyle(color: textPrimary, fontSize: 14.sp),
                        items: [
                          DropdownMenuItem<int?>(
                            value: 0,
                            child: Text(loc.translate('order_unpaid')),
                          ),
                          DropdownMenuItem<int?>(
                            value: 1,
                            child: Text(loc.translate('order_paid')),
                          ),
                        ],
                        onChanged: (v) {
                          setDialogState(() => newPayStatus = v);
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        loc.translate('admin_cancel'),
                        style: TextStyle(color: textPrimary, fontSize: 14.sp),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final res = await AdminApi.updateOrder(order.id, {
                          'status': newStatus,
                          'pay_status': newPayStatus,
                        });
                        if (res['code'] == 200 || res['success'] == true) {
                          if (mounted) Navigator.pop(ctx);
                          _loadOrders();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                      ),
                      child: Text(
                        loc.translate('admin_save'),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  // ========== 删除订单 ==========
  Future<void> _confirmDelete(
    AdminOrder order,
    shared.AppLocalizations loc,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) async {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.w),
            ),
            title: Text(
              loc.translate('admin_delete_confirm'),
              style: TextStyle(color: textPrimary, fontSize: 18.sp),
            ),
            content: Text(
              '${loc.translate('order_delete_message')} ${order.orderNo}？',
              style: TextStyle(color: textSecondary, fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  loc.translate('admin_cancel'),
                  style: TextStyle(color: textPrimary, fontSize: 14.sp),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final res = await AdminApi.deleteOrder(order.id);
                  if (res['code'] == 200 || res['success'] == true) {
                    if (mounted) Navigator.pop(ctx);
                    _loadOrders();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
                child: Text(
                  loc.translate('admin_delete'),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
    );
  }
}
