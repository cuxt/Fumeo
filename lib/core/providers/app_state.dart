import 'package:flutter/material.dart';
import 'package:fumeo/core/theme/theme_manager.dart';

/// 全局应用状态管理类，用于管理应用级别的状态
class AppState with ChangeNotifier {
  // 应用区域设置
  Locale _locale = const Locale('zh', 'CN');
  Locale get locale => _locale;

  // 应用主题管理
  final ThemeManager _themeManager = ThemeManager();
  ThemeManager get themeManager => _themeManager;

  // 导航状态
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  // 设置当前导航索引
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // 切换语言
  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  // 切换语言 (简化方法)
  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      setLocale(const Locale('zh', 'CN'));
    } else {
      setLocale(const Locale('en', 'US'));
    }
  }
}
