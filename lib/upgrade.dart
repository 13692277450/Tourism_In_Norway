import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart'; // 添加这个

class Upgrade extends StatefulWidget {
  final String? apkUrl;

  const Upgrade({super.key, this.apkUrl});

  @override
  State<Upgrade> createState() => _UpgradeState();
}

class _UpgradeState extends State<Upgrade> with SingleTickerProviderStateMixin {
  String? get apkUrl => widget.apkUrl;
  double _progress = 0;
  int _status = DownloadTaskStatus.enqueued.index;
  String? _taskId;
  late AnimationController _spinnerController;
  StreamSubscription? _downloadSubscription;
  bool _isInitialized = false;
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _initializeAndCheckPermissions();
  }

  Future<void> _initializeAndCheckPermissions() async {
    try {
      // 初始化下载器
      await FlutterDownloader.initialize(debug: true);
      FlutterDownloader.registerCallback(downloadCallback);
      
      // 请求权限
      final hasPermission = await _requestAllPermissions();
      if (hasPermission) {
        setState(() {
          _isInitialized = true;
        });
        await _startDownload();
      } else {
        _showError('需要存储权限才能下载更新');
      }
    } catch (e) {
      print('初始化失败: $e');
      _showError('初始化失败: $e');
    }
  }

  Future<bool> _requestAllPermissions() async {
    if (!Platform.isAndroid) return true;
    
    setState(() {
      _isRequestingPermission = true;
    });
    
    List<Permission> permissions = [];
    
    // Android 13+ (API 33+) 需要通知权限
    if (await Permission.notification.isDenied) {
      permissions.add(Permission.notification);
    }
    
    // Android 10 及以下需要存储权限
    if (await Permission.storage.isDenied) {
      permissions.add(Permission.storage);
    }
    
    // 安装权限（所有版本都需要）
    if (await Permission.requestInstallPackages.isDenied) {
      permissions.add(Permission.requestInstallPackages);
    }
    
    // Android 11+ 可能需要管理外部存储权限
    if (await Permission.manageExternalStorage.isDenied) {
      permissions.add(Permission.manageExternalStorage);
    }
    
    if (permissions.isEmpty) {
      setState(() {
        _isRequestingPermission = false;
      });
      return true;
    }
    
    // 请求权限
    final results = await permissions.request();
    
    setState(() {
      _isRequestingPermission = false;
    });
    
    // 检查是否所有权限都被授予
    bool allGranted = true;
    for (var permission in permissions) {
      if (!await permission.isGranted) {
        allGranted = false;
        print('权限被拒绝: ${permission.toString()}');
      }
    }
    
    if (!allGranted) {
      // 如果权限被拒绝，提示用户
      _showPermissionDialog();
      return false;
    }
    
    return true;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要权限'),
        content: const Text('应用需要存储权限才能下载更新文件，请在设置中授予权限。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // 返回上一页
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // 打开应用设置页面
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    print('Download callback: id=$id, status=$status, progress=$progress');
    _downloadStreamController.add({
      'id': id,
      'status': status,
      'progress': progress,
    });
  }

  static final StreamController<Map<String, dynamic>> _downloadStreamController = 
      StreamController.broadcast();

  Future<void> _startDownload() async {
    try {
      // 检查平台
      if (!Platform.isAndroid) {
        _showError('当前平台不支持自动更新');
        return;
      }

      // 再次确认权限
      final hasStoragePermission = await Permission.storage.isGranted;
      final hasManagePermission = await Permission.manageExternalStorage.isGranted;
      
      if (!hasStoragePermission && !hasManagePermission) {
        _showError('需要存储权限才能下载');
        return;
      }

      // 获取正确的下载目录
      final directory = await _getDownloadDirectory();
      if (directory == null) {
        _showError('无法获取下载目录');
        return;
      }

      final savePath = '${directory.path}/app-release.apk';
      
      // 删除旧文件
      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
        print('已删除旧APK文件');
      }

      print('下载目录: ${directory.path}');
      print('保存路径: $savePath');
      print('下载URL: ${apkUrl ?? 'http://www.pavogroup.top/tourism/NorwayTravel/app-release.apk'}');

      // 监听下载状态
      _downloadSubscription?.cancel();
      _downloadSubscription = _downloadStreamController.stream.listen((data) {
        print('收到下载数据: $data');
        if (mounted && data['id'] == _taskId) {
          setState(() {
            _status = data['status'];
            _progress = data['progress'].toDouble();
          });

          print('下载进度: ${data['progress']}%, 状态: ${_getStatusText(data['status'])}');

          if (data['status'] == DownloadTaskStatus.complete.index) {
            _installApk();
          } else if (data['status'] == DownloadTaskStatus.failed.index) {
            _showError('下载失败，请检查网络连接');
          }
        }
      });

      // 开始下载
      print('开始创建下载任务...');
      _taskId = await FlutterDownloader.enqueue(
        url: apkUrl ?? 'http://www.pavogroup.top/tourism/NorwayTravel/app-release.apk',
        savedDir: directory.path,
        fileName: 'app-release.apk',
        showNotification: true,
        openFileFromNotification: false,
        saveInPublicStorage: true,
      );

      print('下载任务ID: $_taskId');
      
      if (_taskId != null) {
        setState(() {
          _status = DownloadTaskStatus.running.index;
        });
      } else {
        _showError('无法创建下载任务');
      }

    } catch (e) {
      print('下载启动失败: $e');
      _showError('下载启动失败: $e');
    }
  }

  Future<Directory?> _getDownloadDirectory() async {
    try {
      // 尝试获取外部存储目录
      if (Platform.isAndroid) {
        // 方法1: 使用 getExternalStorageDirectory
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          print('使用外部存储目录: ${externalDir.path}');
          return externalDir;
        }
      }
      
      // 方法2: 回退到应用文档目录
      final docDir = await getApplicationDocumentsDirectory();
      print('使用应用文档目录: ${docDir.path}');
      return docDir;
    } catch (e) {
      print('获取目录失败: $e');
      return null;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0: return 'enqueued';
      case 1: return 'running';
      case 2: return 'complete';
      case 3: return 'failed';
      case 4: return 'paused';
      case 5: return 'canceled';
      default: return 'unknown';
    }
  }

  Future<void> _installApk() async {
    try {
      final directory = await _getDownloadDirectory();
      if (directory == null) {
        _showError('无法获取安装目录');
        return;
      }

      final filePath = '${directory.path}/app-release.apk';
      final file = File(filePath);

      if (await file.exists()) {
        print('开始安装APK: $filePath');
        final result = await OpenFile.open(filePath);
        print('安装结果: ${result.type}');
        
        if (result.type != ResultType.done) {
          _showError('无法自动安装，请手动打开APK文件');
        }
      } else {
        print('APK文件不存在: $filePath');
        _showError('APK文件不存在');
      }
    } catch (e) {
      print('安装失败: $e');
      _showError('安装失败: $e');
    }
  }

  void _showError(String message) {
    print('错误: $message');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  double _progressPercent() {
    return _progress.clamp(0, 100);
  }

  String _statusText() {
    final pct = _progressPercent().toStringAsFixed(0);

    if (_isRequestingPermission) {
      return '正在请求权限...';
    }

    switch (_status) {
      case 0:
        return '准备更新...';
      case 1:
        return '请稍等下，APP更新进行中：$pct %';
      case 2:
        return '下载完成，准备安装...';
      case 3:
        return '下载失败，请重试';
      case 4:
        return '下载已暂停';
      case 5:
        return '下载已取消';
      default:
        return '正在准备更新...';
    }
  }

  Widget _buildProgressBar() {
    final pct = _progressPercent();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: LinearProgressIndicator(
        value: pct / 100,
        backgroundColor: Colors.grey[200],
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3D5AFE)),
        minHeight: 8.h,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        title: const Text('APP更新'),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _spinnerController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _spinnerController.value * 2 * 3.14159,
                    child: Icon(
                      _status == DownloadTaskStatus.complete.index 
                          ? Icons.center_focus_weak_outlined 
                          : (_status == DownloadTaskStatus.running.index 
                              ? Icons.downloading_rounded 
                              : Icons.download_done_rounded),
                      size: 64.r,
                      color: isDark ? const Color.fromARGB(255, 98, 220, 244) : const Color.fromARGB(255, 82, 104, 226),
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),

              Text(
                _statusText(),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              if (_status == DownloadTaskStatus.running.index ||
                  _status == DownloadTaskStatus.complete.index) ...[
                _buildProgressBar(),
                SizedBox(height: 16.h),
                Text(
                  '${_progressPercent().toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF00D4FF) : const Color(0xFF3D5AFE),
                  ),
                ),
              ],
              
              if (_isRequestingPermission)
                Padding(
                  padding: EdgeInsets.only(top: 24.h),
                  child: const CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}