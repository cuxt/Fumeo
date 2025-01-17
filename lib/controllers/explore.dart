import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreController extends GetxController {
  final features = [
    {
      'title': '功能',
      'icon': Icons.chat_bubble,
      'color': Colors.blue,
      'route': '/feature1',
    },
    {
      'title': '功能',
      'icon': Icons.folder_shared,
      'color': Colors.green,
      'route': '/feature2',
    },
    {
      'title': '功能',
      'icon': Icons.bar_chart,
      'color': Colors.orange,
      'route': '/feature3',
    },
    {
      'title': '功能',
      'icon': Icons.settings,
      'color': Colors.purple,
      'route': '/feature4',
    },
    {
      'title': '功能',
      'icon': Icons.help_outline,
      'color': Colors.teal,
      'route': '/feature5',
    },
    {
      'title': '功能',
      'icon': Icons.info_outline,
      'color': Colors.indigo,
      'route': '/feature6',
    },
  ].obs;

  void handleFeatureTap(int index) {
    Get.snackbar('提示', '功能${index + 1}正在开发中...',
        snackPosition: SnackPosition.TOP);
  }
}
