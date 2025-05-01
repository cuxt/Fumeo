import 'package:flutter/material.dart';

/// 功能模块数据模型
class FeatureModel {
  /// 功能名称
  final String text;

  /// 路由路径
  final String route;

  /// 功能图标
  final IconData? icon;


  FeatureModel({
    required this.text,
    required this.route,
    this.icon,
  });
}
