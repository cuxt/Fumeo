import 'package:flutter/material.dart';
import 'package:fumeo/controllers/todo.dart';
import 'package:fumeo/pages/nav/side_nav_bar.dart';
import 'package:fumeo/pages/todo/todo_bottom_sheet.dart';
import 'package:fumeo/pages/todo/todo_tile.dart';
import 'package:get/get.dart';

class TodoView extends GetView<TodoController> {
  const TodoView({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Icon(Icons.menu),
            ),
          ),
        ),
      ),
      drawer: const SideNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.bottomSheet(
          TodoBottomSheet(
            controller: textController,
            onSave: () {
              controller.addTodo(textController.text);
              textController.clear();
              Get.back();
            },
            onCancel: () => Get.back(),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: Obx(
            () => ListView.builder(
          itemCount: controller.todoList.length,
          itemBuilder: (context, index) {
            final todo = controller.todoList[index];
            return TodoTile(
              taskName: todo[0],
              taskCompleted: todo[1],
              onChanged: (_) => controller.toggleTodo(index),
              deleteTask: (_) => controller.deleteTodo(index),
            );
          },
        ),
      ),
    );
  }
}
