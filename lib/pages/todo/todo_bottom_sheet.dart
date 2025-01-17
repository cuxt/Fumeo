import 'package:flutter/material.dart';
import 'package:fumeo/pages/components/fm_button.dart';

class TodoBottomSheet extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const TodoBottomSheet({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(
              maxHeight: 500,
            ),
            child: SingleChildScrollView(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add Task',
                ),
                maxLines: null, // 允许多行输入
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FmButton(text: "取消", onPressed: onCancel),
                const SizedBox(width: 8),
                FmButton(text: "保存", onPressed: onSave),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
