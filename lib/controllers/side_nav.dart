import 'package:get/get.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter/material.dart';

class MenuItemModel {
  final HeroIcons icon;
  final String title;
  final Color color;
  final String route;

  MenuItemModel({
    required this.icon,
    required this.title,
    required this.color,
    required this.route,
  });
}

class SideNavController extends GetxController {
  final menuItems = <MenuItemModel>[
    MenuItemModel(
      icon: HeroIcons.pencil,
      title: '笔记',
      color: Colors.green,
      route: '/note',
    ),
    MenuItemModel(
      icon: HeroIcons.chatBubbleLeftRight,
      title: '聊天',
      color: Colors.blue,
      route: '/im/login',
    ),
    MenuItemModel(
      icon: HeroIcons.eye,
      title: '发现',
      color: Colors.red,
      route: '/explore',
    ),
    MenuItemModel(
      icon: HeroIcons.listBullet,
      title: 'Todo',
      color: Colors.orange,
      route: '/todo',
    ),
  ].obs;

  final settingsItems = <MenuItemModel>[
    MenuItemModel(
      icon: HeroIcons.cog6Tooth,
      title: '设置',
      color: Colors.grey,
      route: '/settings',
    ),
    MenuItemModel(
      icon: HeroIcons.informationCircle,
      title: '关于',
      color: Colors.blue,
      route: '/about',
    ),
  ].obs;

  void handleMenuItemTap(String route) {
    if (route.isNotEmpty) {
      Get.back();
      Get.toNamed(route);
    }
  }
}
