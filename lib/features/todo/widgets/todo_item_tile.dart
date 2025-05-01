import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import 'package:intl/intl.dart';

class TodoItemTile extends StatelessWidget {
  final TodoItem item;
  final Function(String) onToggle;
  final Function(String) onDelete;
  final Function(String, String) onEdit;

  const TodoItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除这个待办事项吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        onDelete(item.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color:
                item.completed ? Colors.green.shade200 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: InkWell(
          onLongPress: () => _showEditDialog(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: ListTile(
              leading: _buildCheckbox(context),
              title: Text(
                item.title,
                style: TextStyle(
                  decoration:
                      item.completed ? TextDecoration.lineThrough : null,
                  color: item.completed ? Colors.grey : null,
                  fontWeight:
                      item.completed ? FontWeight.normal : FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '创建于 ${_formatDate(item.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: '编辑',
                    onPressed: () => _showEditDialog(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    tooltip: '删除',
                    onPressed: () => onDelete(item.id),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return InkWell(
      onTap: () => onToggle(item.id),
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: item.completed
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade400,
            width: 2,
          ),
          color: item.completed
              ? Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 26) // 0.1 * 255 = 25.5 ≈ 26
              : Colors.transparent,
        ),
        child: Icon(
          Icons.check,
          size: 16,
          color: item.completed
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd HH:mm').format(date);
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: item.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑待办事项'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '待办事项内容',
                border: OutlineInputBorder(),
                hintText: '输入待办事项内容',
              ),
              autofocus: true,
              maxLength: 100,
            ),
            const SizedBox(height: 8),
            Text(
              '创建于: ${_formatDate(item.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (item.completed)
              Text(
                '状态: 已完成',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                ),
              )
            else
              Text(
                '状态: 待完成',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[600],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onEdit(item.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
