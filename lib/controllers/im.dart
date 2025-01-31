import 'package:fumeo/pages/im/services/im.dart';
import 'package:get/get.dart';

class IMController extends GetxController {
  final IMService _imService = Get.find();

  Future<void> login(String userID, String userSig) async {
    bool success = await _imService.login(userID, userSig);
    if (success) {
      Get.offAllNamed('/im.dart/login');
    } else {
      Get.snackbar('错误', '登录失败，请检查账号信息');
    }
  }
}
