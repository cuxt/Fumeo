import 'package:flutter/material.dart';
import 'package:fumeo/routes/routes.dart';
import 'package:get/get.dart';
import 'package:heroicons/heroicons.dart';

class SideNavBar extends StatelessWidget {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "F",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "umeo",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildListTile(
                icon: const HeroIcon(
                  HeroIcons.informationCircle,
                  style: HeroIconStyle.outline,
                ),
                title: '关于',
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.about);
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: _buildListTile(
              icon: const HeroIcon(
                HeroIcons.cog6Tooth,
                style: HeroIconStyle.outline,
              ),
              title: '设置',
              onTap: () {
                Get.back();
                Get.toNamed(Routes.settings);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required Widget icon, // 修改类型为 Widget
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: ListTile(
          leading: icon, // 直接使用传入的 icon widget
          title: Text(title),
        ),
      ),
    );
  }
}
