import "package:flutter/foundation.dart";
import "package:fumeo/config.dart";
import "package:fumeo/pages/chat/history.dart";
import "package:fumeo/pages/nav/side_nav_bar.dart";
import "package:fumeo/util.dart";

import "input.dart";
import "message.dart";

import "dart:io";
import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:http/http.dart" as http;
import "package:image_picker/image_picker.dart";
import "package:flutter_image_compress/flutter_image_compress.dart";

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? image;
  bool sendable = true;

  File? currentFile;
  ChatConfig? currentChat;
  final List<Message> _messages = [];

  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _editCtrl = TextEditingController();

  List<String> _models = [];
  String? _selectedModel;
  bool _isLoadingModels = false;

  @override
  void initState() {
    super.initState();
    _fetchModels();
  }

  // 获取模型列表的函数
  Future<void> _fetchModels() async {
    if (Config.apiUrl == null || Config.apiKey == null) {
      Util.showSnackBar(
        context: context,
        content: const Text("API URL or API Key is not set"),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      _isLoadingModels = true;
    });

    final url = Uri.parse("${Config.apiUrl!}/v1/models");
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${Config.apiKey}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> modelsData = data['data'];
        List<String> fetchedModels =
            modelsData.map((model) => model['id'] as String).toList();

        // 按字母顺序排序
        fetchedModels.sort((a, b) => a.compareTo(b));

        setState(() {
          _models = fetchedModels;
          // 设置默认模型为 'gpt-4o'，如果存在的话
          if (_models.contains('gpt-4o')) {
            _selectedModel = 'gpt-4o';
            Config.bot.model = 'gpt-4o';
          } else {
            _selectedModel =
                Config.bot.model ?? (_models.isNotEmpty ? _models.first : null);
          }
        });
      } else {
        throw "Failed to load models: ${response.statusCode}";
      }
    } catch (e) {
      if (mounted) {
        Util.showSnackBar(
          context: context,
          content: Text("Error fetching models: $e"),
          duration: const Duration(seconds: 2),
        );
      }
    } finally {
      setState(() {
        _isLoadingModels = false;
      });
    }
  }

  // 保存配置的函数
  void _saveConfig() {
    Config.save();
  }

  // 添加图片的函数
  Future<void> _addImage(BuildContext context) async {
    if (image != null) {
      return setState(() => image = null);
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              title: const Text("Camera"),
              leading: const Icon(Icons.camera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              title: const Text("Gallery"),
              leading: const Icon(Icons.photo_library),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        );
      },
    );
    if (source == null) return;

    final result = await _picker.pickImage(source: source);
    if (result == null) return;

    final compressed = await FlutterImageCompress.compressWithFile(result.path,
        quality: 60, minWidth: 1024, minHeight: 1024);
    Uint8List bytes = compressed ?? await File(result.path).readAsBytes();

    if (compressed == null && context.mounted) {
      Util.showSnackBar(
        context: context,
        content: const Text("Failed to compress image"),
      );
    }

    final base64 = base64Encode(bytes);
    setState(() => image = "data:image/jpeg;base64,$base64");
  }

  // 保存聊天记录的函数
  Future<void> _saveChat() async {
    if (currentChat == null) {
      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch.toString();

      final time = Util.formatDateTime(now);
      final title = _messages.isNotEmpty ? _messages.first.text : "Untitled";
      final fileName = "$timestamp.json";

      final chat = ChatConfig(
        time: time,
        title: title,
        fileName: fileName,
      );
      currentChat = chat;

      final filePath = Config.chatFilePath(fileName);
      currentFile = File(filePath);

      setState(() => Config.chats.add(chat));
      Config.save();
    }

    await currentFile!.writeAsString(jsonEncode(_messages));
  }

  // 发送消息的函数
  Future<void> _sendMessage(BuildContext context) async {
    if (Config.isNotOk) {
      Util.showSnackBar(
        context: context,
        content: const Text("Set up the Bot and API first"),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final text = _editCtrl.text;
    if (text.isEmpty) return;

    setState(() => sendable = false);

    _messages.add(Message(role: MessageRole.user, text: text, image: image));
    final message = Message(role: MessageRole.assistant, text: "");
    final window = _buildContext(_messages);
    _messages.add(message);

    final client = http.Client();
    final chatEndpoint = "${Config.apiUrl!}/v1/chat/completions";

    try {
      final request = http.Request("POST", Uri.parse(chatEndpoint));
      request.headers["Authorization"] = "Bearer ${Config.apiKey}";
      request.headers["Content-Type"] = "application/json";
      request.body = jsonEncode(window);

      final response = await client.send(request);
      final lineStream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      if (response.statusCode != 200) {
        final errorBody = await lineStream.join('\n');
        throw "${response.statusCode} $errorBody";
      }

      outer:
      await for (final line in lineStream) {
        if (!line.startsWith("data:")) continue;
        final raw = line.substring(5).trim();

        if (raw == "[DONE]") break outer;

        try {
          final jsonData = jsonDecode(raw);
          if (kDebugMode) {
            print(jsonData);
          }
          setState(() {
            final content = jsonData["choices"][0]["delta"]["content"];
            if (content != null) {
              message.text += content;
            }
          });
          _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing JSON: $e');
          }
        }
      }

      image = null;
      _editCtrl.clear();
      await _saveChat();
    } catch (e) {
      if (context.mounted) {
        Util.showSnackBar(
          context: context,
          content: Text("$e"),
          duration: const Duration(milliseconds: 1500),
        );
      }
      if (_messages.length >= 2) {
        setState(() {
          _messages.removeRange(_messages.length - 2, _messages.length);
        });
      } else {
        setState(() {
          _messages.clear();
        });
      }
    } finally {
      client.close();
    }

    setState(() => sendable = true);
  }

  // 长按消息
  Future<void> _longPress(BuildContext context, int index) async {
    if (!sendable) return;

    final message = _messages[index];
    final children = [
      ListTile(
        title: const Text("Copy"),
        leading: const Icon(Icons.copy_all),
        onTap: () => Navigator.pop(context, MessageEvent.copy),
      ),
    ];

    if (message.role == MessageRole.user) {
      children.add(
        ListTile(
          title: const Text("Delete"),
          leading: const Icon(Icons.delete_outlined),
          onTap: () => Navigator.pop(context, MessageEvent.delete),
        ),
      );
    }

    final event = await showModalBottomSheet<MessageEvent>(
      context: context,
      builder: (BuildContext context) {
        return Wrap(children: children);
      },
    );
    if (event == null) return;

    switch (event) {
      case MessageEvent.copy:
        await Clipboard.setData(ClipboardData(text: message.text));
        if (context.mounted) {
          Util.showSnackBar(
            context: context,
            content: const Text("Copied Successfully"),
          );
        }
        break;

      case MessageEvent.delete:
        setState(() {
          if (_messages.length > index) {
            _messages.removeAt(index);
            if (_messages.length > index &&
                _messages[index].role == MessageRole.assistant) {
              _messages.removeAt(index);
            }
          }
        });
        await _saveChat();
        break;

      default:
        if (context.mounted) {
          Util.showSnackBar(
            context: context,
            content: const Text("Not implemented yet"),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            itemCount: _messages.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final message = _messages[index];
              return MessageWidget(
                message: message,
                longPress: () async => await _longPress(context, index),
              );
            },
          ),
        ),
        InputWidget(
          editable: sendable,
          controller: _editCtrl,
          files: image != null ? 1 : 0,
          addImage: sendable ? _addImage : null,
          sendMessage: sendable ? _sendMessage : null,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "大语言模型可能会生成误导性错误信息，请对关键信息加以验证。",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: _isLoadingModels
            ? SizedBox(
                width: 150,
                height: 30,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            : _models.isNotEmpty
                ? DropdownButtonHideUnderline(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedModel,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                        ),
                        items: _models.map((model) {
                          return DropdownMenuItem<String>(
                            value: model,
                            child: Text(
                              model,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newModel) {
                          if (newModel != null) {
                            setState(() {
                              _selectedModel = newModel;
                              Config.bot.model = newModel;
                            });
                            _saveConfig();
                          }
                        },
                      ),
                    ),
                  )
                : const Text('LLM'),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Icon(Icons.menu),
            ),
          ),
        ),
        actions: [
          // 现有的 IconButton
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            onPressed: () {
              setState(() {
                _messages.clear();
                currentChat = null;
                currentFile = null;
                image = null;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed("chat_settings"),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatHistory(
                    onChatSelected: _loadSelectedChat,
                    onChatDeleted: _deleteChat,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const SideNavBar(),
      body: body,
    );
  }

  // 加载选中的聊天
  Future<void> _loadSelectedChat(ChatConfig chat) async {
    if (currentChat == chat) return;
    setState(() {
      _messages.clear();
      currentChat = chat;
      currentFile = File(Config.chatFilePath(chat.fileName));
    });

    try {
      final jsonData = await currentFile!.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonData);
      setState(() {
        _messages.addAll(jsonList.map((e) => Message.fromJson(e)).toList());
        image = null;
      });
    } catch (e) {
      if (!mounted) return;
      Util.showSnackBar(
        context: context,
        content: Text("Failed to load chat: $e"),
        duration: const Duration(seconds: 2),
      );
    }
  }

  // 删除聊天
  Future<void> _deleteChat(int index) async {
    final chat = Config.chats[index];
    if (currentChat == chat) {
      setState(() {
        currentChat = null;
        currentFile = null;
        _messages.clear();
        image = null;
      });
    }

    final file = File(Config.chatFilePath(chat.fileName));
    if (await file.exists()) {
      await file.delete();
    }

    setState(() {
      Config.chats.removeAt(index);
    });
    await Config.save();

    if (!mounted) return;
    Util.showSnackBar(
      context: context,
      content: const Text("Chat deleted successfully"),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _editCtrl.dispose();
    super.dispose();
  }

  // 构建消息上下文
  Map<String, Object> _buildContext(List<Message> messages) {
    Map<String, Object> context = {
      "model": _selectedModel ?? Config.bot.model!,
      "stream": true,
    };
    if (Config.bot.maxTokens != null) {
      context["max_tokens"] = Config.bot.maxTokens!;
    }
    if (Config.bot.temperature != null) {
      context["temperature"] = Config.bot.temperature!;
    }

    List<Map<String, Object>> list = [];
    if (Config.bot.systemPrompts != null) {
      list.add({"role": "system", "content": Config.bot.systemPrompts!});
    }

    for (final pair in messages.asMap().entries) {
      final int index = pair.key;
      final Message message = pair.value;
      final String? image = message.image;

      Object content;
      if (index != messages.length - 1 || image == null) {
        content = message.text;
      } else {
        content = [
          {
            "type": "image_url",
            "image_url": {"url": image},
          },
          {
            "type": "text",
            "text": message.text,
          },
        ];
      }

      list.add({"role": message.role.name, "content": content});
    }

    context["messages"] = list;
    return context;
  }
}
