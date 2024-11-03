import 'package:flutter/material.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const NavPage(),
      theme: ThemeData(primaryColor:  const Color(0xfffa9e51)),
      routes: {
        'home': (context) => const HomePage(),
        'settings': (context) => const SettingsPage(),
        'todo': (context) => const TodoPage(),
      },
    );
  }
}
