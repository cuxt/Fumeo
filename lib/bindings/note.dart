import 'package:fumeo/controllers/note.dart';
import 'package:get/get.dart';

class NoteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NoteController());
  }
}
