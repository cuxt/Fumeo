import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:fumeo/core/theme/theme_manager.dart';

class SettingsProvider extends ChangeNotifier {
  String _appVersion = '';
  String _buildNumber = '';
  late ThemeManager _themeManager;

  // 亮暗主题相关
  bool get isDarkMode => _themeManager.themeMode == ThemeMode.dark;

  SettingsProvider() {
    _loadAppInfo();
  }

  // 初始化，获取ThemeManager引用
  void initialize(BuildContext context) {
    _themeManager = Provider.of<ThemeManager>(context, listen: false);
    notifyListeners();
  }

  // 获取应用版本信息
  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
      notifyListeners();
    } catch (e) {
      debugPrint('获取应用信息失败: $e');
    }
  }

  // 切换暗色/亮色模式
  void toggleDarkMode() {
    _themeManager.toggleThemeMode();
    notifyListeners();
  }

  // 获取应用版本
  String get appVersion => _appVersion;

  // 获取应用构建号
  String get buildNumber => _buildNumber;

  // 获取完整版本信息
  String get fullVersion => 'v$_appVersion ($_buildNumber)';
}
