import 'package:flutter/material.dart';
import 'package:fumeo/controllers/theme.dart';
import 'package:fumeo/controllers/update.dart';
import 'package:fumeo/pages/nav/side_nav_bar.dart';
import 'package:get/get.dart';

class MineView extends GetView<ThemeController> {
  const MineView({super.key});

  @override
  Widget build(BuildContext context) {
    final updateController = Get.put(UpdateController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Icon(Icons.menu),
            ),
          ),
        ),
      ),
      drawer: const SideNavBar(),
      body: ListView(
        children: [
          const UserHeader(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置'),
            onTap: () => Get.toNamed('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('深色模式'),
            trailing: Obx(
                  () => Switch(
                value: controller.isDarkMode.value,
                onChanged: (value) => controller.toggleTheme(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text('检查更新'),
            trailing: Obx(
                  () => updateController.isChecking.value
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.arrow_forward_ios, size: 18),
            ),
            onTap: () => updateController.checkUpdate(),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            onTap: () => Get.toNamed('/about'),
          ),
        ],
      ),
    );
  }
}

// UserHeader 保持不变
class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          const Text(
            'Fumeo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '个人简介',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
