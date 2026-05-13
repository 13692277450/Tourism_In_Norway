import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ota_update/ota_update.dart';

import 'settings.dart';

/// Example widget for ota_update plugin.
class Upgrade extends StatefulWidget {
  final String? apkUrl;

  const Upgrade({
    super.key,
    this.apkUrl,
  });

  @override
  UpgradeState createState() => UpgradeState();
}

class UpgradeState extends State<Upgrade> with SingleTickerProviderStateMixin {
  OtaEvent? currentEvent;
  String? get apkUrl => widget.apkUrl;

  late final AnimationController _spinnerController;
  late final Animation<double> _spinner;

  @override
  void initState() {
    super.initState();

    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _spinner = Tween<double>(begin: 0, end: 1).animate(_spinnerController);

    tryOtaUpdate();
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    super.dispose();
  }

  Future<void> tryOtaUpdate() async {
    try {
      OtaUpdate().execute(
        'http://www.pavogroup.top/tourism/NorwayTravel/app-release.apk',
        destinationFilename: 'app-release.apk',
      ).listen((OtaEvent event) {
        print('OTA Event: ${event.status} - ${event.value}');
        if (!mounted) return;
        setState(() => currentEvent = event);
      });
    } catch (e) {
      // ignore: avoid_print
      print('对不起，安装更新失败，错误代码: $e');
    }
  }

  double _progressPercent() {
    final raw = currentEvent?.value;
    if (raw == null) return 0;

    final parsed = double.tryParse(raw.toString());
    if (parsed == null) return 0;

    return parsed.clamp(0, 100);
  }

  String _statusText() {
    final status = currentEvent?.status;
    final value = currentEvent?.value;

    if (status == null && value == null) return '正在准备更新…';
    final pct = _progressPercent().toStringAsFixed(0);
    return '请稍等下，APP更新进行中：${pct} %';
  }

  @override
  Widget build(BuildContext context) {
    final pct = _progressPercent();
    final isReady = currentEvent != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('APP Upgrade...'),
        leading: IconButton(
          iconSize: 24,
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 24.0,
            semanticLabel: 'GO BACK',
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(
                  locale: const Locale('en'),
                  onLocaleChanged: (l) {},
                ),
                maintainState: false,
              ),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeaderCard(pct: pct, isReady: isReady, spinner: _spinner),
                SizedBox(height: 18.h),
                _ProgressCard(pct: pct),
                SizedBox(height: 14.h),
                Text(
                  _statusText(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E2D),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Text(
                  '感谢您的耐心等候，如果网络速度合适，更新大概需要两分钟左右。',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF65748B),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  '本次更新APP的服务器：www.pavogroup.top。',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF4B4B6B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final double pct;
  final bool isReady;
  final Animation<double> spinner;

  const _HeaderCard({
    required this.pct,
    required this.isReady,
    required this.spinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.w),
        border: Border.all(color: const Color(0xFF1E1E2D), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.06),
            blurRadius: 16,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 62.w,
            height: 62.w,
            child: AnimatedBuilder(
              animation: spinner,
              builder: (context, _) {
                final angle = spinner.value * 2 * 3.1415926;
                return Transform.rotate(
                  angle: angle,
                  child: Container(
                    decoration: BoxDecoration(
                      color: pct > 0.5 ? const Color(0xFF2ECC71) : const Color(0xFFF1C40F),
                      borderRadius: BorderRadius.circular(18.w),
                      border: Border.all(color: const Color(0xFF1E1E2D), width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        isReady ? Icons.download_done_rounded : Icons.downloading_rounded,
                        size: 28.r,
                        color: const Color(0xFF1E1E2D),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPDATE IN PROGRESS',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: const Color(0xFF1E1E2D),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '下载与安装中…',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E1E2D),
                  ),
                ),
                SizedBox(height: 8.h),
                _Pill(text: '${pct.toStringAsFixed(0)}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF1E1E2D), width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1E1E2D),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final double pct;

  const _ProgressCard({required this.pct});

  @override
  Widget build(BuildContext context) {
    final shown = pct.clamp(0, 100);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.w),
        border: Border.all(color: const Color(0xFF1E1E2D), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_mosaic_rounded, color: Color(0xFF1E1E2D)),
              SizedBox(width: 10.w),
              Text(
                'DOWNLOADING / INSTALLING',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1E2D),
                ),
              ),
              const Spacer(),
              Text(
                '${shown.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1E2D),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: shown / 100,
              minHeight: 18.h,
              backgroundColor: const Color(0xFFE9ECF3),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF4D4D)),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              _StepDot(active: shown >= 0),
              SizedBox(width: 10.w),
              _StepDot(active: shown >= 25),
              SizedBox(width: 10.w),
              _StepDot(active: shown >= 50),
              SizedBox(width: 10.w),
              _StepDot(active: shown >= 75),
              const Spacer(),
              Text(
                '请勿退出应用',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF65748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;

  const _StepDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18.r,
      height: 18.r,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFF4D4D) : const Color(0xFFE9ECF3),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1E1E2D), width: 2),
      ),
    );
  }
}