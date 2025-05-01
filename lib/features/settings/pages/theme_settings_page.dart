import 'package:flutter/material.dart';
import 'package:fumeo/core/providers/app_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  _ThemeSettingsPageState createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  late Color _pickerColor;
  final List<Color> _materialColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _pickerColor =
        Provider.of<AppState>(context, listen: false).themeManager.primaryColor;
  }

  void _changeColor(Color color) {
    setState(() => _pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final themeManager = appState.themeManager;

    return Scaffold(
      appBar: AppBar(
        title: Text('主题设置'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主题模式选择
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
                    ListTile(
                      title: const Text('系统默认'),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.system,
                        groupValue: themeManager.themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            themeManager.setThemeMode(value);
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('浅色模式'),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.light,
                        groupValue: themeManager.themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            themeManager.setThemeMode(value);
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('深色模式'),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.dark,
                        groupValue: themeManager.themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            themeManager.setThemeMode(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 主题颜色选择
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
                    // 预设颜色选择
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final color in _materialColors)
                          GestureDetector(
                            onTap: () {
                              themeManager.setPrimaryColor(color);
                              setState(() {
                                _pickerColor = color;
                              });
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: color == themeManager.primaryColor
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: color == themeManager.primaryColor
                                  ? Icon(
                                      Icons.check,
                                      color:
                                          ThemeData.estimateBrightnessForColor(
                                                      color) ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                    )
                                  : null,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 自定义颜色选择按钮
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('选择自定义颜色'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: _pickerColor,
                                  onColorChanged: _changeColor,
                                  pickerAreaHeightPercent: 0.8,
                                  enableAlpha: false,
                                  displayThumbColor: true,
                                  showLabel: true,
                                  paletteType: PaletteType.hsv,
                                  pickerAreaBorderRadius:
                                      const BorderRadius.all(
                                          Radius.circular(10)),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text('取消'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    themeManager.setPrimaryColor(_pickerColor);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text('确认'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('自定义颜色'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 主题预览
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '主题预览',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    // 预览各种组件样式
                    Text('标题文字', style: Theme.of(context).textTheme.titleLarge),
                    Text('正文文字', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('主按钮'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('次按钮'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {},
                          child: const Text('文本按钮'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: '输入框',
                        hintText: '请输入...',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('开关'),
                      value: true,
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: 0.5,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),

            // 重置按钮
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  themeManager.setPrimaryColor(Colors.blue);
                  themeManager.setThemeMode(ThemeMode.system);
                  setState(() {
                    _pickerColor = Colors.blue;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('主题已重置为默认设置')),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('重置为默认主题'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
