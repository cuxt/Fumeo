import 'package:fumeo/bindings/about.dart';
import 'package:fumeo/bindings/explore.dart';
import 'package:fumeo/bindings/note.dart';
import 'package:fumeo/bindings/todo.dart';
import 'package:fumeo/pages/about/about.dart';
import 'package:fumeo/pages/explore/explore.dart';
import 'package:fumeo/pages/note/note.dart';
import 'package:fumeo/pages/settings/settings.dart';
import 'package:fumeo/pages/todo/todo.dart';
import 'package:get/get.dart';

abstract class Routes {
  // 路由常量
  static const note = '/note';
  static const todo = '/todo';
  static const explore = '/explore';
  static const settings = '/settings';
  static const about = '/about';

  // 路由页面配置
  static final routes = [
    GetPage(name: note, page: () => NoteView(), binding: NoteBinding()),
    GetPage(
      name: explore,
      page: () => const ExploreView(),
      binding: ExploreBinding(),
    ),
    GetPage(
      name: todo,
      page: () => const TodoView(),
      binding: TodoBinding(),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsView(),
    ),
    GetPage(
        name: about, page: () => const AboutView(), binding: AboutBinding()),
  ];
}
