import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';

  // 主题设置
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = Colors.blue;
  bool _isLoaded = false;

  // 缓存的主题数据
  late ThemeData _lightTheme;
  late ThemeData _darkTheme;

  // 构造函数 - 初始化主题数据
  ThemeController() {
    _updateThemeData();
    _loadSavedTheme();
  }

  // 加载已保存的主题设置
  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 加载主题模式
      final savedThemeMode = prefs.getString(_themeModeKey);
      if (savedThemeMode != null) {
        switch (savedThemeMode) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          default:
            _themeMode = ThemeMode.system;
        }
      }

      // 加载主题颜色
      final savedColorValue = prefs.getInt(_primaryColorKey);
      if (savedColorValue != null) {
        _primaryColor = Color(savedColorValue);
        _updateThemeData();
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('加载主题设置失败: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  // 保存主题设置到持久存储
  Future<void> _saveThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 保存主题模式
      String themeModeString;
      switch (_themeMode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        default:
          themeModeString = 'system';
      }
      await prefs.setString(_themeModeKey, themeModeString);

      // 保存主题颜色
      await prefs.setInt(_primaryColorKey, _primaryColor.toARGB32());
    } catch (e) {
      debugPrint('保存主题设置失败: $e');
    }
  }

  // 更新主题数据
  void _updateThemeData() {
    _lightTheme = _createThemeData(brightness: Brightness.light);
    _darkTheme = _createThemeData(brightness: Brightness.dark);
  }

  // 创建主题数据
  ThemeData _createThemeData({required Brightness brightness}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: brightness,
    );

    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,

      // 基础颜色
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: colorScheme.surface,

      // AppBar主题
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? colorScheme.surfaceContainerHighest : colorScheme.primary,
        foregroundColor: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
        elevation: 0,
      ),

      // 卡片主题
      cardTheme: CardTheme(
        color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:
            isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant
            .withValues(alpha: 153), // 0.6 * 255 = 153
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHighest
                .withValues(alpha: 77) // 0.3 * 255 = 76.5 ≈ 77
            : colorScheme.surfaceContainerLowest.withValues(alpha: 77),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
      ),

      // 开关主题
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return isDark ? Colors.grey.shade600 : Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary
                .withValues(alpha: 128); // 0.5 * 255 = 127.5 ≈ 128
          }
          return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
        }),
      ),

      // 分割线
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        thickness: 1,
      ),
    );
  }

  // 公开的getter
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;
  bool get isLoaded => _isLoaded;

  // 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _saveThemeSettings();
      notifyListeners();
    }
  }

  // 设置主题颜色
  Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor != color) {
      _primaryColor = color;
      _updateThemeData();
      await _saveThemeSettings();
      notifyListeners();
    }
  }

  // 切换亮暗主题
  Future<void> toggleThemeMode() async {
    ThemeMode newMode;

    if (_themeMode == ThemeMode.dark) {
      newMode = ThemeMode.light;
    } else {
      newMode = ThemeMode.dark;
    }

    await setThemeMode(newMode);
  }

  // 重置为默认主题
  Future<void> resetToDefault() async {
    await setPrimaryColor(Colors.blue);
    await setThemeMode(ThemeMode.system);
  }
}
