import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';

class Place {
  final String name;
  final String location;
  final String description;
  final String phone;
  final int rating;
  final String imageUrl;
  final String website;
  final String highlights;
  final String address;

  const Place({
    required this.name,
    required this.location,
    required this.description,
    required this.phone,
    required this.rating,
    required this.imageUrl,
    required this.website,
    required this.highlights,
    required this.address,
  });
}

class PlaceDetailPage extends StatelessWidget {
  final Place place;

  const PlaceDetailPage({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          place.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white.withOpacity(0.86),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.withOpacity(0.08),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.w),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 10,
                            child: CachedNetworkImage(
                              imageUrl: place.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: Colors.black.withOpacity(0.05),
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image_rounded, size: 40),
                              ),
                              placeholder: (context, url) => Container(
                                color: Colors.black.withOpacity(0.04),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12.w,
                            bottom: 12.h,
                            right: 12.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.86),
                                borderRadius: BorderRadius.circular(18.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 18,
                                    offset: Offset(0, 8.h),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFF111827), size: 18),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Rating: ${place.rating}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.public_rounded, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: _SectionTitle(text: 'Overview'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: 'Name',
                            value: place.name,
                            icon: Icons.label_important_outline_rounded,
                          ),
                          Divider(height: 18.h),
                          _InfoRow(
                            label: 'Location',
                            value: place.location,
                            icon: Icons.place_rounded,
                          ),
                          Divider(height: 18.h),
                          _InfoRow(
                            label: 'Description',
                            value: place.description,
                            icon: Icons.description_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    child: _SectionTitle(text: 'Contact & Link'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: 'Phone',
                            value: place.phone,
                            icon: Icons.phone_rounded,
                          ),
                          Divider(height: 18.h),
                          _InfoRow(
                            label: 'Website',
                            value: place.website,
                            icon: Icons.link_rounded,
                          ),
                          Divider(height: 18.h),
                          _InfoRow(
                            label: 'Highlights',
                            value: place.highlights,
                            icon: Icons.local_fire_department_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _LocationMap(
                    address: place.address,
                    title: place.name,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 24.h),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF0F172A),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22.w),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 2.h),
          width: 34.w,
          height: 34.h,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14.w),
          ),
          child: Icon(icon, size: 18.r, color: const Color(0xFF0F172A)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationMap extends StatefulWidget {
  final String address;
  final String title;

  const _LocationMap({
    required this.address,
    required this.title,
  });

  @override
  State<_LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<_LocationMap> {
  LatLng? _position;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _geocodeAddress();
  }

  Future<void> _geocodeAddress() async {
    setState(() {
      _position = const LatLng(59.9139, 10.7522);
      _isLoading = false;
    });
  }

  Future<void> _openExternalMap() async {
    final availableMaps = await MapLauncher.installedMaps;
    
    if (availableMaps.isNotEmpty) {
      await MapLauncher.showMarker(
        mapType: MapType.google,
        coords: Coords(
          _position?.latitude ?? 59.9139,
          _position?.longitude ?? 10.7522,
        ),
        title: widget.address,
      );
    } else {
      // Fallback to url_launcher if no maps are available
      final url = 'geo:${_position?.latitude ?? 59.9139},${_position?.longitude ?? 10.7522}?q=${Uri.encodeComponent(widget.address)}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Color(0xFF8B5CF6)),
                SizedBox(width: 10.w),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E2D),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _openExternalMap,
                  child: Text(
                    'Open in Maps',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              widget.address,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF65748B),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(
            height: 200.h,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: _position ?? const LatLng(59.9139, 10.7522),
                          initialZoom: 14,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                            userAgentPackageName: 'tourism_in_norway/1.0.0',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _position ?? const LatLng(59.9139, 10.7522),
                                width: 30.w,
                                height: 30.w,
                                child: _CallunaMarker(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _openExternalMap,
                          behavior: HitTestBehavior.opaque,
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

class _CallunaMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B5DE5), Color(0xFFF15BB5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 178, 120, 248).withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.location_on_outlined,
          color: Colors.white,
          size: 12.r,
        ),
      ),
    );
  }
}