import 'package:flutter/material.dart';
import 'package:fumeo/controllers/note.dart';
import 'package:fumeo/pages/note/note_edit_panel.dart';
import 'package:fumeo/pages/note/note_list_panel.dart';
import 'package:get/get.dart';

class NoteView extends StatelessWidget {
  final NoteController noteController = Get.find();

  NoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 200),
                  child: SegmentedButton<int>(
                    // 隐藏选中指示器
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: 0,
                        label: Text(
                          '列表',
                          style: TextStyle(
                            fontWeight: noteController.currentView.value == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text(
                          '编辑',
                          style: TextStyle(
                            fontWeight: noteController.currentView.value == 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                    selected: {noteController.currentView.value},
                    onSelectionChanged: (Set<int> newSelection) {
                      noteController.currentView.value = newSelection.first;
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.transparent),
                        side: WidgetStateProperty.all(BorderSide.none)),
                  ),
                ),
              ],
            )),
      ),
      body: Obx(() => noteController.currentView.value == 0
          ? NoteListPanel()
          : noteController.selectedNote.value != null
              ? NoteEditPanel(note: noteController.selectedNote.value!)
              : const Center(child: Text('请选择或创建笔记'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => noteController.createNewNote(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
