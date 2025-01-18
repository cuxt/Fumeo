import 'package:fumeo/controllers/nav.dart';
import 'package:fumeo/controllers/note.dart';
import 'package:fumeo/controllers/theme.dart';
import 'package:fumeo/controllers/update.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NavController(), permanent: true);
    Get.put(ThemeController(), permanent: true);
    Get.lazyPut(() => UpdateController());
    Get.lazyPut(() => NoteController());
  }
}
