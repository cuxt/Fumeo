import 'package:fumeo/controllers/side_nav.dart';
import 'package:fumeo/controllers/theme.dart';
import 'package:fumeo/controllers/update.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
    Get.put(SideNavController(), permanent: true);
    // Get.put(UpdateController(), permanent: true);
    Get.lazyPut(() => UpdateController());
  }
}
