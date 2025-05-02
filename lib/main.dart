import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:fumeo/core/providers/app_state.dart';
import 'package:fumeo/core/router/app_router.dart';
import 'package:fumeo/core/theme/theme_controller.dart';
import 'package:fumeo/features/update/providers/update_controller.dart';
import 'package:fumeo/features/todo/providers/todo_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Hive数据库
  await Hive.initFlutter();
  await Hive.openBox('todo_box');
  await Hive.openBox('notes_box');
  await Hive.openBox('settings_box');

  runApp(const FumeoApp());
}

class FumeoApp extends StatelessWidget {
  const FumeoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用MultiProvider提供全局状态
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final controller = UpdateController();
            // 初始化更新控制器，启用自动检查
            controller.initialize();
            return controller;
          },
        ),
      ],
      child: Consumer2<ThemeController, AppState>(
        builder: (context, themeController, appState, _) {
          return MaterialApp.router(
            title: 'Fumeo',
            theme: themeController.lightTheme,
            darkTheme: themeController.darkTheme,
            themeMode: themeController.themeMode,
            routerConfig: AppRouter().router,
            debugShowCheckedModeBanner: false,
            // 添加本地化支持
            locale: const Locale('zh', 'CN'),
            supportedLocales: const [Locale('zh', 'CN')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
