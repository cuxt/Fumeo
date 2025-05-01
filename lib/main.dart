import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:fumeo/core/providers/app_state.dart';
import 'package:fumeo/core/router/app_router.dart';
import 'package:fumeo/features/update/providers/update_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

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
        ChangeNotifierProvider(create: (_) => AppState()),
        // 添加 ThemeManager Provider
        ChangeNotifierProvider(
            create: (context) => context.read<AppState>().themeManager),
        // 添加更新控制器
        ChangeNotifierProvider(create: (_) {
          final controller = UpdateController();
          // 初始化更新控制器，启用自动检查
          controller.initialize();
          return controller;
        }),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp.router(
            title: 'Fumeo',
            theme: appState.themeManager.themeData,
            darkTheme: appState.themeManager.darkThemeData,
            themeMode: appState.themeManager.themeMode,
            locale: appState.locale,
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: AppRouter().router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
