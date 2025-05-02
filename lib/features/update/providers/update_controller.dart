import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/github_service.dart';
import '../widgets/update_dialog.dart';

class UpdateController with ChangeNotifier {
  bool _isChecking = false;
  bool get isChecking => _isChecking;

  DateTime? _lastCheckTime;

  // 更新设置
  bool _autoCheckEnabled = true;
  int _checkInterval = 24; // 小时
  bool _notifyOnlyForStable = true;

  bool get autoCheckEnabled => _autoCheckEnabled;
  int get checkInterval => _checkInterval;
  bool get notifyOnlyForStable => _notifyOnlyForStable;

  // 初始化控制器，从本地存储加载设置
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _autoCheckEnabled = prefs.getBool('update_auto_check') ?? true;
    _checkInterval = prefs.getInt('update_check_interval') ?? 24;
    _notifyOnlyForStable = prefs.getBool('update_notify_only_stable') ?? true;
    _lastCheckTime = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt('update_last_check_time') ?? 0,
    );

    notifyListeners();

    // 检查是否需要自动检查更新
    if (_autoCheckEnabled && _shouldCheckForUpdates()) {
      // 延迟几秒后自动检查，避免影响应用启动速度
      Future.delayed(
        const Duration(seconds: 3),
        () => checkForUpdates(null, silent: true),
      );
    }
  }

  // 更新设置并保存到本地存储
  Future<void> updateSettings({
    bool? autoCheckEnabled,
    int? checkInterval,
    bool? notifyOnlyForStable,
  }) async {
    if (autoCheckEnabled != null) _autoCheckEnabled = autoCheckEnabled;
    if (checkInterval != null) _checkInterval = checkInterval;
    if (notifyOnlyForStable != null) _notifyOnlyForStable = notifyOnlyForStable;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('update_auto_check', _autoCheckEnabled);
    await prefs.setInt('update_check_interval', _checkInterval);
    await prefs.setBool('update_notify_only_stable', _notifyOnlyForStable);

    notifyListeners();
  }

  // 检查更新
  Future<void> checkForUpdates(
    BuildContext? context, {
    bool silent = false,
  }) async {
    if (_isChecking) return;

    _isChecking = true;
    notifyListeners();

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final updateInfo = await GithubService.checkForUpdates(currentVersion);

      // 更新最后检查时间
      _lastCheckTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'update_last_check_time',
        _lastCheckTime!.millisecondsSinceEpoch,
      );

      if (updateInfo != null) {
        // 检查是否只提醒稳定版
        bool isStableRelease =
            !updateInfo['version'].toString().contains('beta') &&
            !updateInfo['version'].toString().contains('alpha');

        if (_notifyOnlyForStable && !isStableRelease) {
          return;
        }

        if (context != null && context.mounted) {
          _showUpdateDialog(context, updateInfo);
        }
      } else if (!silent && context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('当前已是最新版本')));
      }
    } catch (e) {
      debugPrint('检查更新失败: $e');
      if (!silent && context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('检查更新失败: $e')));
      }
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  // 显示更新对话框
  void _showUpdateDialog(
    BuildContext context,
    Map<String, dynamic> updateInfo,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(updateInfo: updateInfo),
    );
  }

  // 根据上次检查时间和检查间隔，决定是否应该检查更新
  bool _shouldCheckForUpdates() {
    if (_lastCheckTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_lastCheckTime!).inHours;

    return difference >= _checkInterval;
  }

  // 重置通知状态
  void resetNotificationState() {
    notifyListeners();
  }
}
