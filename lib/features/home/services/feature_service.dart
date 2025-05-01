import 'package:flutter/material.dart';
import '../models/feature_model.dart';

/// 功能服务类，用于集中管理应用中的所有功能模块
class FeatureService {
  /// 获取功能映射表，按类别组织功能列表
  static Map<String, List<FeatureModel>> getFeatureMap() {
    return {
      '笔记管理': [
        FeatureModel(
          text: '笔记列表',
          icon: Icons.note_alt_outlined,
          route: '/notes',
        ),
        FeatureModel(
          text: '笔记分类',
          icon: Icons.category_outlined,
          route: '/notes/categories',
        ),
        FeatureModel(
          text: '回收站',
          icon: Icons.delete_outline,
          route: '/notes/trash',
        ),
      ],
      '任务管理': [
        FeatureModel(
          text: '任务清单',
          icon: Icons.task_alt_outlined,
          route: '/tasks',
        ),
        FeatureModel(
          text: '创建任务',
          icon: Icons.add_task_outlined,
          route: '/tasks/create',
        ),
        FeatureModel(
          text: '日历视图',
          icon: Icons.calendar_today_outlined,
          route: '/tasks/calendar',
        ),
        FeatureModel(
          text: '统计分析',
          icon: Icons.bar_chart_outlined,
          route: '/tasks/stats',
        ),
      ],
      '设置与工具': [
        FeatureModel(
          text: '应用设置',
          icon: Icons.settings_outlined,
          route: '/settings',
        ),
        FeatureModel(
          text: '数据备份',
          icon: Icons.backup_outlined,
          route: '/settings/backup',
        ),
        FeatureModel(
          text: '主题设置',
          icon: Icons.color_lens_outlined,
          route: '/settings/theme',
        ),
        FeatureModel(
          text: '关于应用',
          icon: Icons.info_outline,
          route: '/about',
        ),
      ],
    };
  }
}
