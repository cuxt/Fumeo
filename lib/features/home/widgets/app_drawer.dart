import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fumeo/core/providers/app_state.dart';
import '../models/feature_model.dart';

class AppDrawer extends StatefulWidget {
  final Map<String, List<FeatureModel>> featureMap;

  const AppDrawer({
    super.key,
    required this.featureMap,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context);
    final currentTheme = Theme.of(context);

    return Drawer(
      elevation: 2.0,
      child: Column(
        children: [
          // 抽屉头部 - 用户信息展示区
          UserAccountsDrawerHeader(
            accountName: const Text(
              'Fumeo用户',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            accountEmail: const Text(
              '高效率的笔记与任务管理工具',
              style: TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: currentTheme.colorScheme.secondary,
              child: const Icon(
                Icons.person,
                size: 48,
                color: Colors.white,
              ),
            ),
            decoration: BoxDecoration(
              color: currentTheme.colorScheme.primary,
            ),
          ),

          // 主题切换选项
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('主题设置'),
            subtitle: const Text('选择您喜欢的主题颜色'),
            trailing: const Icon(Icons.keyboard_arrow_down),
            onTap: () => _showThemeSelector(context),
          ),

          const Divider(),

          // 功能导航列表
          Expanded(
            child: _buildNavigationItems(context),
          ),

          // 底部 - 版本信息和更新检查
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'V1.0.0',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // 检查更新功能将在后续实现
                    Navigator.pop(context); // 关闭抽屉
                  },
                  icon: const Icon(Icons.system_update, size: 16),
                  label: const Text('检查更新'),
                  style: TextButton.styleFrom(
                    foregroundColor: currentTheme.colorScheme.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建导航菜单项
  Widget _buildNavigationItems(BuildContext context) {
    final List<Widget> navigationItems = [];

    widget.featureMap.forEach((category, features) {
      // 如果该类别没有要显示的功能，则跳过
      if (features.isEmpty) {
        return;
      }

      // 添加分类标题
      navigationItems.add(
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );

      // 添加功能项
      for (final feature in features) {
        navigationItems.add(
          ListTile(
            leading: Icon(feature.icon ?? Icons.label_outline),
            title: Text(feature.text),
            onTap: () {
              Navigator.pop(context); // 关闭抽屉
              context.go(feature.route); // 导航到目标页面
            },
          ),
        );
      }

      navigationItems.add(const Divider());
    });

    return ListView(
      padding: EdgeInsets.zero,
      children: navigationItems,
    );
  }

  // 显示主题选择器
  void _showThemeSelector(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final themeManager = appState.themeManager;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.blue),
                title: const Text('蓝色主题'),
                onTap: () {
                  themeManager.setPrimaryColor(Colors.blue);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.green),
                title: const Text('绿色主题'),
                onTap: () {
                  themeManager.setPrimaryColor(Colors.green);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.red),
                title: const Text('红色主题'),
                onTap: () {
                  themeManager.setPrimaryColor(Colors.red);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.purple),
                title: const Text('紫色主题'),
                onTap: () {
                  themeManager.setPrimaryColor(Colors.purple);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
