import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fumeo/core/providers/app_state.dart';
import 'widgets/todo_item_tile.dart';
import 'widgets/todo_stats_card.dart';
import 'widgets/todo_filter_bar.dart';
import 'screens/add_todo_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String _filterMode = 'all'; // 'all', 'active', 'completed'

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办事项'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: _refreshTodos,
          ),
          // 清除已完成按钮
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: '清除已完成',
            onPressed: () => _showClearCompletedDialog(context),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  void _refreshTodos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 通过AppState获取TodoProvider进行刷新
      final todoProvider =
          Provider.of<AppState>(context, listen: false).todoProvider;
      await todoProvider.refreshTodos();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBody() {
    // 使用Consumer获取AppState并访问其todoProvider
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final todoProvider = appState.todoProvider;

        if (todoProvider.isLoading || _isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allTodos = todoProvider.items;
        final stats = todoProvider.getStats();

        // 根据筛选条件过滤待办事项
        final todos = _filterTodos(allTodos);

        return Column(
          children: [
            // 统计卡片
            TodoStatsCard(stats: stats),

            // 筛选栏
            TodoFilterBar(
              currentFilter: _filterMode,
              onFilterChanged: (mode) {
                setState(() {
                  _filterMode = mode;
                });
              },
            ),

            // 待办事项列表
            Expanded(
              child:
                  todos.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: todos.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return TodoItemTile(
                            item: todo,
                            onToggle: todoProvider.toggleTodoStatus,
                            onDelete:
                                (id) => _showDeleteConfirmDialog(context, id),
                            onEdit: todoProvider.editTodo,
                          );
                        },
                      ),
            ),
          ],
        );
      },
    );
  }

  List<dynamic> _filterTodos(List todos) {
    switch (_filterMode) {
      case 'active':
        return todos.where((todo) => !todo.completed).toList();
      case 'completed':
        return todos.where((todo) => todo.completed).toList();
      case 'all':
      default:
        return todos;
    }
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_filterMode) {
      case 'active':
        message = '没有待办事项';
        icon = Icons.check_circle;
        break;
      case 'completed':
        message = '没有已完成的事项';
        icon = Icons.assignment_turned_in;
        break;
      case 'all':
      default:
        message = '暂无待办事项，请点击右下角按钮添加';
        icon = Icons.assignment;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (_filterMode == 'all') ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddTodoDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('添加待办事项'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      onPressed: _navigateToAddTodoScreen,
      child: const Icon(Icons.add),
    );
  }

  void _navigateToAddTodoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddTodoScreen(
              onAdd: (title) {
                _addTodo(title);
              },
            ),
      ),
    );
  }

  void _addTodo(String title) {
    if (title.isNotEmpty) {
      // 通过AppState获取TodoProvider实例
      final todoProvider =
          Provider.of<AppState>(context, listen: false).todoProvider;

      // 添加待办事项（Provider内部会处理加载状态和通知刷新）
      todoProvider.addTodo(title);

      // 添加后主动刷新列表，确保新添加的条目立即显示
      _refreshTodos();

      // 显示添加成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('添加成功'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 这个方法保留用于兼容从空状态页的添加按钮
  void _showAddTodoDialog(BuildContext context) {
    _navigateToAddTodoScreen();
  }

  void _showDeleteConfirmDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除这个待办事项吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  // 通过AppState获取TodoProvider实例
                  Provider.of<AppState>(
                    context,
                    listen: false,
                  ).todoProvider.deleteTodo(id);
                  Navigator.pop(context);

                  // 显示删除成功提示
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('删除成功'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('删除'),
              ),
            ],
          ),
    );
  }

  void _showClearCompletedDialog(BuildContext context) {
    // 通过AppState获取TodoProvider实例
    final todoProvider =
        Provider.of<AppState>(context, listen: false).todoProvider;
    final stats = todoProvider.getStats();

    // 如果没有已完成的待办事项，显示提示
    if (stats['completed'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('没有已完成的待办事项'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('清除已完成'),
            content: Text('确定要清除全部 ${stats['completed']} 个已完成的待办事项吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  todoProvider.clearCompletedTodos();
                  Navigator.pop(context);

                  // 显示清除成功提示
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('已清除所有已完成的待办事项'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('清除'),
              ),
            ],
          ),
    );
  }
}
