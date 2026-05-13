// import 'package:flutter/material.dart';

// import 'app_shared.dart' as shared;
// import 'place_detail.dart';

// class HomePage extends StatelessWidget {
//   final shared.AppScale scale;
//   final shared.AppLocalizations loc;

//   const HomePage({super.key, required this.scale, required this.loc});

//   static const Color _ink = Color(0xFF0F172A);
//   static const Color _muted = Color(0xFF64748B);
//   static const Color _cardBorder = Color(0x1F111827);

//   // Your provided dataset (name, location, description, phone, rating, imageUrl, website, highlights)
//   static const List<Place> places = [
//     Place(
//       name: 'Geirangerfjord',
//       location: 'Geiranger, Møre og Romsdal, Norway',
//       description: 'UNESCO World Heritage fjord known for its dramatic scenery and waterfalls.',
//       phone: '+47 70 20 20 20',
//       rating: 5,
//       imageUrl: 'http://www.pavogroup.top/tourism/norway/img/geiranger.jpg',
//       website: 'https://www.geirangerfjord.no',
//       highlights: 'Best visited May-September.',
//     ),
//     Place(
//       name: 'Trolltunga',
//       location: 'Odda, Vestland, Norway',
//       description: 'A spectacular rock formation jutting horizontally out of the mountain.',
//       phone: '+47 53 60 60 60',
//       rating: 5,
//       imageUrl: 'http://www.pavogroup.top/tourism/norway/img/trolltunga.jpg',
//       website: 'https://www.trolltunga.com',
//       highlights: 'Difficult hike, 10-12 hours.',
//     ),
//     Place(
//       name: 'Lofoten Islands',
//       location: 'Lofoten, Nordland, Norway',
//       description: 'Archipelago famous for dramatic mountains, peaks, and open sea.',
//       phone: '+47 76 00 00 00',
//       rating: 5,
//       imageUrl: 'http://www.pavogroup.top/tourism/norway/img/lofoten.jpg',
//       website: 'https://www.lofoten.info',
//       highlights: 'Great for Northern Lights.',
//     ),
//   ];

//   String _shortDesc(String description) {
//     const maxLen = 20;
//     if (description.length <= maxLen) return description;
//     return '${description.substring(0, maxLen)}…';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final scale = this.scale;

//     // “瀑布式两列错位”：使用两条 ListView（左/右列）分别滚动同一个父滚动区域。
//     // 通过给卡片添加不同的 top padding + 不同的图片高宽比，让视觉上呈现瀑布错位。
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: scale.horizontal(24)),
//       child: CustomScrollView(
//         slivers: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.only(top: scale.vertical(6), bottom: scale.vertical(18)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     loc.homeTitle,
//                     style: TextStyle(
//                       fontSize: scale.fontSize(34),
//                       fontWeight: FontWeight.bold,
//                       color: _ink,
//                       height: 1.05,
//                     ),
//                   ),
//                   SizedBox(height: scale.vertical(8)),
//                   Text(
//                     loc.homeSubtitle,
//                     style: TextStyle(
//                       fontSize: scale.fontSize(16),
//                       color: _muted,
//                       height: 1.35,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           SliverPadding(
//             padding: EdgeInsets.only(bottom: scale.vertical(24)),
//             sliver: SliverToBoxAdapter(
//               child: _StaggeredTwoColumnGrid(
//                 scale: scale,
//                 items: places,
//                 shortDesc: _shortDesc,
//                 onTap: (place) {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (_) => PlaceDetailPage(scale: scale, place: place),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StaggeredTwoColumnGrid extends StatelessWidget {
//   final shared.AppScale scale;
//   final List<Place> items;
//   final String Function(String) shortDesc;
//   final ValueChanged<Place> onTap;

//   const _StaggeredTwoColumnGrid({
//     required this.scale,
//     required this.items,
//     required this.shortDesc,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final left = <Place>[];
//     final right = <Place>[];

//     for (var i = 0; i < items.length; i++) {
//       (i.isEven ? left : right).add(items[i]);
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final gap = scale.horizontal(14);
//         final colWidth = (constraints.maxWidth - gap) / 2;

//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: colWidth,
//               child: _Column(
//                 scale: scale,
//                 items: left,
//                 shortDesc: shortDesc,
//                 onTap: onTap,
//                 columnIndex: 0,
//               ),
//             ),
//             SizedBox(width: gap),
//             SizedBox(
//               width: colWidth,
//               child: _Column(
//                 scale: scale,
//                 items: right,
//                 shortDesc: shortDesc,
//                 onTap: onTap,
//                 columnIndex: 1,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class _Column extends StatelessWidget {
//   final shared.AppScale scale;
//   final List<Place> items;
//   final String Function(String) shortDesc;
//   final ValueChanged<Place> onTap;
//   final int columnIndex;

//   const _Column({
//     required this.scale,
//     required this.items,
//     required this.shortDesc,
//     required this.onTap,
//     required this.columnIndex,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         for (var i = 0; i < items.length; i++)
//           Padding(
//             // “错位”：不同 index 顶部留白不同
//             padding: EdgeInsets.only(top: scale.vertical((i.isEven ? 18 : 34) + (columnIndex == 0 ? 6 : 0))),
//             child: _PlaceCard(
//               scale: scale,
//               place: items[i],
//               shortDesc: shortDesc,
//               onTap: () => onTap(items[i]),
//               // “瀑布”：不同卡片图高度不同（通过 aspectRatio 变化）
//               imageAspectRatio: (i + columnIndex).isEven ? 4 / 3 : 16 / 11,
//             ),
//           ),
//       ],
//     );
//   }
// }

// class _PlaceCard extends StatelessWidget {
//   final shared.AppScale scale;
//   final Place place;
//   final String Function(String) shortDesc;
//   final VoidCallback onTap;
//   final double imageAspectRatio;

//   const _PlaceCard({
//     required this.scale,
//     required this.place,
//     required this.shortDesc,
//     required this.onTap,
//     required this.imageAspectRatio,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final border = Color(0x1F111827);

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: EdgeInsets.only(bottom: scale.vertical(16)),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.92),
//           borderRadius: BorderRadius.circular(scale.horizontal(22)),
//           border: Border.all(color: border, width: 1),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               blurRadius: 18,
//               offset: Offset(0, scale.vertical(10)),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 图片
//             AspectRatio(
//               aspectRatio: imageAspectRatio,
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: Image.network(
//                       place.imageUrl,
