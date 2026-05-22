// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';



// class ServicePage extends StatelessWidget {
//   const ServicePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final baseTextTheme = GoogleFonts.spaceMonoTextTheme(ThemeData.dark().textTheme);

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         useMaterial3: true,
//         textTheme: baseTextTheme,
//         colorScheme: const ColorScheme.dark(
//           primary: _Neon.cyan,
//           secondary: _Neon.magenta,
//           surface: _Neon.surface,
//         ),
//       ),
//       home: const NeonProductPage(),
//     );
//   }
// }

// class NeonProductPage extends StatefulWidget {
//   const NeonProductPage({super.key});

//   @override
//   State<NeonProductPage> createState() => _NeonProductPageState();
// }

// class _NeonProductPageState extends State<NeonProductPage> {
//   final _pageCtrl = PageController(viewportFraction: 0.92);
//   final _scrollCtrl = ScrollController();

//   int _sizeIndex = 2;
//   int _colorIndex = 1;

//   final List<String> _sizes = const ['XS', 'S', 'M', 'L', 'XL'];
//   final List<Color> _colors = const [
//     _Neon.cyan,
//     _Neon.magenta,
//     _Neon.lime,
//     _Neon.amber,
//   ];

//   @override
//   void dispose() {
//     _pageCtrl.dispose();
//     _scrollCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final top = MediaQuery.paddingOf(context).top;
//     final text = Theme.of(context).textTheme;

