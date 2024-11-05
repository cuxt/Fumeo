import 'package:flutter/material.dart';
import 'package:fumeo/config.dart';
import 'package:fumeo/pages/chat/chat_page.dart';
import 'package:fumeo/pages/chat/setting/settings.dart';
import 'package:fumeo/pages/home/home_page.dart';
import 'package:fumeo/pages/nav/nav_page.dart';
import 'package:fumeo/pages/settings_page.dart';
import 'package:fumeo/pages/todo/todo_page.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

Future<void> main() async {
  // init hive_ce
  await Hive.initFlutter();
  // open box
  await Hive.openBox('todo_box');
  WidgetsFlutterBinding.ensureInitialized();

  Config.initialize().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const NavPage(),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      routes: {
        'home': (context) => const HomePage(),
        'chat': (context) => const ChatPage(),
        'settings': (context) => const SettingsPage(),
        'chat_settings': (context) => const ChatSettingsPage(),
        'todo': (context) => const TodoPage(),
      },
    );
  }
}
