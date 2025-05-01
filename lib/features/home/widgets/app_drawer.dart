import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  String _version = "";

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = packageInfo.version;
        });
      }
    } catch (e) {
      // 处理可能的异常
      _version = "1.0.0";
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context);
    final currentTheme = Theme.of(context);

    return Drawer(
      elevation: 2.0,
      child: Column(
        children: [
          // 抽屉头部 - 显示应用名
          Container(
            width: double.infinity,
            height: 150,
            color: currentTheme.colorScheme.primary,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Fumeo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                Text(
                  'v$_version',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                )
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
}
