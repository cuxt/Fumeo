import 'package:fumeo/controllers/base.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class TodoController extends BaseController {
  var todoList = [].obs;
  final _todoBox = Hive.box('todo_box');

  @override
  Future<void> onInit() async {
    await super.onInit();
    if (_todoBox.get('TODOLIST') == null) {
      createInitialData();
    } else {
      loadData();
    }
  }

  void createInitialData() {
    todoList.value = [
      ['数据结构', false],
      ['计算机组成原理', false],
      ['操作系统', false],
      ['计算机网络', false],
    ];
    updateDataBase();
  }

  void loadData() {
    todoList.value = _todoBox.get('TODOLIST');
  }

  void updateDataBase() {
    _todoBox.put('TODOLIST', todoList);
  }

  void addTodo(String task) {
    if(task.isEmpty) return;
    todoList.add([task, false]);
    updateDataBase();
  }

  void toggleTodo(int index) {
    todoList[index][1] = !todoList[index][1];
    todoList.refresh();
    updateDataBase();
  }

  void deleteTodo(int index) {
    todoList.removeAt(index);
    updateDataBase();
  }
}
