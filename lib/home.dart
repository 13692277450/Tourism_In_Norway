import 'dart:convert';
//import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import 'app_shared.dart' as shared;
import 'service_place_detail.dart';
import 'service_theme.dart' as theme;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Place> places = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool isLoading = true;
  String? errorMessage;
  String? _selectedScenicTag;

  // 是否已记录访问
  bool _hasRecordedVisit = false;

  // 景点名称对应的彩色图标/emoji映射
  final Map<String, String> _placeIcons = {
    '卑尔根': '🏔️',
    '奥斯陆': '🏛️',
    '特罗姆瑟': '🌌',
    '罗弗敦': '🏝️',
    '盖朗厄尔': '🏞️',
    '斯塔万格': '⚓',
    '特隆赫姆': '⛪',
    '奥勒松': '🏘️',
    '弗洛姆': '🚂',
    '松恩峡湾': '🌊',
    '哈当厄尔': '🍒',
    '吕瑟峡湾': '⛰️',
  };

  // 随机彩色图标列表（当没有匹配时使用）
  final List<String> _randomIcons = [
    '🌟',
    '🔥',
    '💎',
    '🌈',
    '🎯',
    '⭐',
    '🌸',
    '🌺',
    '🍀',
    '🎨',
    '💫',
    '🌿',
  ];

  String _getIconForPlace(String name) {
    for (final entry in _placeIcons.entries) {
      if (name.contains(entry.key)) {
        return entry.value;
      }
    }
    final index = name.hashCode.abs() % _randomIcons.length;
    return _randomIcons[index];
  }

  List<String> get _scenicTagNames {
    final names =
        places
            .map((place) => place.name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();
    return names.take(12).toList();
  }

  List<Place> get _filteredPlaces {
    var result = places;
    if (_selectedScenicTag != null) {
      result =
          result.where((place) => place.name == _selectedScenicTag).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result =
          result
              .where(
                (place) =>
                    place.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    place.location.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    place.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }
    return result;
  }

  void _searchPlaces() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    _searchController.clear();
  }

  @override
  void initState() {
    super.initState();
    fetchScenicData(isRefresh: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================== 访问计数功能 ====================
  Future<void> _recordVisit() async {
    if (_hasRecordedVisit) return;

    try {
      final now = DateTime.now();
      final formattedTime =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      final response = await http.post(
        Uri.parse('${shared.AppConfig.baseWebUrl3004}/api/visit/counter'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'connectTime': formattedTime}),
      );

      if (response.statusCode == 200) {
        _hasRecordedVisit = true;
        debugPrint('✅ 访问记录成功: $formattedTime');
      } else {
        debugPrint('❌ 访问记录失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ 访问记录异常: $e');
    }
  }

  Future<void> fetchScenicData({bool isRefresh = false}) async {
    if (_isLoadingMore && !isRefresh) return;
    if (!_hasMore && !isRefresh) return;

    if (isRefresh) {
      setState(() {
        isLoading = true;
        errorMessage = null;
        _currentPage = 1;
        _hasMore = true;
        places = [];
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final uri = Uri.parse(
        '${shared.AppConfig.baseWebUrl}:${shared.AppConfig.port3004}/api/norwaytravelscenic/',
      ).replace(
        queryParameters: {
          'page': _currentPage.toString(),
          'limit': _pageSize.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        List<dynamic> dataList = [];
        int total = 0;

        if (decoded is List) {
          dataList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          final dataMap = decoded['data'] as Map<String, dynamic>?;
          dataList = dataMap?['list'] as List<dynamic>? ?? const <dynamic>[];
          total = dataMap?['total'] as int? ?? 0;
        }

        final newPlaces =
            dataList.map((item) {
              final map =
                  item as Map<String, dynamic>? ?? const <String, dynamic>{};
              final name = map['name'] ?? '';
              final location = map['address'] ?? map['location'] ?? '';
              final description = map['description'] ?? map['desc'] ?? '';
              final phone = map['telephone'] ?? map['phone'] ?? '';
              final rating = (map['grade'] ?? map['rating'] ?? 0);
              final imageUrl =
                  map['picture']?.toString().trim() ??
                  map['img']?.toString().trim() ??
                  map['image']?.toString().trim() ??
                  map['image_url']?.toString().trim() ??
                  map['photo']?.toString().trim() ??
                  map['photos']?.toString().trim() ??
                  map['imageUrl']?.toString().trim() ??
                  '';
              final website = map['website'] ?? '';
              final highlights = map['attend'] ?? map['highlights'] ?? '';

              return Place(
                name: name,
                location: location,
                description: description,
                phone: phone,
                rating: rating,
                imageUrl: imageUrl,
                website: website,
                highlights: highlights,
                address: location,
              );
            }).toList();

        setState(() {
          if (isRefresh) {
            places = newPlaces;
          } else {
            places.addAll(newPlaces);
          }

          if (newPlaces.length < _pageSize || places.length >= total) {
            _hasMore = false;
          } else {
            _currentPage++;
          }

          isLoading = false;
          _isLoadingMore = false;

          if (places.isEmpty) {
            errorMessage = '未找到景点数据，请稍后重试。';
          }
        });

        // 数据加载完成后记录访问（只记录一次）
        if (!_hasRecordedVisit && places.isNotEmpty) {
          _recordVisit();
        }
      } else {
        setState(() {
          isLoading = false;
          _isLoadingMore = false;
          errorMessage = '服务器返回状态码 ${response.statusCode}。';
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() {
        isLoading = false;
        _isLoadingMore = false;
        if (places.isEmpty) {
          errorMessage = '网络错误，请检查连接。';
        }
      });
    }
  }

  String _shortDesc(String description) {
    const maxLen = 50;
    if (description.length <= maxLen) return description;
    return '${description.substring(0, maxLen)}…';
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: EdgeInsets.fromLTRB(13.w, 16.h, 13.w, 4.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark
                        ? theme.ServiceMetalColors.darkSurface
                        : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border:
                    isDark
                        ? Border.all(
                          color: theme.ServiceMetalColors.primary.withOpacity(
                            0.3,
                          ),
                        )
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        filled: isDark,
                        fillColor:
                            isDark
                                ? theme.ServiceMetalColors.darkSurface
                                : Colors.white,
                        hintStyle: TextStyle(
                          color:
                              isDark
                                  ? theme.ServiceMetalColors.darkTextSecondary
                                  : Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                      ),
                      style: TextStyle(
                        color:
                            isDark
                                ? theme.ServiceMetalColors.darkText
                                : Colors.black87,
                        fontSize: 14.sp,
                      ),
                      onSubmitted: (_) => _searchPlaces(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _searchPlaces,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Icon(
                        Icons.search,
                        color: theme.ServiceMetalColors.primary,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // 挪威国旗 - 修复显示问题
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7.r),
              child: Image.asset(
                'assets/images/norwayflag.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // 使用 SVG 格式或绘制手动国旗
                  return _buildNorwayFlagPlaceholder(isDark);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 手动绘制挪威国旗作为备用
  Widget _buildNorwayFlagPlaceholder(bool isDark) {
    return Container(
      color: const Color(0xFFEF2B2D), // 红色底色
      child: Stack(
        children: [
          // 白色十字（水平）
          Align(
            alignment: Alignment.center,
            child: Container(height: 10.h, color: Colors.white),
          ),
          // 白色十字（垂直）
          Align(
            alignment: Alignment.center,
            child: Container(width: 10.w, color: Colors.white),
          ),
          // 蓝色十字（水平，在白色十字内部）
          Align(
            alignment: Alignment.center,
            child: Container(height: 6.h, color: const Color(0xFF002868)),
          ),
          // 蓝色十字（垂直，在白色十字内部）
          Align(
            alignment: Alignment.center,
            child: Container(width: 6.w, color: const Color(0xFF002868)),
          ),
          // 左上角蓝色方块
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 14.w,
              height: 10.h,
              color: const Color(0xFF002868),
            ),
          ),
          // 左上角白色十字
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 14.w,
              height: 10.h,
              child: Stack(
                children: [
                  // 白色十字（水平）
                  Align(
                    alignment: Alignment.center,
                    child: Container(height: 2.h, color: Colors.white),
                  ),
                  // 白色十字（垂直）
                  Align(
                    alignment: Alignment.center,
                    child: Container(width: 2.w, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenicTagArea(bool isDark) {
    final tags = _scenicTagNames;
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final half = (tags.length / 2).ceil();
    final firstRow = tags.take(half).toList();
    final secondRow = tags.length > half ? tags.sublist(half) : <String>[];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(13.w, 8.h, 13.w, 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        border:
            isDark
                ? Border.all(
                  color: theme.ServiceMetalColors.primary.withOpacity(0.3),
                )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    '热门景点',
                    style: TextStyle(
                      color:
                          isDark
                              ? theme.ServiceMetalColors.darkText
                              : theme.ServiceMetalColors.lightText,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (_selectedScenicTag != null || _searchQuery.isNotEmpty)
                GestureDetector(
                  onTap:
                      () => setState(() {
                        _selectedScenicTag = null;
                        _searchQuery = '';
                      }),
                  child: Text(
                    '清除',
                    style: TextStyle(
                      color: theme.ServiceMetalColors.primary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTagRow(firstRow, isDark),
                if (secondRow.isNotEmpty) SizedBox(height: 10.h),
                if (secondRow.isNotEmpty) _buildTagRow(secondRow, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagRow(List<String> tags, bool isDark) {
    return Row(
      children:
          tags.map((tag) {
            final selected = tag == _selectedScenicTag;
            final icon = _getIconForPlace(tag);
            return Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedScenicTag = selected ? null : tag;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 104.w,
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        selected
                            ? const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : isDark
                            ? const LinearGradient(
                              colors: [Color(0xFF374151), Color(0xFF1F2937)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : const LinearGradient(
                              colors: [Color(0xFFF0F4FF), Color(0xFFE8EDF5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                    borderRadius: BorderRadius.circular(13.w),
                    border: Border.all(
                      color:
                          selected
                              ? Colors.transparent
                              : isDark
                              ? theme.ServiceMetalColors.primary.withOpacity(
                                0.3,
                              )
                              : const Color(0xFFD1D9E6),
                      width: 1,
                    ),
                    boxShadow:
                        selected
                            ? [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.2 : 0.06,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(icon, style: TextStyle(fontSize: 14.sp)),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            tag,
                            style: TextStyle(
                              color:
                                  selected
                                      ? Colors.white
                                      : isDark
                                      ? theme.ServiceMetalColors.darkText
                                      : const Color(0xFF2D3748),
                              fontSize: 12.sp,
                              fontWeight:
                                  selected ? FontWeight.bold : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = shared.AppLocalizations.of(context);
    final filteredPlaces = _filteredPlaces;

    return Scaffold(
      backgroundColor:
          isDark
              ? theme.ServiceMetalColors.darkBg
              : theme.ServiceMetalColors.lightBg,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification &&
              scrollNotification.metrics.extentAfter == 0) {
            if (!_isLoadingMore && _hasMore && !isLoading) {
              fetchScenicData(isRefresh: false);
            }
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            if (isLoading && places.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: CircularProgressIndicator(
                      color: theme.ServiceMetalColors.primary,
                    ),
                  ),
                ),
              )
            else if (errorMessage != null && places.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(child: _buildSearchBar(isDark)),
              SliverToBoxAdapter(child: _buildScenicTagArea(isDark)),
              if (filteredPlaces.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        _selectedScenicTag == null && _searchQuery.isEmpty
                            ? '暂无景点数据，请稍后重试。'
                            : '暂无匹配的景点。',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  sliver: SliverToBoxAdapter(
                    child: _StaggeredTwoColumnGrid(
                      items: filteredPlaces,
                      shortDesc: _shortDesc,
                      onTap: (place) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlaceDetailPage(place: place),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              if (_isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.ServiceMetalColors.primary,
                        ),
                      ),
                    ),
                  ),
                )
              else if (!_hasMore && places.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: Text(
                        '—— 没有更多景点了 ——',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.grey[500] : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StaggeredTwoColumnGrid extends StatelessWidget {
  final List<Place> items;
  final String Function(String) shortDesc;
  final ValueChanged<Place> onTap;

  const _StaggeredTwoColumnGrid({
    required this.items,
    required this.shortDesc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leftColumn = <Place>[];
    final rightColumn = <Place>[];

    for (int i = 0; i < items.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(items[i]);
      } else {
        rightColumn.add(items[i]);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 13.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < leftColumn.length; i++)
                  _StaggeredCard(
                    place: leftColumn[i],
                    shortDesc: shortDesc(leftColumn[i].description),
                    onTap: () => onTap(leftColumn[i]),
                    marginTop: i == 0 ? 0 : 16.h,
                  ),
              ],
            ),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < rightColumn.length; i++)
                  _StaggeredCard(
                    place: rightColumn[i],
                    shortDesc: shortDesc(rightColumn[i].description),
                    onTap: () => onTap(rightColumn[i]),
                    marginTop: i == 0 ? 0 : 16.h,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredCard extends StatelessWidget {
  final Place place;
  final String shortDesc;
  final VoidCallback onTap;
  final double marginTop;

  const _StaggeredCard({
    required this.place,
    required this.shortDesc,
    required this.onTap,
    this.marginTop = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(top: marginTop),
      decoration: BoxDecoration(
        color: isDark ? theme.ServiceMetalColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border:
            isDark
                ? Border.all(
                  color: theme.ServiceMetalColors.primary.withOpacity(0.2),
                )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
                child:
                    place.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: place.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          errorWidget: (context, url, error) {
                            return Container(
                              height: 180.h,
                              color:
                                  isDark
                                      ? theme
                                          .ServiceMetalColors
                                          .darkSurfaceElevated
                                      : Colors.grey[300],
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color:
                                      isDark ? Colors.grey[600] : Colors.grey,
                                ),
                              ),
                            );
                          },
                          placeholder:
                              (context, url) => Container(
                                height: 180.h,
                                color:
                                    isDark
                                        ? theme
                                            .ServiceMetalColors
                                            .darkSurfaceElevated
                                        : Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                        )
                        : Container(
                          height: 180.h,
                          color:
                              isDark
                                  ? theme.ServiceMetalColors.darkSurfaceElevated
                                  : Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: isDark ? Colors.grey[600] : Colors.grey,
                            ),
                          ),
                        ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark
                                ? theme.ServiceMetalColors.darkText
                                : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14.sp, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          place.rating.toString(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.location_on,
                          size: 12.sp,
                          color: isDark ? Colors.grey[500] : Colors.grey,
                        ),
                        Expanded(
                          child: Text(
                            place.location,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      shortDesc,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color:
                            isDark
                                ? theme.ServiceMetalColors.darkTextSecondary
                                : Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
