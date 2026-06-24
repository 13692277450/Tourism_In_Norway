// education_home.dart - 教育首页

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_shared.dart' as shared;

class EducationHomePage extends StatefulWidget {
  const EducationHomePage({super.key});

  @override
  State<EducationHomePage> createState() => _EducationHomePageState();
}

class _EducationHomePageState extends State<EducationHomePage> {
  List<dynamic> _universities = [];
  List<dynamic> _recommendations = [];
  List<dynamic> _tags = [];
  bool _isLoading = true;
  final String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final universitiesRes = await http.get(
        Uri.parse(
          '${shared.AppConfig.baseWebUrl3002}/api/universities?limit=8',
        ),
      );
      final recommendationsRes = await http.get(
        Uri.parse(
          '${shared.AppConfig.baseWebUrl3002}/api/programs/recommendations',
        ),
      );
      final tagsRes = await http.get(
        Uri.parse('${shared.AppConfig.baseWebUrl3002}/api/tags'),
      );

      if (universitiesRes.statusCode == 200) {
        final data = json.decode(universitiesRes.body);
        setState(() {
          _universities = data['data']['list'] ?? [];
        });
      }

      if (recommendationsRes.statusCode == 200) {
        final data = json.decode(recommendationsRes.body);
        setState(() {
          _recommendations = data['data'] ?? [];
        });
      }

      if (tagsRes.statusCode == 200) {
        final data = json.decode(tagsRes.body);
        setState(() {
          _tags = data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('加载数据失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToDetail(dynamic university) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UniversityDetailPage(university: university),
      ),
    );
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UniversitySearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            title: Text(
              '🏫 挪威大学',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            elevation: 0,
          ),

          // 搜索栏
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: GestureDetector(
                onTap: _navigateToSearch,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12.w),
                    border: Border.all(
                      color:
                          isDark ? const Color(0xFF334155) : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: const Color(0xFF4F46E5)),
                      SizedBox(width: 12.w),
                      Text(
                        '搜索大学名称、城市...',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 热门标签
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔥 热门标签',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children:
                        _tags.map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(
                                  tag['color'].replaceFirst('#', '0xFF'),
                                ),
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Color(
                                  int.parse(
                                    tag['color'].replaceFirst('#', '0xFF'),
                                  ),
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tag['icon'] ?? '🏷️',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  tag['name_cn'],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Color(
                                      int.parse(
                                        tag['color'].replaceFirst('#', '0xFF'),
                                      ),
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // 院校推荐标题
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🏛️ 院校推荐',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      '全部 >',
                      style: TextStyle(
                        color: const Color(0xFF4F46E5),
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 大学卡片 - 两列网格
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (index >= _universities.length) {
                  return const SizedBox.shrink();
                }
                final uni = _universities[index];
                return _buildUniversityCard(uni, isDark);
              }, childCount: _isLoading ? 4 : _universities.length),
            ),
          ),

          // 项目推荐标题
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📌 项目推荐',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      '全部 >',
                      style: TextStyle(
                        color: const Color(0xFF4F46E5),
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 项目推荐列表
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index >= _recommendations.length) {
                  return const SizedBox.shrink();
                }
                final rec = _recommendations[index];
                return _buildRecommendationCard(rec, isDark);
              }, childCount: _recommendations.length),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
        ],
      ),
    );
  }

  Widget _buildUniversityCard(dynamic uni, bool isDark) {
    final tags =
        uni['tags'] is List ? (uni['tags'] as List).cast<String>() : [];

    return GestureDetector(
      onTap: () => _navigateToDetail(uni),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            Container(
              height: 100.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                color: isDark ? Colors.grey[800] : Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Image.network(
                  uni['banner_image'] ??
                      'https://picsum.photos/seed/${uni['id']}/400/200',
                  width: double.infinity,
                  height: 100.h,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: const Color(0xFF4F46E5).withOpacity(0.3),
                        child: Center(
                          child: Icon(
                            Icons.school,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                ),
              ),
            ),
            // 内容
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    uni['name_cn'] ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '🏙️ ${uni['city'] ?? ''}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  // 标签
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 4.h,
                      children:
                          tags.take(2).map((tag) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: const Color(0xFF4F46E5),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(dynamic rec, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // 项目类型标签
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                rec['type'] ?? '1+2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec['program_name'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '🏛️ ${rec['university_name'] ?? ''}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '入学时间：${rec['start_date'] ?? ''}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        rec['annual_cost_cn'] != null
                            ? '¥${(rec['annual_cost_cn'] as num).toStringAsFixed(2)}万/年'
                            : '',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFFD97706),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 大学详情页 ====================
class UniversityDetailPage extends StatelessWidget {
  final dynamic university;

  const UniversityDetailPage({super.key, required this.university});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        title: Text(
          university['name_cn'] ?? '',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                university['banner_image'] ??
                    'https://picsum.photos/seed/${university['id']}/800/300',
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      height: 200.h,
                      color: const Color(0xFF4F46E5).withOpacity(0.3),
                      child: const Center(
                        child: Icon(
                          Icons.school,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
              ),
            ),
            SizedBox(height: 16.h),
            // 基本信息
            Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      university['logo'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Icon(
                            Icons.school,
                            size: 30,
                            color: const Color(0xFF4F46E5),
                          ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        university['name_cn'] ?? '',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        university['name_en'] ?? '',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14.sp,
                            color: const Color(0xFF4F46E5),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            university['city'] ?? '',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // 统计数据
            Row(
              children: [
                _buildStatItem(
                  '🏆',
                  '世界排名',
                  '${university['rank_world'] ?? 'N/A'}',
                  isDark,
                ),
                _buildStatItem(
                  '🎓',
                  '建校年份',
                  '${university['established_year'] ?? ''}',
                  isDark,
                ),
                _buildStatItem(
                  '📚',
                  '专业数',
                  '${university['program_count'] ?? 0}',
                  isDark,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // 简介
            if (university['description'] != null)
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📖 学校简介',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      university['description'] ?? '',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color:
                            isDark ? Colors.grey[300] : const Color(0xFF4B5563),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 20.sp)),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 搜索页面 ====================
class UniversitySearchPage extends StatefulWidget {
  const UniversitySearchPage({super.key});

  @override
  State<UniversitySearchPage> createState() => _UniversitySearchPageState();
}

class _UniversitySearchPageState extends State<UniversitySearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _isSearching = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await http.get(
        Uri.parse(
          '${shared.AppConfig.baseWebUrl3002}/api/search/universities?q=$query',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _results = data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('搜索失败: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        title: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 12.w),
              Icon(Icons.search, color: const Color(0xFF4F46E5)),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '搜索大学...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  onChanged: _search,
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _controller.clear();
                    setState(() => _results = []);
                  },
                  icon: Icon(Icons.clear, size: 18.sp),
                ),
            ],
          ),
        ),
      ),
      body:
          _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty && _controller.text.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 16.h),
                    Text(
                      '未找到相关大学',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final uni = _results[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              uni['logo'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Icon(
                                    Icons.school,
                                    color: const Color(0xFF4F46E5),
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                uni['name_cn'] ?? '',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                '🏙️ ${uni['city'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14.sp,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