//     return Scaffold(
//       backgroundColor: _Neon.bg,
//       body: Stack(
//         children: [
//           const _AnimatedNeonBackdrop(),
//           Positioned.fill(
//             child: CustomPaint(
//               painter: _GridPainter(),
//             ),
//           ),
//           // 主内容
//           CustomScrollView(
//             controller: _scrollCtrl,
//             physics: const BouncingScrollPhysics(),
//             slivers: [
//               SliverToBoxAdapter(
//                 child: SizedBox(height: top + 12),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 18),
//                   child: _TopBar(
//                     onBack: () => Navigator.maybePop(context),
//                     onShare: () {},
//                     onFav: () {},
//                   ),
//                 ),
//               ),
//               const SliverToBoxAdapter(child: SizedBox(height: 14)),
//               SliverToBoxAdapter(
//                 child: SizedBox(
//                   height: 340,
//                   child: PageView(
//                     controller: _pageCtrl,
//                     children: const [
//                       _ProductHeroCard(
//                         imageUrl:
//                             'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1400&q=80',
//                         label: 'NEON DROP',
//                       ),
//                       _ProductHeroCard(
//                         imageUrl:
//                             'https://images.unsplash.com/photo-1511385348-a52b4a160dc2?auto=format&fit=crop&w=1400&q=80',
//                         label: 'MIDNIGHT',
//                       ),
//                       _ProductHeroCard(
//                         imageUrl:
//                             'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=1400&q=80',
//                         label: 'PHOTON',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SliverToBoxAdapter(child: SizedBox(height: 14)),
//               SliverPadding(
//                 padding: const EdgeInsets.symmetric(horizontal: 18),
//                 sliver: SliverToBoxAdapter(
//                   child: _GlowPanel(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'AURORA // WATCH',
//                                       style: text.titleLarge?.copyWith(
//                                         fontWeight: FontWeight.w800,
//                                         letterSpacing: 0.8,
//                                         height: 1.05,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 6),
//                                     Text(
//                                       '碳纤维表圈 · 霓虹流光表盘 · 50m 防水',
//                                       style: text.bodyMedium?.copyWith(
//                                         color: Colors.white.withOpacity(0.75),
//                                         height: 1.35,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               _PricePill(price: '¥1,699'),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           const _NeonDivider(),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: [
//                               const _RatingBadge(rating: 4.8, reviews: 1293),
//                               const SizedBox(width: 10),
//                               _SpecChip(icon: Icons.bolt_rounded, text: '24h 发光'),
//                               const SizedBox(width: 8),
//                               _SpecChip(icon: Icons.local_shipping_rounded, text: '当日发货'),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             '选择规格',
//                             style: text.labelLarge?.copyWith(
//                               fontWeight: FontWeight.w700,
//                               letterSpacing: 0.6,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           _SizeRow(
//                             sizes: _sizes,
//                             selectedIndex: _sizeIndex,
//                             onChanged: (i) => setState(() => _sizeIndex = i),
//                           ),
//                           const SizedBox(height: 14),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   '配色',
//                                   style: text.labelLarge?.copyWith(
//                                     fontWeight: FontWeight.w700,
//                                     letterSpacing: 0.6,
//                                   ),
//                                 ),
//                               ),
//                               Text(
//                                 '库存充足',
//                                 style: text.labelMedium?.copyWith(
//                                   color: _Neon.lime.withOpacity(0.9),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           _ColorRow(
//                             colors: _colors,
//                             selectedIndex: _colorIndex,
//                             onChanged: (i) => setState(() => _colorIndex = i),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             '产品描述',
//                             style: text.labelLarge?.copyWith(
//                               fontWeight: FontWeight.w700,
//                               letterSpacing: 0.6,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             '在暗处，指针像电流一样划过表盘；在光下，金属纹理像城市霓虹的倒影。我们把“赛博”做得克制——让它更像一件长期佩戴的日用品。',
//                             style: text.bodyMedium?.copyWith(
//                               color: Colors.white.withOpacity(0.78),
//                               height: 1.45,
//                             ),
//                           ),
//                           const SizedBox(height: 14),
//                           Wrap(
//                             spacing: 10,
//                             runSpacing: 10,
//                             children: const [
//                               _InfoBadge(title: '材质', value: '碳纤维 + 316L'),
//                               _InfoBadge(title: '重量', value: '62g'),
//                               _InfoBadge(title: '表径', value: '41mm'),
//                               _InfoBadge(title: '保修', value: '2 年'),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SliverToBoxAdapter(child: SizedBox(height: 100)),
//             ],
//           ),
//           // 底部操作区
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: SafeArea(
//               top: false,
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
//                 child: Row(
//                   children: [
//                     _ActionIcon(
//                       icon: Icons.chat_bubble_outline_rounded,
//                       onTap: () {},
//                       tooltip: '咨询',
//                     ),
//                     const SizedBox(width: 10),
//                     _ActionIcon(
//                       icon: Icons.shopping_bag_outlined,
//                       onTap: () {},
//                       tooltip: '购物袋',
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _NeonButton(
//                         label: '加入购物车',
//                         onTap: () async {
//                           HapticFeedback.mediumImpact();
//                           if (!mounted) return;
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               backgroundColor: _Neon.surface,
//                               content: Text(
//                                 '已加入：${_sizes[_sizeIndex]} / 色彩 #${_colorIndex + 1}',
//                                 style: GoogleFonts.spaceMono(),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TopBar extends StatelessWidget {
//   const _TopBar({
//     required this.onBack,
//     required this.onShare,
//     required this.onFav,
//   });

//   final VoidCallback onBack;
//   final VoidCallback onShare;
//   final VoidCallback onFav;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         _RoundNeonIcon(
//           icon: Icons.arrow_back_rounded,
//           onTap: onBack,
//         ),
//         const Spacer(),
//         _RoundNeonIcon(
//           icon: Icons.ios_share_rounded,
//           onTap: onShare,
//         ),
//         const SizedBox(width: 10),
//         _RoundNeonIcon(
//           icon: Icons.favorite_border_rounded,
//           onTap: onFav,
//         ),
//       ],
//     );
//   }
// }

// class _ProductHeroCard extends StatelessWidget {
//   const _ProductHeroCard({
//     required this.imageUrl,
//     required this.label,
//   });

//   final String imageUrl;
//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(22),
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: DecoratedBox(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       Color(0xFF101321),
//                       Color(0xFF05060B),
//                     ],
//                   ),
//                 ),
//                 child: Image.network(
//                   imageUrl,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => const SizedBox(),
//                 ),
//               ),
//             ),
//             Positioned.fill(
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.05),
//                       Colors.black.withOpacity(0.65),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 14,
//               right: 14,
//               bottom: 14,
//               child: Row(
//                 children: [
//                   _GlowTag(text: label),
//                   const Spacer(),
//                   _RoundNeonIcon(
//                     icon: Icons.fullscreen_rounded,
//                     onTap: () {},
//                     size: 44,
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: 14,
//               left: 14,
//               child: _GlowTag(
//                 text: 'LIMITED',
//                 color: _Neon.lime,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _GlowPanel extends StatelessWidget {
//   const _GlowPanel({required this.child});

//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(22),
//         color: _Neon.surface.withOpacity(0.92),
//         border: Border.all(color: Colors.white.withOpacity(0.08)),
//         boxShadow: [
//           BoxShadow(
//             color: _Neon.cyan.withOpacity(0.14),
//             blurRadius: 28,
//             spreadRadius: -10,
//             offset: const Offset(0, 10),
//           ),
//           BoxShadow(
//             color: _Neon.magenta.withOpacity(0.08),
//             blurRadius: 40,
//             spreadRadius: -16,
//             offset: const Offset(0, 20),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }

// class _PricePill extends StatelessWidget {
//   const _PricePill({required this.price});

//   final String price;

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _Neon.magenta.withOpacity(0.7), width: 1),
//         gradient: LinearGradient(
//           colors: [
//             _Neon.magenta.withOpacity(0.16),
//             _Neon.cyan.withOpacity(0.10),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: _Neon.magenta.withOpacity(0.28),
//             blurRadius: 18,
//             spreadRadius: -10,
//             offset: const Offset(0, 8),
//           )
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         child: Text(
//           price,
//           style: GoogleFonts.spaceMono(
//             fontSize: 16,
//             fontWeight: FontWeight.w800,
//             letterSpacing: 0.4,
//             shadows: [
//               Shadow(
//                 color: _Neon.magenta.withOpacity(0.55),
//                 blurRadius: 14,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _RatingBadge extends StatelessWidget {
//   const _RatingBadge({required this.rating, required this.reviews});

//   final double rating;
//   final int reviews;

//   @override
//   Widget build(BuildContext context) {
//     return _NeonOutline(
//       color: _Neon.cyan,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.star_rounded, size: 16, color: _Neon.amber),
//             const SizedBox(width: 6),
//             Text(
//               rating.toStringAsFixed(1),
//               style: GoogleFonts.spaceMono(
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: 0.2,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               '($reviews)',
//               style: GoogleFonts.spaceMono(
//                 color: Colors.white.withOpacity(0.65),
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SpecChip extends StatelessWidget {
//   const _SpecChip({required this.icon, required this.text});

//   final IconData icon;
//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.white.withOpacity(0.08)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 16, color: _Neon.lime.withOpacity(0.9)),
//             const SizedBox(width: 6),
//             Text(
//               text,
//               style: GoogleFonts.spaceMono(
//                 fontSize: 12,
//                 color: Colors.white.withOpacity(0.78),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SizeRow extends StatelessWidget {
//   const _SizeRow({
//     required this.sizes,
//     required this.selectedIndex,
//     required this.onChanged,
//   });

//   final List<String> sizes;
//   final int selectedIndex;
//   final ValueChanged<int> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 10,
//       runSpacing: 10,
//       children: [
//         for (int i = 0; i < sizes.length; i++)
//           _SizeChip(
//             label: sizes[i],
//             selected: i == selectedIndex,
//             onTap: () => onChanged(i),
//           ),
//       ],
//     );
//   }
// }

// class _SizeChip extends StatelessWidget {
//   const _SizeChip({
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });

//   final String label;
//   final bool selected;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final color = selected ? _Neon.magenta : Colors.white.withOpacity(0.10);
//     final border = selected ? _Neon.magenta : Colors.white.withOpacity(0.10);

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         curve: Curves.easeOutCubic,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(14),
//           color: color.withOpacity(selected ? 0.18 : 1),
//           border: Border.all(color: border, width: 1),
//           boxShadow: selected
//               ? [
//                   BoxShadow(
//                     color: _Neon.magenta.withOpacity(0.32),
//                     blurRadius: 18,
//                     spreadRadius: -10,
//                     offset: const Offset(0, 10),
//                   ),
//                 ]
//               : null,
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         child: Text(
//           label,
//           style: GoogleFonts.spaceMono(
//             fontWeight: FontWeight.w800,
//             letterSpacing: 0.3,
//             color: selected ? Colors.white : Colors.white.withOpacity(0.72),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ColorRow extends StatelessWidget {
//   const _ColorRow({
//     required this.colors,
//     required this.selectedIndex,
//     required this.onChanged,
//   });

//   final List<Color> colors;
//   final int selectedIndex;
//   final ValueChanged<int> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         for (int i = 0; i < colors.length; i++) ...[
//           _ColorDot(
//             color: colors[i],
//             selected: i == selectedIndex,
//             onTap: () => onChanged(i),
//           ),
//           if (i != colors.length - 1) const SizedBox(width: 10),
//         ]
//       ],
//     );
//   }
// }

// class _ColorDot extends StatelessWidget {
//   const _ColorDot({
//     required this.color,
//     required this.selected,
//     required this.onTap,
//   });

//   final Color color;
//   final bool selected;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(999),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         curve: Curves.easeOutCubic,
//         width: selected ? 44 : 36,
//         height: selected ? 44 : 36,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           gradient: RadialGradient(
//             colors: [
//               color.withOpacity(0.95),
//               color.withOpacity(0.25),
//             ],
//           ),
//           border: Border.all(
//             color: selected ? color.withOpacity(0.95) : Colors.white.withOpacity(0.12),
//             width: selected ? 1.6 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(selected ? 0.55 : 0.20),
//               blurRadius: selected ? 22 : 12,
//               spreadRadius: -10,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: selected
//             ? Icon(Icons.check_rounded, color: Colors.white.withOpacity(0.92), size: 18)
//             : null,
//       ),
//     );
//   }
// }

// class _ActionIcon extends StatelessWidget {
//   const _ActionIcon({
//     required this.icon,
//     required this.onTap,
//     required this.tooltip,
//   });

//   final IconData icon;
//   final VoidCallback onTap;
//   final String tooltip;

//   @override
//   Widget build(BuildContext context) {
//     return Tooltip(
//       message: tooltip,
//       child: _NeonOutline(
//         color: Colors.white.withOpacity(0.16),
//         child: InkWell(
//           onTap: () {
//             HapticFeedback.selectionClick();
//             onTap();
//           },
//           borderRadius: BorderRadius.circular(18),
//           child: SizedBox(
//             width: 52,
//             height: 52,
//             child: Icon(icon, color: Colors.white.withOpacity(0.85)),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NeonButton extends StatefulWidget {
//   const _NeonButton({required this.label, required this.onTap});

//   final String label;
//   final VoidCallback onTap;

//   @override
//   State<_NeonButton> createState() => _NeonButtonState();
// }

// class _NeonButtonState extends State<_NeonButton> {
//   bool _pressed = false;

//   @override
//   Widget build(BuildContext context) {
//     return Listener(
//       onPointerDown: (_) => setState(() => _pressed = true),
//       onPointerUp: (_) => setState(() => _pressed = false),
//       onPointerCancel: (_) => setState(() => _pressed = false),
//       child: InkWell(
//         onTap: widget.onTap,
//         borderRadius: BorderRadius.circular(18),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 140),
//           curve: Curves.easeOut,
//           height: 54,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(18),
//             gradient: const LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [
//                 _Neon.magenta,
//                 _Neon.cyan,
//               ],
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: _Neon.cyan.withOpacity(_pressed ? 0.18 : 0.35),
//                 blurRadius: _pressed ? 18 : 28,
//                 spreadRadius: -14,
//                 offset: const Offset(0, 16),
//               ),
//               BoxShadow(
//                 color: _Neon.magenta.withOpacity(_pressed ? 0.10 : 0.22),
//                 blurRadius: _pressed ? 16 : 24,
//                 spreadRadius: -14,
//                 offset: const Offset(0, 16),
//               ),
//             ],
//           ),
//           child: Center(
//             child: Text(
//               widget.label,
//               style: GoogleFonts.spaceMono(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w900,
//                 letterSpacing: 1.0,
//                 color: Colors.black.withOpacity(0.92),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _RoundNeonIcon extends StatelessWidget {
//   const _RoundNeonIcon({
//     required this.icon,
//     required this.onTap,
//     this.size = 48,
//   });

//   final IconData icon;
//   final VoidCallback onTap;
//   final double size;

//   @override
//   Widget build(BuildContext context) {
//     return _NeonOutline(
//       color: Colors.white.withOpacity(0.12),
//       child: InkWell(
//         onTap: () {
//           HapticFeedback.selectionClick();
//           onTap();
//         },
//         borderRadius: BorderRadius.circular(999),
//         child: SizedBox(
//           width: size,
//           height: size,
//           child: Icon(icon, color: Colors.white.withOpacity(0.9)),
//         ),
//       ),
//     );
//   }
// }

// class _GlowTag extends StatelessWidget {
//   const _GlowTag({required this.text, this.color = _Neon.cyan});

//   final String text;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(999),
//         color: _Neon.surface.withOpacity(0.72),
//         border: Border.all(color: color.withOpacity(0.55)),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.28),
//             blurRadius: 20,
//             spreadRadius: -14,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         child: Text(
//           text,
//           style: GoogleFonts.spaceMono(
//             fontSize: 12,
//             fontWeight: FontWeight.w900,
//             letterSpacing: 0.9,
//             color: Colors.white.withOpacity(0.92),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NeonOutline extends StatelessWidget {
//   const _NeonOutline({required this.child, required this.color});

//   final Widget child;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         color: Colors.white.withOpacity(0.03),
//         border: Border.all(color: color.withOpacity(0.55)),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.14),
//             blurRadius: 20,
//             spreadRadius: -14,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }

// class _NeonDivider extends StatelessWidget {
//   const _NeonDivider();

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 2,
//       child: DecoratedBox(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(99),
//           gradient: LinearGradient(
//             colors: [
//               _Neon.cyan.withOpacity(0.0),
//               _Neon.cyan.withOpacity(0.8),
//               _Neon.magenta.withOpacity(0.8),
//               _Neon.magenta.withOpacity(0.0),
//             ],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: _Neon.cyan.withOpacity(0.18),
//               blurRadius: 14,
//               spreadRadius: -10,
//               offset: const Offset(0, 8),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _InfoBadge extends StatelessWidget {
//   const _InfoBadge({required this.title, required this.value});

//   final String title;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.white.withOpacity(0.08)),
//         color: Colors.white.withOpacity(0.04),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               '$title ',
//               style: GoogleFonts.spaceMono(
//                 fontSize: 11,
//                 color: Colors.white.withOpacity(0.55),
//               ),
//             ),
//             Text(
//               value,
//               style: GoogleFonts.spaceMono(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white.withOpacity(0.86),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _AnimatedNeonBackdrop extends StatelessWidget {
//   const _AnimatedNeonBackdrop();

//   @override
//   Widget build(BuildContext context) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0, end: 1),
//       duration: const Duration(seconds: 6),
//       curve: Curves.easeInOut,
//       builder: (context, t, _) {
//         return ShaderMask(
//           shaderCallback: (rect) {
//             final a = 0.25 + 0.35 * math.sin(t * math.pi * 2);
//             return LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 _Neon.cyan.withOpacity(a),
//                 _Neon.magenta.withOpacity(0.10),
//                 _Neon.lime.withOpacity(0.08),
//                 Colors.transparent,
//               ],
//               stops: const [0, 0.35, 0.7, 1],
//             ).createShader(rect);
//           },
//           blendMode: BlendMode.plus,
//           child: const DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: RadialGradient(
//                 center: Alignment(-0.6, -0.8),
//                 radius: 1.4,
//                 colors: [
//                   Color(0xFF0B1020),
//                   Color(0xFF04040A),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class _GridPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1;

//     // 微弱“赛博”网格：横线 + 斜线
//     final step = 34.0;
//     final colorA = _Neon.cyan.withOpacity(0.06);
//     final colorB = _Neon.magenta.withOpacity(0.04);

//     for (double y = -size.height * 0.2; y < size.height * 1.2; y += step) {
// paint.color = (y / step).toInt().isEven ? colorA : colorB;
//       final p1 = Offset(-80, y);
//       final p2 = Offset(size.width + 80, y + 16);
//       canvas.drawLine(p1, p2, paint);
//     }

//     paint.color = Colors.white.withOpacity(0.035);
//     for (double x = -size.width * 0.2; x < size.width * 1.2; x += step) {
//       final p1 = Offset(x, -40);
//       final p2 = Offset(x + 18, size.height + 40);
//       canvas.drawLine(p1, p2, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class _Neon {
//   static const bg = Color(0xFF05060B);
//   static const surface = Color(0xFF0D0F19);

//   static const cyan = Color(0xFF36E7FF);
//   static const magenta = Color(0xFFFF2BD6);
//   static const lime = Color(0xFFB9FF2B);
//   static const amber = Color(0xFFFFC24A);
// }

