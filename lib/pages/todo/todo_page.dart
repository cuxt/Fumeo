import 'package:flutter/material.dart';
import 'package:fumeo/data/database.dart';
import 'package:fumeo/pages/nav/side_nav_bar.dart';
import 'package:fumeo/pages/todo/todo_bottom_sheet.dart';
import 'package:fumeo/pages/todo/todo_tile.dart';
import 'package:fumeo/util.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _todoBox = Hive.box('todo_box');
  TodoDataBase db = TodoDataBase();

  @override
  void initState() {
    if (_todoBox.get('TODOLIST') == null) {
      // 第一次启动
      db.createInitialData();
    } else {
      db.loadData();
    }

    super.initState();
  }

  final _controller = TextEditingController();

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.todoList[index][1] = !db.todoList[index][1];
    });
    db.updateDataBase();
  }

  saveNewTask() {
    if (_controller.text.isEmpty) {
      Util.showAwesomebar(context, 'warning', 'Warning', '内容不能为空');

      return;
    }

    setState(() {
      db.todoList.add([_controller.text, false]);
      _controller.clear();
    });

    Navigator.of(context).pop();
    db.updateDataBase();
  }

  void createNewTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            width: double.infinity,
            child: TodoBottomSheet(
              controller: _controller,
              onSave: saveNewTask,
              onCancel: () => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      db.todoList.removeAt(index);
    });
    db.updateDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('小记'),
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Icon(Icons.menu),
              ),
            ),
          ),
        ),
        drawer: const SideNavBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewTask,
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: db.todoList.length,
          itemBuilder: (context, index) {
            return TodoTile(
              taskName: db.todoList[index][0],
              taskCompleted: db.todoList[index][1],
              onChanged: (value) => checkBoxChanged(value, index),
              deleteTask: (context) => deleteTask(index),
            );
          },
        ));
  }
}
