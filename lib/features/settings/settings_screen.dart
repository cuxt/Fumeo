import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fumeo/core/router/app_router.dart';
import 'package:fumeo/core/providers/app_state.dart';
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
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Consumer<SettingsProvider>(builder: (context, settings, _) {
          final appState = Provider.of<AppState>(context);

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

              // 暗色模式开关
              SettingsTile(
                icon: appState.themeManager.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                title: '暗色模式',
                subtitle: appState.themeManager.themeMode == ThemeMode.dark
                    ? '已启用'
                    : (appState.themeManager.themeMode == ThemeMode.light
                        ? '已禁用'
                        : '跟随系统'),
                trailing: Switch(
                  value: appState.themeManager.themeMode == ThemeMode.dark,
                  onChanged: (_) {
                    if (appState.themeManager.themeMode == ThemeMode.dark) {
                      appState.themeManager.setThemeMode(ThemeMode.light);
                    } else {
                      appState.themeManager.setThemeMode(ThemeMode.dark);
                    }
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  if (appState.themeManager.themeMode == ThemeMode.dark) {
                    appState.themeManager.setThemeMode(ThemeMode.light);
                  } else {
                    appState.themeManager.setThemeMode(ThemeMode.dark);
                  }
                },
              ),

              const Divider(),

              _buildSection(context, '应用信息'),

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
                onTap: () => context.push(AppRouter.about),
              ),
            ],
          );
        }),
      ),
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
