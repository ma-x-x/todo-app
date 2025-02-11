import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

/// 更新服务类
/// 检查应用更新并提供更新信息
class UpdateService {
  static final UpdateService _instance = UpdateService._();
  factory UpdateService() => _instance;

  late PackageInfo _packageInfo;
  bool _isChecking = false;

  UpdateService._();

  /// 初始化更新服务
  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// 检查应用更新
  ///
  /// 返回:
  /// - 如果有更新可用，返回 UpdateInfo 对象
  /// - 如果没有更新或检查失败，返回 null
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
          downloadUrl: 'https://github.com/ma-x-x/todo-app/releases/latest',
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

/// 更新信息类
/// 包含应用更新的详细信息
class UpdateInfo {
  /// 新版本号
  final String version;

  /// 更新说明
  final String description;

  /// 下载地址
  final String downloadUrl;

  /// 是否强制更新
  final bool isForced;

  UpdateInfo({
    required this.version,
    required this.description,
    required this.downloadUrl,
    this.isForced = false,
  });
}
