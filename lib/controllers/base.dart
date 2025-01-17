import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class BaseController extends GetxController {
  var isLoading = false.obs;

  void showLoading() => isLoading.value = true;

  void hideLoading() => isLoading.value = false;

  // PackageInfo
  var packageInfo = Rx<PackageInfo?>(null);

  @override
  Future<void> onInit() async {
    super.onInit();
    packageInfo.value = await PackageInfo.fromPlatform();
  }
}
