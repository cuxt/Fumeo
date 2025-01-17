import 'package:fumeo/pages/update/github_service.dart';
import 'package:fumeo/pages/update/update.dart';
import 'package:get/get.dart';

class UpdateController extends GetxController {
  var isChecking = false.obs;

  Future<void> checkUpdate() async {
    if (isChecking.value) return;

    isChecking.value = true;
    try {
      final updateInfo = await GithubService.checkUpdate();
      if (updateInfo['hasUpdate']) {
        Get.dialog(
          UpdateDialog(updateInfo: updateInfo),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          '检查更新',
          '已是最新版本',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        '检查更新',
        '检查更新失败: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isChecking.value = false;
    }
  }
}
