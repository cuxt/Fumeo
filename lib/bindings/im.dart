import 'package:fumeo/controllers/im.dart';
import 'package:get/get.dart';

class IMBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IMController());
  }
}
