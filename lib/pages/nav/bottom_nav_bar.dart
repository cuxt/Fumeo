import 'package:flutter/material.dart';
import 'package:fumeo/controllers/nav.dart';
import 'package:get/get.dart';
import 'package:heroicons/heroicons.dart';

class BottomNavBar extends GetView<NavController> {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BottomNavigationBar(
        currentIndex: controller.currentIndex,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context)
            .colorScheme
            .onSurface
            .withAlpha((0.6 * 255).toInt()),
        onTap: controller.changePage,
        items: [
          _buildBottomNavItem(context, HeroIcons.home, '首页', 0),
          _buildBottomNavItem(context, HeroIcons.pencil, 'Todo', 1),
          _buildBottomNavItem(context, HeroIcons.eye, '发现', 2),
          _buildBottomNavItem(context, HeroIcons.user, '我的', 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(
      BuildContext context, HeroIcons iconType, String label, int index) {
    return BottomNavigationBarItem(
      icon: Obx(
        () => HeroIcon(
          iconType,
          style: HeroIconStyle.outline,
          color: controller.currentIndex == index
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withAlpha((0.6 * 255).toInt()),
          size: 24,
        ),
      ),
      label: label,
    );
  }
}
