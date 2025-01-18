import 'package:flutter/material.dart';
import 'package:fumeo/controllers/note.dart';
import 'package:fumeo/pages/note/models/note.dart';
import 'package:get/get.dart';

class NoteEditPanel extends StatefulWidget {
  final Note note;

  const NoteEditPanel({super.key, required this.note});

  @override
  NoteEditPanelState createState() => NoteEditPanelState();
}

class NoteEditPanelState extends State<NoteEditPanel> {
  final NoteController noteController = Get.find();
  late TextEditingController titleController;
  late TextEditingController contentController;
  bool isNewNote = false;

  @override
  void initState() {
    super.initState();
    isNewNote = widget.note.title.isEmpty && widget.note.content.isEmpty;
    titleController = TextEditingController(text: widget.note.title);
    contentController = TextEditingController(text: widget.note.content);

    // 如果是新笔记，默认设置为编辑状态
    if (isNewNote) {
      noteController.isEditing.value = true;
    }

    titleController.addListener(_onTextChanged);
    contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    // 离开编辑页面时重置编辑状态
    noteController.isEditing.value = false;
    super.dispose();
  }

  @override
  void didUpdateWidget(NoteEditPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) {
      isNewNote = widget.note.title.isEmpty && widget.note.content.isEmpty;
      titleController.text = widget.note.title;
      contentController.text = widget.note.content;

      // 如果是新笔记，设置为编辑状态
      if (isNewNote) {
        noteController.isEditing.value = true;
      } else {
        noteController.isEditing.value = false;
      }
    }
  }

  void _onTextChanged() {
    String currentTitle = titleController.text.trim();
    String currentContent = contentController.text.trim();

    if (isNewNote) {
      // 新笔记：只要有内容就标记为编辑状态
      noteController.isEditing.value =
          currentTitle.isNotEmpty || currentContent.isNotEmpty;
    } else {
      // 已有笔记：内容发生改变才标记为编辑状态
      bool hasChanged = currentTitle != widget.note.title.trim() ||
          currentContent != widget.note.content.trim();
      noteController.isEditing.value = hasChanged;
    }
  }

  Future<void> saveNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      Get.snackbar('错误', '标题和内容不能为空');
      return;
    }

    try {
      final wordCount = _calculateWordCount(content);
      if (isNewNote) {
        await noteController.addNote(title, content, wordCount);
      } else {
        await noteController.updateNote(
            widget.note.id, title, content, wordCount);
      }
      Get.snackbar('成功', '笔记已保存');
    } catch (e) {
      Get.snackbar('错误', '保存失败: ${e.toString()}');
    }
  }

  int _calculateWordCount(String text) {
    if (text.isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !noteController.isEditing.value,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!noteController.isEditing.value) return;

        if (didPop) return;

        final bool shouldPop = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('确认离开'),
                content: const Text('当前笔记未保存，是否确认离开？'),
                actions: [
                  TextButton(
                    child: const Text('取消'),
                    onPressed: () => Get.back(result: false),
                  ),
                  TextButton(
                    child: const Text('确认'),
                    onPressed: () => Get.back(result: true),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldPop) {
          noteController.isEditing.value = false;
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: titleController,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: '标题',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Obx(() => IconButton(
                      icon: const Icon(Icons.save),
                      onPressed:
                          noteController.isEditing.value ? saveNote : null,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: '开始写作...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
