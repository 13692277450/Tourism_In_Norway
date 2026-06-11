import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'app_shared.dart';

class VersionChecker {
  static const String _versionUrl =
      '${AppConfig.baseWebUrl}/tourism/NorwayTravel/version.json';

  static Future<VersionInfo?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(_versionUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['version'] as String;
        final apkUrl = data['apk_url'] as String;
        final releaseNotes = data['release_notes'] as String;
        final isMandatory = data['is_mandatory'] as bool;

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        if (_compareVersions(latestVersion, currentVersion) > 0) {
          return VersionInfo(
            latestVersion: latestVersion,
            currentVersion: currentVersion,
            apkUrl: apkUrl,
            releaseNotes: releaseNotes,
            isMandatory: isMandatory,
          );
        }
      }
    } catch (e) {
      print('版本检查失败: $e');
    }
    return null;
  }

  static int _compareVersions(String v1, String v2) {
    final parts1 =
        v1.split('.').map((part) => int.tryParse(part) ?? 0).toList();
    final parts2 =
        v2.split('.').map((part) => int.tryParse(part) ?? 0).toList();
    final length =
        parts1.length > parts2.length ? parts1.length : parts2.length;

    for (int i = 0; i < length; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 != p2) return p1 - p2;
    }
    return 0;
  }
}

class VersionInfo {
  final String latestVersion;
  final String currentVersion;
  final String apkUrl;
  final String releaseNotes;
  final bool isMandatory;

  VersionInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.apkUrl,
    required this.releaseNotes,
    required this.isMandatory,
  });
}
