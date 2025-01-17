import 'package:fumeo/controllers/explore.dart';
import 'package:get/get.dart';

class ExploreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExploreController());
  }
}
