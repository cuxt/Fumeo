import 'package:fumeo/bindings/about.dart';
import 'package:fumeo/bindings/app.dart';
import 'package:fumeo/bindings/explore.dart';
import 'package:fumeo/bindings/note.dart';
import 'package:fumeo/bindings/todo.dart';
import 'package:fumeo/pages/about/about.dart';
import 'package:fumeo/pages/explore/explore.dart';
import 'package:fumeo/pages/mine/mine.dart';
import 'package:fumeo/pages/nav/nav.dart';
import 'package:fumeo/pages/note/note_list.dart';
import 'package:fumeo/pages/settings/settings.dart';
import 'package:fumeo/pages/todo/todo.dart';
import 'package:get/get.dart';

abstract class Routes {
  // 路由常量
  static const nav = '/';
  static const home = '/home';
  static const todo = '/todo';
  static const explore = '/explore';
  static const mine = '/mine';
  static const settings = '/settings';
  static const about = '/about';
  static const note = '/note';

  // 路由页面配置
  static final routes = [
    GetPage(
        name: nav,
        page: () => NavView(),
        binding: AppBinding(),
        bindings: [TodoBinding(), ExploreBinding()]),
    GetPage(
      name: todo,
      page: () => const TodoView(),
      binding: TodoBinding(),
    ),
    GetPage(
        name: about, page: () => const AboutView(), binding: AboutBinding()),
    GetPage(
      name: settings,
      page: () => const SettingsView(),
    ),
    GetPage(
      name: explore,
      page: () => const ExploreView(),
      binding: ExploreBinding(),
    ),
    GetPage(
      name: mine,
      page: () => const MineView(),
    ),
    GetPage(name: note, page: () => NoteListView(), binding: NoteBinding())
  ];
}
