import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import 'app_shared.dart' as shared;
import 'service_place_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Place> places = [];

  // 分页相关状态
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool isLoading = true; // 仅用于首次加载
  String? errorMessage;
  String? _selectedScenicTag;

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
    if (_selectedScenicTag == null) return places;
    return places.where((place) => place.name == _selectedScenicTag).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchScenicData(isRefresh: true);
  }

  /// 获取数据
  /// [isRefresh] 为 true 时表示刷新/首次加载，重置列表；为 false 时表示加载更多
  Future<void> fetchScenicData({bool isRefresh = false}) async {
    // 如果正在加载更多，且不是刷新操作，则防止重复请求
    if (_isLoadingMore && !isRefresh) return;

    // 如果没有更多数据且不是刷新操作，直接返回
    if (!_hasMore && !isRefresh) return;

    if (isRefresh) {
      setState(() {
        isLoading = true;
        errorMessage = null;
        _currentPage = 1;
        _hasMore = true;
        places = []; // 清空旧数据
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      // 构建带分页参数的 URL
      final uri = Uri.parse(
        '${shared.AppConfig.baseWebUrl}:3004/norwaytravelscenic',
      ).replace(
        queryParameters: {
          'page': _currentPage.toString(),
          'limit': _pageSize.toString(),
          // 如果后端支持语言参数，也可以在这里添加，例如: 'locale': shared.AppLocalizations.of(context).locale.languageCode,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // 解析数据逻辑
        List<dynamic> dataList = [];
        int total = 0; // 总数

        if (decoded is List) {
          dataList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          // 后端返回 { data: { list: [...], total: ... } } 结构
          final dataMap = decoded['data'] as Map<String, dynamic>?;
          dataList = dataMap?['list'] as List<dynamic>? ?? const <dynamic>[];

          // 获取总数用于准确判断是否有更多数据
          total = dataMap?['total'] as int? ?? 0;
        }

        // 解析 Place 对象
        final newPlaces =
            dataList.map((item) {
              final map =
                  item as Map<String, dynamic>? ?? const <String, dynamic>{};
              final name = map['name'] ?? '';
              final location = map['address'] ?? map['location'] ?? '';
              final description = map['description'] ?? map['desc'] ?? '';
              final phone = map['telephone'] ?? map['phone'] ?? '';
              final rating = (map['grade'] ?? map['rating'] ?? 0);
              // 尝试多种可能的图片字段名
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
                address: location, // 添加 address 参数
              );
            }).toList();

        setState(() {
          if (isRefresh) {
            places = newPlaces;
          } else {
            places.addAll(newPlaces);
          }

          // 判断是否还有更多数据
          // 使用后端返回的total进行准确判断
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

  Widget _buildScenicTagArea() {
    final tags = _scenicTagNames;
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final firstRow = tags.take(4).toList();
    final secondRow = tags.length > 4 ? tags.sublist(4) : <String>[];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(24.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '热门景点',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedScenicTag != null)
                GestureDetector(
                  onTap: () => setState(() => _selectedScenicTag = null),
                  child: Text(
                    '清除',
                    style: TextStyle(
                      color: Colors.blue[200],
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildTagRow(firstRow),
          if (secondRow.isNotEmpty) ...[
            SizedBox(height: 10.h),
            _buildTagRow(secondRow),
          ],
        ],
      ),
    );
  }

  Widget _buildTagRow(List<String> tags) {
    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final tag = tags[index];
          final selected = tag == _selectedScenicTag;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedScenicTag = selected ? null : tag;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient:
                    selected
                        ? const LinearGradient(
                          colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
                        )
                        : const LinearGradient(
                          colors: [Color(0xFF334155), Color(0xFF1E293B)],
                        ),
                borderRadius: BorderRadius.circular(999.w),
                border: Border.all(
                  color:
                      selected
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.14),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        selected
                            ? const Color(0xFF36D1DC).withOpacity(0.25)
                            : Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  tag,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = shared.AppLocalizations.of(context);
    final filteredPlaces = _filteredPlaces;

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          // 监听滚动到底部
          // ScrollEndNotification 比 ScrollUpdateNotification 性能更好，只在停止滚动时触发
          if (scrollNotification is ScrollEndNotification &&
              scrollNotification.metrics.extentAfter == 0) {
            // 触底且还有更多数据，且不在加载中
            if (!_isLoadingMore && _hasMore && !isLoading) {
              fetchScenicData(isRefresh: false);
            }
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            // SliverAppBar(
            //   title: Text(loc.appName),
            //   pinned: true,
            //   backgroundColor: const Color(0xFF0F172A),
            //   foregroundColor: Colors.white,
            //   expandedHeight: 200.h,
            //   flexibleSpace: const FlexibleSpaceBar(
            //     background: DecoratedBox(
            //       decoration: BoxDecoration(
            //         gradient: LinearGradient(
            //           begin: Alignment.topCenter,
            //           end: Alignment.bottomCenter,
            //           colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

            // 首次加载状态
            if (isLoading && places.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.w),
                    child: const CircularProgressIndicator(),
                  ),
                ),
              )
            // 错误状态
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
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              )
            // 正常列表内容
            else ...[
              SliverToBoxAdapter(child: _buildScenicTagArea()),
              if (filteredPlaces.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        _selectedScenicTag == null
                            ? '暂无景点数据，请稍后重试。'
                            : '暂无匹配 "$_selectedScenicTag" 的景点。',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[300],
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

              // 底部加载状态指示器
              if (_isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                )
              // 没有更多数据提示
              else if (!_hasMore && places.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: Text(
                        '—— 没有更多景点了 ——',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
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
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < rightColumn.length; i++)
                  _StaggeredCard(
                    place: rightColumn[i],
                    shortDesc: shortDesc(rightColumn[i].description),
                    onTap: () => onTap(rightColumn[i]),
                    marginTop: i == 0 ? 0 : 16.h, // 40.h : 16.h,
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
    return Container(
      margin: EdgeInsets.only(top: marginTop),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
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
              // 图片部分：宽度固定，高度自适应
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.w)),
                child:
                    place.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: place.imageUrl,
                          width: double.infinity, // 宽度填满列宽
                          fit: BoxFit.fitWidth, // 关键：保持宽高比，高度自动调整
                          errorWidget: (context, url, error) {
                            return Container(
                              height: 180.h, // 错误时给一个默认高度
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                          placeholder:
                              (context, url) => Container(
                                height: 180.h, // 加载时给一个占位高度，避免布局跳动太大
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                        )
                        : Container(
                          height: 180.h,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
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
                        color: Colors.black87,
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
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.location_on,
                          size: 12.sp,
                          color: Colors.grey,
                        ),
                        Expanded(
                          child: Text(
                            place.location,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
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
                        color: Colors.grey[700],
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
