// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'app_shared.dart' as shared;

// class ServicePage extends StatelessWidget {
//   const ServicePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final loc = shared.AppLocalizations.of(context);
//     return _PageShell(
//       title: loc.shopTitle,
//       subtitle: loc.shopSubtitle,
//       description: loc.shopDescription,
//       accent: const Color(0xFFF57C00),
//       imageAsset: Icons.shopping_bag,
//     );
//   }
// }

// class _PageShell extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final String description;
//   final Color accent;
//   final IconData imageAsset;

//   const _PageShell({
//     required this.title,
//     required this.subtitle,
//     required this.description,
//     required this.accent,
//     required this.imageAsset,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 34.sp,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF19233F),
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Text(
//             subtitle,
//             style: TextStyle(
//               fontSize: 16.sp,
//               color: const Color(0xFF52607D),
//             ),
//           ),
//           SizedBox(height: 24.h),
//           Expanded(
//             child: Center(
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(28.w),
//                   gradient: LinearGradient(
//                     colors: [accent.withOpacity(0.16), Colors.white],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: accent.withOpacity(0.12),
//                       blurRadius: 24,
//                       offset: Offset(0, 16.h),
//                     ),
//                   ],
//                 ),
//                 padding: EdgeInsets.all(26.w),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       imageAsset,
//                       size: 96.r,
//                       color: accent.withOpacity(0.18),
//                     ),
//                     SizedBox(height: 24.h),
//                     Text(
//                       description,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.w600,
//                         color: const Color(0xFF222B45),
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     Text(
//                       '•  •',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: accent,
//                         letterSpacing: 1.2,
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
