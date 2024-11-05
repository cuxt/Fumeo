import 'package:flutter/material.dart';
import 'package:fumeo/config.dart';

class ChatHistory extends StatelessWidget {
  final Function(ChatConfig) onChatSelected;
  final Function(int) onChatDeleted;

  const ChatHistory({
    super.key,
    required this.onChatSelected,
    required this.onChatDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: Config.chats.length,
              itemBuilder: (context, index) {
                final chat = Config.chats[index];
                return ListTile(
                  contentPadding: const EdgeInsets.only(left: 16, right: 8),
                  leading: const Icon(Icons.message),
                  title: Text(
                    chat.title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(chat.time),
                  onTap: () {
                    onChatSelected(chat);
                    Navigator.pop(context);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // 删除确认
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("删除聊天"),
                            content: const Text("您确定要删除此聊天记录吗？"),
                            actions: [
                              TextButton(
                                child: const Text("取消"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("删除"),
                                onPressed: () {
                                  Navigator.of(context).pop(); // 关闭对话框
                                  onChatDeleted(index);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
