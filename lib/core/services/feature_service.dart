import 'package:flutter/material.dart';
import '../../features/home/models/feature_model.dart';

class FeatureService {
  // 单例模式
  static final FeatureService _instance = FeatureService._internal();

  factory FeatureService() {
    return _instance;
  }

  FeatureService._internal();

  // 所有功能模块列表
  final Map<String, List<FeatureModel>> featureMap = {
    '笔记': [
      FeatureModel(
        text: '笔记列表',
        route: '/note',
        icon: Icons.note,
        showInDrawer: true,
        showInHome: true,
      ),
      FeatureModel(
        text: '创建笔记',
        route: '/note/create',
        icon: Icons.add_circle_outline,
        showInDrawer: false, // 只在首页显示
        showInHome: true,
      ),
    ],
    '待办': [
      FeatureModel(
        text: '待办列表',
        route: '/todo',
        icon: Icons.check_circle_outline,
        showInDrawer: true,
        showInHome: true,
      ),
      FeatureModel(
        text: '创建待办',
        route: '/todo/create',
        icon: Icons.add_task,
        showInDrawer: false, // 只在首页显示
        showInHome: true,
      ),
    ],
    '探索': [
      FeatureModel(
        text: '探索',
        route: '/explore',
        icon: Icons.explore,
        showInDrawer: true,
        showInHome: true,
      ),
    ],
    '设置': [
      FeatureModel(
        text: '设置',
        route: '/settings',
        icon: Icons.settings,
        showInDrawer: true,
        showInHome: true,
      ),
      FeatureModel(
        text: '关于',
        route: '/settings/about',
        icon: Icons.info_outline,
        showInDrawer: true,
        showInHome: false, // 只在侧边栏显示
      ),
      FeatureModel(
        text: '主题设置',
        route: '/settings/theme',
        icon: Icons.color_lens,
        showInDrawer: true,
        showInHome: false, // 只在侧边栏显示
      ),
    ],
  };

  // 获取所有功能
  Map<String, List<FeatureModel>> getAllFeatures() {
    return featureMap;
  }

  // 获取侧边栏显示的功能列表
  Map<String, List<FeatureModel>> getDrawerFeatures() {
    final result = <String, List<FeatureModel>>{};

    featureMap.forEach((category, features) {
      final drawerFeatures =
          features.where((feature) => feature.showInDrawer).toList();
      if (drawerFeatures.isNotEmpty) {
        result[category] = drawerFeatures;
      }
    });

    return result;
  }

  // 获取首页显示的功能列表
  Map<String, List<FeatureModel>> getHomeFeatures() {
    final result = <String, List<FeatureModel>>{};

    featureMap.forEach((category, features) {
      final homeFeatures =
          features.where((feature) => feature.showInHome).toList();
      if (homeFeatures.isNotEmpty) {
        result[category] = homeFeatures;
      }
    });

    return result;
  }

  // 根据类别名称获取功能列表
  List<FeatureModel>? getFeaturesByCategory(String category) {
    return featureMap[category];
  }

  // 搜索功能
  Map<String, List<FeatureModel>> searchFeatures(String query) {
    if (query.isEmpty) {
      return featureMap;
    }

    final result = <String, List<FeatureModel>>{};

    featureMap.forEach((category, features) {
      final matchedFeatures = features
          .where((feature) =>
              feature.text.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (matchedFeatures.isNotEmpty) {
        result[category] = matchedFeatures;
      }
    });

    return result;
  }

  // 搜索首页显示的功能
  Map<String, List<FeatureModel>> searchHomeFeatures(String query) {
    if (query.isEmpty) {
      return getHomeFeatures();
    }

    final result = <String, List<FeatureModel>>{};

    featureMap.forEach((category, features) {
      final matchedFeatures = features
          .where((feature) =>
              feature.showInHome &&
              feature.text.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (matchedFeatures.isNotEmpty) {
        result[category] = matchedFeatures;
      }
    });

    return result;
  }
}
