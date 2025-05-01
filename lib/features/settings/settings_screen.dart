import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fumeo/core/router/app_router.dart';
import 'package:fumeo/core/theme/theme_controller.dart';
import 'package:fumeo/features/update/providers/update_controller.dart'; // 导入更新控制器
import 'providers/settings_provider.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
        ),
        body: Consumer2<SettingsProvider, ThemeController>(
          builder: (context, settings, themeController, _) {
            return ListView(
              children: [
                const SizedBox(height: 16),
                _buildSection(context, '外观'),

                // 主题设置入口
                SettingsTile(
                  icon: Icons.color_lens,
                  title: '主题设置',
                  subtitle: '自定义应用颜色和主题样式',
                  onTap: () => context.push(AppRouter.themeSettings),
                ),

                // 主题模式选择
                SettingsTile(
                  icon: _getThemeModeIcon(themeController.themeMode),
                  title: '主题模式',
                  subtitle: _getThemeModeText(themeController.themeMode),
                  onTap: () => _showThemeModeDialog(context, themeController),
                ),

                const Divider(),

                _buildSection(context, '应用信息'),

                // 检查更新
                Consumer<UpdateController>(
                  builder: (context, updateController, _) {
                    return SettingsTile(
                      icon: Icons.system_update_outlined,
                      title: '检查更新',
                      subtitle: '检查是否有新版本可用',
                      trailing: updateController.isChecking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : null,
                      onTap: () => updateController.checkForUpdates(context),
                    );
                  },
                ),

                // 版本信息
                SettingsTile(
                  icon: Icons.info_outline,
                  title: '应用版本',
                  subtitle: settings.fullVersion,
                ),

                // 关于页面
                SettingsTile(
                  icon: Icons.help_outline,
                  title: '关于',
                  subtitle: '了解更多应用信息',
                  onTap: () => context.go('/settings/about'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 获取主题模式图标
  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  // 获取主题模式文本描述
  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '亮色模式';
      case ThemeMode.dark:
        return '暗色模式';
    }
  }

  // 显示主题模式选择对话框
  void _showThemeModeDialog(
      BuildContext context, ThemeController themeController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeModeOption(context, '跟随系统', Icons.brightness_auto,
                ThemeMode.system, themeController),
            const Divider(),
            _buildThemeModeOption(context, '亮色模式', Icons.light_mode,
                ThemeMode.light, themeController),
            const Divider(),
            _buildThemeModeOption(context, '暗色模式', Icons.dark_mode,
                ThemeMode.dark, themeController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  // 构建主题模式选项
  Widget _buildThemeModeOption(BuildContext context, String title,
      IconData icon, ThemeMode mode, ThemeController themeController) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: themeController.themeMode == mode
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        themeController.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
