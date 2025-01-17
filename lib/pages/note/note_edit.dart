import 'package:flutter/material.dart';
import 'package:fumeo/controllers/note.dart';
import 'package:fumeo/pages/note/models/note.dart';
import 'package:get/get.dart';

// 笔记编辑页面
class NoteEditView extends StatefulWidget {
  final Note? note;

  const NoteEditView({super.key, this.note});

  @override
  NoteEditViewState createState() => NoteEditViewState();
}

class NoteEditViewState extends State<NoteEditView> {
  final NoteController noteController = Get.find();
  late TextEditingController titleController;
  late TextEditingController contentController;
  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    titleController = TextEditingController(text: widget.note?.title ?? '');
    contentController = TextEditingController(text: widget.note?.content ?? '');

    // 添加编辑监听
    titleController.addListener(_onTextChanged);
    contentController.addListener(_onTextChanged);
  }

  // 文本改变监听器
  void _onTextChanged() {
    if (!_isEdited) {
      setState(() {
        _isEdited = true;
      });
    }
  }

  @override
  void dispose() {
    titleController.removeListener(_onTextChanged);
    contentController.removeListener(_onTextChanged);
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  // 保存笔记
  Future<void> saveNote() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      Get.snackbar(
        '错误',
        '标题和内容不能为空',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    try {
      if (widget.note == null) {
        await noteController.addNote(
          titleController.text.trim(),
          contentController.text.trim(),
        );
      } else {
        await noteController.updateNote(
          widget.note!.id,
          titleController.text.trim(),
          contentController.text.trim(),
        );
      }
      Get.back();
    } catch (e) {
      Get.snackbar(
        '错误',
        '保存失败: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  // 显示退出确认对话框
  Future<bool> _showExitDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('确认退出'),
        content: Text('您有未保存的更改，确定要退出吗？'),
        actions: [
          TextButton(
            child: Text('取消'),
            onPressed: () => Get.back(result: false),
          ),
          TextButton(
            child: Text('确定'),
            onPressed: () => Get.back(result: true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (_isEdited) {
          final shouldPop = await _showExitDialog();
          if (shouldPop) {
            Get.back();
          }
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? '新建笔记' : '编辑笔记'),
          actions: [
            // 保存按钮
            IconButton(
              icon: Icon(Icons.check),
              onPressed: saveNote,
            ),
          ],
        ),
        body: _buildEditorBody(),
      ),
    );
  }

  // 构建编辑器主体
  Widget _buildEditorBody() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 标题输入框
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: '标题',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
              counterText: '${titleController.text.length}/50',
            ),
            maxLength: 50,
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16.0),
          // 内容输入框
          Expanded(
            child: TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: '内容',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
