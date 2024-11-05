import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  final int files;
  final bool editable;
  final TextEditingController controller;
  final void Function(BuildContext context)? addImage;
  final void Function(BuildContext context)? sendMessage;

  const InputWidget({
    super.key,
    this.files = 0,
    this.editable = true,
    required this.addImage,
    required this.controller,
    required this.sendMessage,
  });

  @override
  Widget build(BuildContext context) {
    void Function()? add;
    void Function()? send;

    if (addImage != null) {
      add = () {
        addImage!(context);
      };
    }

    if (sendMessage != null) {
      send = () {
        sendMessage!(context);
      };
    }

    final inputRow = Row(
      crossAxisAlignment: CrossAxisAlignment.center, // 居中对齐
      children: [
        Badge(
          isLabelVisible: files != 0,
          alignment: Alignment.topLeft,
          label: Text(files.toString()),
          child: IconButton(
            onPressed: add,
            icon: Icon(files == 0 ? Icons.add_photo_alternate : Icons.delete),
          ),
        ),
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 120),
            child: TextField(
              maxLines: null,
              enabled: editable,
              controller: controller,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "发送消息",
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: send,
          icon: const Icon(Icons.send),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // 四周圆角
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: inputRow,
      ),
    );
  }
}
