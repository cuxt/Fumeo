import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fumeo/core/theme/theme_controller.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  // 主题颜色选择
  late Color _selectedColor;
  // 主题模式选择
  late ThemeMode _selectedThemeMode;
  bool _hasUnsavedChanges = false;

  // 浅色/深色预览切换
  ThemeMode _previewThemeMode = ThemeMode.light;

  final List<Color> _presetColors = [
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.yellow,
    Colors.lime,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
    Colors.deepPurple,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    final themeController = context.read<ThemeController>();
    _selectedColor = themeController.primaryColor;
    _selectedThemeMode = themeController.themeMode;
    // 根据当前主题模式初始化预览模式
    _previewThemeMode = themeController.themeMode == ThemeMode.dark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  // 临时更新主题颜色（仅预览）
  void _updatePreviewColor(Color color) {
    setState(() {
      _selectedColor = color;
      _hasUnsavedChanges = true;
    });
  }

  // 临时更新主题模式（仅预览）
  void _updatePreviewThemeMode(ThemeMode mode) {
    setState(() {
      _selectedThemeMode = mode;
      _hasUnsavedChanges = true;
    });
  }

  // 保存主题设置
  Future<void> _applyThemeChanges() async {
    final themeController = context.read<ThemeController>();

    // 应用颜色设置
    await themeController.setPrimaryColor(_selectedColor);

    // 应用主题模式设置
    await themeController.setThemeMode(_selectedThemeMode);

    if (mounted) {
      setState(() {
        _hasUnsavedChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('主题设置已应用')),
      );
    }
  }

  // 重置主题设置
  void _resetThemeSettings() {
    setState(() {
      _selectedColor = Colors.blue;
      _selectedThemeMode = ThemeMode.system;
      _hasUnsavedChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    final currentThemeBrightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
        actions: [
          if (_hasUnsavedChanges)
            TextButton.icon(
              onPressed: _applyThemeChanges,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('应用', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 主题模式选择区
                  Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '主题模式',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          // 主题模式选择器
                          RadioListTile<ThemeMode>(
                            title: const Text('跟随系统'),
                            subtitle: const Text('自动适应系统设置'),
                            secondary: const Icon(Icons.brightness_auto),
                            value: ThemeMode.system,
                            groupValue: _selectedThemeMode,
                            onChanged: (value) {
                              if (value != null) {
                                _updatePreviewThemeMode(value);
                              }
                            },
                          ),

                          RadioListTile<ThemeMode>(
                            title: const Text('浅色模式'),
                            subtitle: const Text('始终使用浅色主题'),
                            secondary: const Icon(Icons.light_mode),
                            value: ThemeMode.light,
                            groupValue: _selectedThemeMode,
                            onChanged: (value) {
                              if (value != null) {
                                _updatePreviewThemeMode(value);
                              }
                            },
                          ),

                          RadioListTile<ThemeMode>(
                            title: const Text('深色模式'),
                            subtitle: const Text('始终使用深色主题'),
                            secondary: const Icon(Icons.dark_mode),
                            value: ThemeMode.dark,
                            groupValue: _selectedThemeMode,
                            onChanged: (value) {
                              if (value != null) {
                                _updatePreviewThemeMode(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 主题颜色选择区
                  Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '主题颜色',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          // 预设颜色选择器
                          LayoutBuilder(builder: (context, constraints) {
                            final double availableWidth = constraints.maxWidth;
                            final int itemsPerRow =
                                (availableWidth / 60).floor(); // 每行显示的项目数
                            final double itemWidth =
                                (availableWidth - (itemsPerRow - 1) * 12) /
                                    itemsPerRow;

                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                for (final color in _presetColors)
                                  GestureDetector(
                                    onTap: () => _updatePreviewColor(color),
                                    child: Container(
                                      width: itemWidth,
                                      height: itemWidth,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _selectedColor == color
                                              ? (currentThemeBrightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black87)
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(26),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: _selectedColor == color
                                          ? Icon(
                                              Icons.check,
                                              color: ThemeData
                                                          .estimateBrightnessForColor(
                                                              color) ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              size: 24,
                                            )
                                          : null,
                                    ),
                                  ),

                                // 自定义颜色选择器按钮
                                GestureDetector(
                                  onTap: () => _showColorPickerDialog(),
                                  child: Container(
                                    width: itemWidth,
                                    height: itemWidth,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                    child: const Icon(Icons.add),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // 主题预览区
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '预览',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Spacer(),
                              // 预览模式切换
                              SegmentedButton<ThemeMode>(
                                segments: const [
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.light,
                                    icon: Icon(Icons.light_mode, size: 16),
                                    label: Text('浅色'),
                                  ),
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.dark,
                                    icon: Icon(Icons.dark_mode, size: 16),
                                    label: Text('深色'),
                                  ),
                                ],
                                selected: {_previewThemeMode},
                                onSelectionChanged: (Set<ThemeMode> modes) {
                                  setState(() {
                                    _previewThemeMode = modes.first;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 预览样本
                          _buildThemePreview(context),
                        ],
                      ),
                    ),
                  ),

                  // 操作按钮
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 重置按钮
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _resetThemeSettings,
                          icon: const Icon(Icons.refresh),
                          label: const Text('重置为默认'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 应用按钮
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              _hasUnsavedChanges ? _applyThemeChanges : null,
                          icon: const Icon(Icons.check),
                          label: const Text('应用更改'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示颜色选择器对话框
  void _showColorPickerDialog() {
    // 创建一个状态变量来存储当前选择的颜色
    Color pickerColor = _selectedColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('选择自定义颜色'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  // 在对话框内更新颜色
                  setState(() {
                    pickerColor = color;
                  });
                },
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false,
                displayThumbColor: true,
                labelTypes: const [
                  ColorLabelType.hex,
                  ColorLabelType.rgb
                ], // 显示颜色代码和RGB值
                paletteType: PaletteType.hsv,
                pickerAreaBorderRadius:
                    const BorderRadius.all(Radius.circular(10)),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () {
                  // 确认后，将选择的颜色应用到主题
                  _updatePreviewColor(pickerColor);
                  Navigator.of(context).pop();
                },
                child: const Text('确定'),
              ),
            ],
          );
        });
      },
    );
  }

  // 构建主题预览组件
  Widget _buildThemePreview(BuildContext context) {
    // 创建预览主题数据
    final previewBrightness = _previewThemeMode == ThemeMode.dark
        ? Brightness.dark
        : Brightness.light;

    final previewColorScheme = ColorScheme.fromSeed(
      seedColor: _selectedColor,
      brightness: previewBrightness,
    );

    // 根据当前选择的颜色和预览亮度创建预览主题
    final ThemeData previewTheme;
    if (previewBrightness == Brightness.light) {
      previewTheme = ThemeData.light().copyWith(
        colorScheme: previewColorScheme,
        primaryColor: _selectedColor,
        // 确保预览区域背景色正确显示
        scaffoldBackgroundColor: previewColorScheme.surface,
        cardColor: Colors.white,
      );
    } else {
      previewTheme = ThemeData.dark().copyWith(
        colorScheme: previewColorScheme,
        primaryColor: _selectedColor,
        // 确保预览区域背景色正确显示
        scaffoldBackgroundColor: previewColorScheme.surface,
        cardColor: previewColorScheme.surfaceContainerHigh,
      );
    }

    return Theme(
      data: previewTheme,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: previewTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: previewTheme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('标题文本', style: previewTheme.textTheme.titleLarge),
            Text('正文内容示例', style: previewTheme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(
                  onPressed: () {},
                  child: const Text('主按钮'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('次要按钮'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('开关示例'),
              value: true,
              onChanged: (_) {},
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: '输入框',
                hintText: '请输入内容...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
