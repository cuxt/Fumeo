import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fumeo/features/home/home_screen.dart';
import 'package:fumeo/features/note/note_screen.dart';
import 'package:fumeo/features/todo/todo_screen.dart';
import 'package:fumeo/features/explore/explore_screen.dart';
import 'package:fumeo/features/settings/settings_screen.dart';
import 'package:fumeo/features/about/about_screen.dart';
import 'package:fumeo/features/settings/pages/theme_settings_page.dart';

class AppRouter {
  // 主要路由名称
  static const String home = '/';
  static const String note = '/note';
  static const String todo = '/todo';
  static const String explore = '/explore';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String themeSettings = '/settings/theme';

  late final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: home,
    routes: [
      // 主路由 - 主页
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // 子路由 - 笔记
          GoRoute(
            path: 'note',
            name: 'note',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const NoteScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          // 子路由 - 待办事项
          GoRoute(
            path: 'todo',
            name: 'todo',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const TodoScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          // 子路由 - 探索
          GoRoute(
            path: 'explore',
            name: 'explore',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const ExploreScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          // 子路由 - 设置
          GoRoute(
            path: 'settings',
            name: 'settings',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            routes: [
              // 嵌套子路由 - 关于
              GoRoute(
                path: 'about',
                name: 'about',
                pageBuilder: (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: const AboutScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ),
              // 嵌套子路由 - 主题设置
              GoRoute(
                path: 'theme',
                name: 'theme',
                pageBuilder: (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: const ThemeSettingsPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('未找到路由: ${state.uri.path}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}
