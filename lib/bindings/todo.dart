import 'package:fumeo/controllers/todo.dart';
import 'package:get/get.dart';

class TodoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TodoController());
  }
}