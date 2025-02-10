import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._();
  factory UpdateService() => _instance;

  late PackageInfo _packageInfo;
  bool _isChecking = false;

  UpdateService._();

  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  Future<UpdateInfo?> checkForUpdates() async {
    if (_isChecking) return null;
    _isChecking = true;

    try {
      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 1));

      // 获取当前版本
      final currentVersion = Version.parse(_packageInfo.version);

      // 模拟最新版本信息（这里设置为比当前版本高一个小版本号）
      final latestVersion = Version(
        currentVersion.major,
        currentVersion.minor + 1,
        currentVersion.patch,
      );

      if (latestVersion > currentVersion) {
        return UpdateInfo(
          version: latestVersion.toString(),
          description: '''
新版本包含以下更新：
1. 优化了应用性能
2. 修复了一些已知问题
3. 添加了新功能
''',
          downloadUrl: 'https://github.com/your-repo/releases/latest',
          isForced: false,
        );
      }
      return null;
    } catch (e) {
      print('检查更新失败: $e');
      return null;
    } finally {
      _isChecking = false;
    }
  }
}

class UpdateInfo {
  final String version;
  final String description;
  final String downloadUrl;
  final bool isForced;

  UpdateInfo({
    required this.version,
    required this.description,
    required this.downloadUrl,
    this.isForced = false,
  });
}
