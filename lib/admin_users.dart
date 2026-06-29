// admin_users.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_shared.dart' as shared;
import 'admin_api.dart';
import 'admin_models.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final List<AdminUser> _users = [];
  int _total = 0;
  int _page = 1;
  final int _limit = 10;
  bool _isLoading = false;
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final result = await AdminApi.getUsers(
        page: _page,
        limit: _limit,
        keyword: _searchCtrl.text.trim(),
      );
      final data = result['data'];
      final listRaw =
          data is Map && data.containsKey('list')
              ? data['list'] as List? ?? []
              : (data is List ? data : []);
      final parsedList = listRaw.map((e) => AdminUser.fromJson(e)).toList();
      final total =
          (data is Map && data.containsKey('total')
                  ? (data['total'] ?? parsedList.length)
                  : parsedList.length)
              as int;
      setState(() {
        _users
          ..clear()
          ..addAll(parsedList);
        _total = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    setState(() => _page = 1);
    _loadUsers();
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    _loadUsers();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
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
          _buildToolbar(
            loc,
            isDark,
            cardBg,
            borderColor,
            textPrimary,
            textSecondary,
          ),
          SizedBox(height: 16.h),
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
                    _isLoading && _users.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _users.isEmpty
                        ? _buildEmptyState(loc, isDark, textSecondary)
                        : _buildUserTable(
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
            loc.translate('admin_users'),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
        SizedBox(
          width: 280.w,
          height: 42.h,
          child: TextField(
            controller: _searchCtrl,
            style: TextStyle(color: textPrimary, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: loc.translate('user_search_hint'),
              hintStyle: TextStyle(color: textSecondary, fontSize: 13.sp),
              prefixIcon: Icon(Icons.search, size: 18.sp, color: textSecondary),
              filled: true,
              fillColor: cardBg,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
                borderRadius: BorderRadius.circular(8.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                borderRadius: BorderRadius.circular(8.w),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
            ),
            onSubmitted: (_) => _onSearch(),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          height: 42.h,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => _page = 1);
              _loadUsers();
            },
            icon: Icon(Icons.refresh, size: 16.sp),
            label: Text(
              loc.translate('admin_refresh'),
              style: TextStyle(fontSize: 13.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? const Color(0xFF475569) : const Color(0xFF64748B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.w),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          height: 42.h,
          child: ElevatedButton.icon(
            onPressed:
                () => _showUserDialog(
                  loc,
                  isDark,
                  cardBg,
                  borderColor,
                  textPrimary,
                  textSecondary,
                ),
            icon: Icon(Icons.add, size: 16.sp),
            label: Text(
              loc.translate('user_add'),
              style: TextStyle(fontSize: 13.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
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
            Icons.people_outline,
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

  Widget _buildUserTable(
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
              _headerCell('', 1, textPrimary, 13),
              _headerCell(loc.translate('user_name'), 2, textPrimary, 13),
              _headerCell(loc.translate('user_email'), 2, textPrimary, 13),
              _headerCell(loc.translate('user_phone'), 2, textPrimary, 13),
              _headerCell(loc.translate('user_country'), 1, textPrimary, 13),
              _headerCell(loc.translate('user_active'), 1, textPrimary, 13),
              _headerCell(loc.translate('user_created'), 2, textPrimary, 13),
              _headerCell(loc.translate('admin_actions'), 1, textPrimary, 13),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: ListView.separated(
            controller: _scrollCtrl,
            itemCount: _users.length,
            separatorBuilder:
                (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: borderColor.withOpacity(0.4),
                ),
            itemBuilder:
                (context, index) => _buildUserRow(
                  _users[index],
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

  Widget _headerCell(String text, int flex, Color? color, double? fontSize) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: fontSize?.sp ?? 13.sp,
        ),
      ),
    );
  }

  Widget _buildUserRow(
    AdminUser user,
    shared.AppLocalizations loc,
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Expanded(flex: 1, child: _avatar(user, isDark, textSecondary)),
          Expanded(
            flex: 2,
            child: Text(
              user.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textPrimary,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user.email,
              style: TextStyle(color: textPrimary, fontSize: 13.sp),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user.telephone ?? '-',
              style: TextStyle(color: textPrimary, fontSize: 13.sp),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              user.country ?? '-',
              style: TextStyle(color: textPrimary, fontSize: 13.sp),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color:
                    (user.active ?? 0) > 0
                        ? Colors.green.withOpacity(0.12)
                        : Colors.grey.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6.w),
              ),
              child: Text(
                (user.active ?? 0) > 0
                    ? loc.translate('user_active_yes')
                    : loc.translate('user_active_no'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: (user.active ?? 0) > 0 ? Colors.green : Colors.grey,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(user.createdAt),
              style: TextStyle(color: textSecondary, fontSize: 12.sp),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionChip(
                  Icons.edit,
                  loc.translate('admin_edit'),
                  isDark,
                  cardBg,
                  textPrimary,
                  () => _showUserDialog(
                    loc,
                    isDark,
                    cardBg,
                    borderColorForUser(isDark),
                    textPrimary,
                    textSecondary,
                    user: user,
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
                    user,
                    loc,
                    isDark,
                    cardBg,
                    textPrimary,
                    textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color borderColorForUser(bool isDark) =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  Widget _avatar(AdminUser user, bool isDark, Color textSecondary) {
    final hasAvatar = user.avatar != null && user.avatar!.isNotEmpty;
    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20.w),
        image:
            hasAvatar
                ? DecorationImage(
                  image: NetworkImage(user.avatar!),
                  fit: BoxFit.cover,
                )
                : null,
      ),
      child:
          hasAvatar
              ? null
              : Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
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

  // ========== 新增 / 编辑用户 ==========
  Future<void> _showUserDialog(
    shared.AppLocalizations loc,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary, {
    AdminUser? user,
  }) async {
    final isEdit = user != null;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final phoneCtrl = TextEditingController(text: user?.telephone ?? '');
    final countryCtrl = TextEditingController(text: user?.country ?? '');
    final remarkCtrl = TextEditingController(text: user?.remark ?? '');
    final passwordCtrl = TextEditingController();
    int active = user?.active ?? 1;

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
                    isEdit
                        ? loc.translate('user_edit')
                        : loc.translate('user_add'),
                    style: TextStyle(color: textPrimary, fontSize: 18.sp),
                  ),
                  content: SizedBox(
                    width: 480.w,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _textField(
                            loc.translate('user_name'),
                            nameCtrl,
                            borderColor,
                            textPrimary,
                            textSecondary,
                            required: true,
                          ),
                          SizedBox(height: 12.h),
                          _textField(
                            loc.translate('user_email'),
                            emailCtrl,
                            borderColor,
                            textPrimary,
                            textSecondary,
                            required: true,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 12.h),
                          _textField(
                            loc.translate('user_password'),
                            passwordCtrl,
                            borderColor,
                            textPrimary,
                            textSecondary,
                            hint:
                                isEdit
                                    ? loc.translate('user_password_edit_hint')
                                    : loc.translate('user_password_required'),
                            obscure: true,
                          ),
                          SizedBox(height: 12.h),
                          _textField(
                            loc.translate('user_phone'),
                            phoneCtrl,
                            borderColor,
                            textPrimary,
                            textSecondary,
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 12.h),
                          _textField(
                            loc.translate('user_country'),
                            countryCtrl,
                            borderColor,
                            textPrimary,
                            textSecondary,
                          ),
                          SizedBox(height: 12.h),
                          _textField(
                            loc.translate('user_remark'),
                            remarkCtrl,
                            borderColor,
                            textPrimary,
                            textSecondary,
                            maxLines: 2,
                          ),
                          SizedBox(height: 12.h),
                          DropdownButtonFormField<int>(
                            value: active,
                            dropdownColor: cardBg,
                            decoration: InputDecoration(
                              labelText: loc.translate('user_active'),
                              labelStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 13.sp,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor),
                                borderRadius: BorderRadius.circular(8.w),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFF3B82F6),
                                ),
                                borderRadius: BorderRadius.circular(8.w),
                              ),
                            ),
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14.sp,
                            ),
                            items: [
                              DropdownMenuItem<int>(
                                value: 1,
                                child: Text(loc.translate('user_active_yes')),
                              ),
                              DropdownMenuItem<int>(
                                value: 0,
                                child: Text(loc.translate('user_active_no')),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setDialogState(() => active = v);
                            },
                          ),
                        ],
                      ),
                    ),
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
                        final name = nameCtrl.text.trim();
                        final email = emailCtrl.text.trim();
                        final password = passwordCtrl.text.trim();
                        if (name.isEmpty || email.isEmpty) return;
                        if (!isEdit && password.isEmpty) return;

                        final payload = <String, dynamic>{
                          'name': name,
                          'email': email,
                          'telephone': phoneCtrl.text.trim(),
                          'country': countryCtrl.text.trim(),
                          'remark': remarkCtrl.text.trim(),
                          'active': active,
                        };
                        if (password.isNotEmpty) payload['password'] = password;

                        final res =
                            isEdit
                                ? await AdminApi.updateUser(user.id, payload)
                                : await AdminApi.createUser(payload);

                        if (res['code'] == 200 || res['success'] == true) {
                          if (mounted) Navigator.pop(ctx);
                          _loadUsers();
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
                        isEdit
                            ? loc.translate('admin_save')
                            : loc.translate('admin_create'),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController ctrl,
    Color borderColor,
    Color textPrimary,
    Color textSecondary, {
    bool required = false,
    bool obscure = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: textPrimary, fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        hintStyle: TextStyle(color: textSecondary, fontSize: 13.sp),
        labelStyle: TextStyle(color: textSecondary, fontSize: 13.sp),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(8.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
          borderRadius: BorderRadius.circular(8.w),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    );
  }

  // ========== 删除用户 ==========
  Future<void> _confirmDelete(
    AdminUser user,
    shared.AppLocalizations loc,
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
  ) async {
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
              '${loc.translate('user_delete_message')} ${user.name}？',
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
                  final res = await AdminApi.deleteUser(user.id);
                  if (res['code'] == 200 || res['success'] == true) {
                    if (mounted) Navigator.pop(ctx);
                    _loadUsers();
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
