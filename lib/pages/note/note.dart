import 'package:flutter/material.dart';
import 'package:fumeo/controllers/note.dart';
import 'package:fumeo/pages/nav/side_nav_bar.dart';
import 'package:fumeo/pages/note/markdown_preview.dart';
import 'package:fumeo/pages/note/note_edit_panel.dart';
import 'package:fumeo/pages/note/note_list_panel.dart';
import 'package:get/get.dart';
import 'package:heroicons/heroicons.dart';

class NoteView extends StatelessWidget {
  final NoteController noteController = Get.find();

  NoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const HeroIcon(
                  HeroIcons.bars3,
                  style: HeroIconStyle.outline,
                ),
              ),
            ),
            // 占位
            const IconButton(
              onPressed: null,
              icon: Icon(null),
            ),
            Expanded(
              child: Center(
                child: Obx(() => Container(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: SegmentedButton<int>(
                        // 隐藏选中指示器
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: 0,
                            label: Text(
                              '笔记',
                              style: TextStyle(
                                fontWeight:
                                    noteController.currentView.value == 0
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
                                fontWeight:
                                    noteController.currentView.value == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                        selected: {noteController.currentView.value},
                        onSelectionChanged: (Set<int> newSelection) {
                          noteController.currentView.value = newSelection.first;
                          noteController.jumpToPage(newSelection.first);
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.transparent),
                          side: WidgetStateProperty.all(BorderSide.none),
                        ),
                      ),
                    )),
              ),
            ),
            // MD 渲染按钮
            Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () {
                    if (noteController.selectedNote.value != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MarkdownPreviewPage(
                            note: noteController.selectedNote.value!,
                          ),
                        ),
                      );
                    } else {
                      Get.snackbar('提示', '请先选择一个笔记');
                    }
                  },
                  icon: const HeroIcon(
                    HeroIcons.sparkles,
                    style: HeroIconStyle.outline,
                  ),
                  splashRadius: 20,
                ),
              ),
            ),
            // 下拉菜单
            Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const HeroIcon(
                    HeroIcons.ellipsisVertical,
                    style: HeroIconStyle.outline,
                  ),
                  splashRadius: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: const SideNavBar(),
      body: PageView(
        controller: noteController.pageController,
        onPageChanged: (index) {
          noteController.currentView.value = index;
        },
        children: [
          NoteListPanel(),
          Obx(() => noteController.selectedNote.value != null
              ? NoteEditPanel(note: noteController.selectedNote.value!)
              : const Center(child: Text('请选择或创建笔记'))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => noteController.createNewNote(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
