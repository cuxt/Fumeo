import "dart:io";
import "dart:convert";
import "package:path_provider/path_provider.dart";
import 'package:flutter/foundation.dart';

class BotConfig {
  String? api;
  String? model;
  int? maxTokens;
  num? temperature;
  String? systemPrompts;

  BotConfig({
    this.api,
    this.model,
    this.maxTokens,
    this.temperature,
    this.systemPrompts,
  });

  Map<String, dynamic> toJson() => {
        "api": api,
        "model": model,
        "maxTokens": maxTokens,
        "temperature": temperature,
        "systemPrompts": systemPrompts,
      };

  factory BotConfig.fromJson(Map<String, dynamic> json) => BotConfig(
        api: json["api"],
        model: json["model"],
        maxTokens: json["maxTokens"],
        temperature: json["temperature"],
        systemPrompts: json["systemPrompts"],
      );
}

class ApiConfig {
  String url;
  String key;
  List<String> models;

  ApiConfig({
    required this.url,
    required this.key,
    required this.models,
  });

  Map<String, Object> toJson() => {
        "url": url,
        "key": key,
        "models": models,
      };

  factory ApiConfig.fromJson(Map<String, dynamic> json) => ApiConfig(
        url: json["url"],
        key: json["key"],
        models: json["models"].cast<String>(),
      );
}

class ChatConfig {
  String time;
  String title;
  String fileName;

  ChatConfig({
    required this.time,
    required this.title,
    required this.fileName,
  });

  Map<String, String> toJson() => {
        "time": time,
        "title": title,
        "fileName": fileName,
      };

  factory ChatConfig.fromJson(Map<String, dynamic> json) => ChatConfig(
        time: json["time"],
        title: json["title"],
        fileName: json["fileName"],
      );
}

class Config {
  static BotConfig bot = BotConfig();
  static Map<String, ApiConfig> apis = {};
  static List<ChatConfig> chats = [];

  static String? get apiUrl {
    if (bot.api == null) return null;
    return apis[bot.api]!.url;
  }

  static String? get apiKey {
    if (bot.api == null) return null;
    return apis[bot.api]!.key;
  }

  static bool get isOk {
    return bot.model != null && apiUrl != null && apiKey != null;
  }

  static bool get isNotOk {
    return bot.model == null || apiUrl == null || apiKey == null;
  }

  static void fromJson(Map<String, dynamic> json) {
    final botJson = json["bot"] ?? {};
    final apisJson = json["apis"] ?? {};
    final chatsJson = json["chats"] ?? [];

    bot = BotConfig.fromJson(botJson);

    for (final pair in apisJson.entries) {
      apis[pair.key] = ApiConfig.fromJson(pair.value);
    }

    for (final chat in chatsJson) {
      chats.add(ChatConfig.fromJson(chat));
    }
  }

  static Map<String, dynamic> toJson() => {
        "bot": bot.toJson(),
        "apis": apis.map((key, value) => MapEntry(key, value.toJson())),
        "chats": chats.map((chat) => chat.toJson()).toList(),
      };

  static late final File _file;
  static late final String _filePath;
  static late final Directory _directory;
  static const String _fileName = "settings.json";

  static Future<void> initialize() async {
    // 检查当前平台
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        _directory = (await getExternalStorageDirectory())!;
      } catch (e) {
        if (kDebugMode) {
          print("Error getting external storage path: $e");
        }
        return;
      }
    } else {
      // 对于非 Android 平台，使用应用程序文档目录
      _directory = await getApplicationDocumentsDirectory();
    }

    _filePath = "${_directory.path}${Platform.pathSeparator}$_fileName";

    _file = File(_filePath);
    if (await _file.exists()) {
      final data = await _file.readAsString();
      fromJson(jsonDecode(data));
    } else {
      save();
    }
  }

  static Future<void> save() async {
    await _file.writeAsString(jsonEncode(toJson()));
  }

  static String chatFilePath(String fileName) {
    return "${_directory.path}${Platform.pathSeparator}$fileName";
  }
}
