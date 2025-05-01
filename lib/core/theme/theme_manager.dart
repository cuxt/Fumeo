import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  // 主题数据
  ThemeData _lightThemeData = _defaultLightTheme;
  ThemeData _darkThemeData = _defaultDarkTheme;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoaded = false;

  // 主色调
  Color _primaryColor = Colors.blue;

  // 默认主题
  static final ThemeData _defaultLightTheme =
      _createThemeData(Colors.blue, Brightness.light);
  static final ThemeData _defaultDarkTheme =
      _createThemeData(Colors.blue, Brightness.dark);

  // Getters
  ThemeData get themeData => _lightThemeData;
  ThemeData get darkThemeData => _darkThemeData;
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get isLoaded => _isLoaded;

  // 构造函数
  ThemeManager() {
    _loadSavedTheme();
  }

  // 加载保存的主题设置
  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 读取保存的主题模式
      final savedThemeMode = prefs.getString('themeMode');
      if (savedThemeMode != null) {
        if (savedThemeMode == 'light') {
          _themeMode = ThemeMode.light;
        } else if (savedThemeMode == 'dark') {
          _themeMode = ThemeMode.dark;
        } else {
          _themeMode = ThemeMode.system;
        }
      }

      // 读取保存的主题颜色
      final savedColorValue = prefs.getInt('primaryColor');
      if (savedColorValue != null) {
        _primaryColor = Color(savedColorValue);
        _updateThemeColors(_primaryColor);
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('加载主题偏好设置失败: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  // 保存主题设置
  Future<void> _saveThemePreferences() async {
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
      await prefs.setString('themeMode', themeModeString);

      // 保存主色调
      await prefs.setInt('primaryColor', _primaryColor.toARGB32());
    } catch (e) {
      debugPrint('保存主题偏好设置失败: $e');
    }
  }

  // 设置主题颜色
  void setPrimaryColor(Color color) {
    if (_primaryColor != color) {
      _primaryColor = color;
      _updateThemeColors(color);
      _saveThemePreferences();
      notifyListeners();
    }
  }

  // 更新主题颜色
  void _updateThemeColors(Color primaryColor) {
    _lightThemeData = _createThemeData(primaryColor, Brightness.light);
    _darkThemeData = _createThemeData(primaryColor, Brightness.dark);
  }

  // 设置主题模式
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveThemePreferences();
      notifyListeners();
    }
  }

  // 切换主题模式
  void toggleThemeMode() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  // 从系统获取主色调
  void useSystemPrimaryColor() {
    // 这里可以尝试获取系统主色调
    // 在Flutter中，目前没有直接的API可以获取系统主色调
    // 可以考虑使用默认的Material主色调
    setPrimaryColor(Colors.blue);
  }

  // 创建主题数据
  static ThemeData _createThemeData(Color primaryColor, Brightness brightness) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      brightness: brightness,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? colorScheme.surface
          : colorScheme.surface,

      // 卡片主题
      cardTheme: CardTheme(
        color: brightness == Brightness.light
            ? Colors.white
            : colorScheme.surfaceContainerHighest,
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
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // AppBar主题
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.light
            ? colorScheme.surface
            : colorScheme.surfaceContainerHighest,
        foregroundColor: brightness == Brightness.light
            ? colorScheme.onSurface
            : colorScheme.onSurfaceVariant,
        elevation: 0,
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: brightness == Brightness.light
            ? colorScheme.surface
            : colorScheme.surfaceContainerHighest,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor:
            colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),

      // 文本主题
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: brightness == Brightness.light
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: brightness == Brightness.light
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: brightness == Brightness.light
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: brightness == Brightness.light
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant,
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: brightness == Brightness.light
                ? colorScheme.outline
                : colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: brightness == Brightness.light
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
      ),

      // 浮动按钮主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // 切换开关主题
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return brightness == Brightness.light
              ? Colors.grey.shade400
              : Colors.grey.shade600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.5);
          }
          return brightness == Brightness.light
              ? Colors.grey.shade300
              : Colors.grey.shade700;
        }),
      ),

      // 分割线颜色
      dividerTheme: DividerThemeData(
        color: brightness == Brightness.light
            ? Colors.grey.shade300
            : Colors.grey.shade700,
        thickness: 1,
      ),
    );
  }
}
