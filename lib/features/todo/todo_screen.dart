import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/todo_provider.dart';
import 'widgets/todo_item_tile.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('待办事项'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, _) {
        final todos = todoProvider.items;

        if (todos.isEmpty) {
          return const Center(
            child: Text('暂无待办事项，请点击右下角按钮添加', style: TextStyle(fontSize: 16)),
          );
        }

        return ListView.separated(
          itemCount: todos.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final todo = todos[index];
            return TodoItemTile(
              item: todo,
              onToggle: todoProvider.toggleTodoStatus,
              onDelete: (id) => _showDeleteConfirmDialog(context, id),
              onEdit: todoProvider.editTodo,
            );
          },
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      onPressed: () => _showAddTodoDialog(context),
      child: const Icon(Icons.add),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    _controller.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加待办事项'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入待办事项内容',
          ),
          onSubmitted: (_) {
            if (_controller.text.isNotEmpty) {
              _addTodo(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => _addTodo(context),
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _addTodo(BuildContext context) {
    if (_controller.text.isNotEmpty) {
      Provider.of<TodoProvider>(context, listen: false)
          .addTodo(_controller.text);
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个待办事项吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TodoProvider>(context, listen: false).deleteTodo(id);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
