import "bot.dart";
import "api.dart";
import "package:fumeo/config.dart";

import "package:flutter/material.dart";

class ChatSettingsPage extends StatefulWidget {
  const ChatSettingsPage({super.key});

  @override
  State<ChatSettingsPage> createState() => ChatSettingsPageState();
}

class ChatSettingsPageState extends State<ChatSettingsPage> {
  final Map<String, Widget> tabItems = {
    "Bot": BotWidget(),
    "APIs": APIWidget(),
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabItems.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("设置"),
          bottom: TabBar(
            tabs: tabItems.keys.map((title) => Tab(text: title)).toList(),
          ),
        ),
        body: SettingsShared(
          setState: setState,
          child: TabBarView(
            children: tabItems.values.map((widget) {
              return Container(
                margin: EdgeInsets.all(16),
                child: widget,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class SettingsShared extends InheritedWidget {
  final void Function(VoidCallback) setState;
  final Map<String, ApiConfig> apis = Config.apis;

  SettingsShared({
    super.key,
    required super.child,
    required this.setState,
  });

  static SettingsShared of(BuildContext context) {
    final SettingsShared? result =
        context.dependOnInheritedWidgetOfExactType<SettingsShared>();
    assert(result != null, 'No SettingsShared found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(SettingsShared oldWidget) {
    return oldWidget.apis != apis;
  }
}
