import "package:fumeo/config.dart";
import "package:fumeo/util.dart";

import "package:flutter/material.dart";

class BotWidget extends StatefulWidget {
  const BotWidget({super.key});

  @override
  State<BotWidget> createState() => _BotWidgetState();
}

class _BotWidgetState extends State<BotWidget> {
  String? _api = Config.bot.api;

  final TextEditingController _maxTokensCtrl =
      TextEditingController(text: Config.bot.maxTokens?.toString());
  final TextEditingController _temperatureCtrl =
      TextEditingController(text: Config.bot.temperature?.toString());
  final TextEditingController _systemPromptsCtrl =
      TextEditingController(text: Config.bot.systemPrompts?.toString());

  Future<void> save(BuildContext context) async {
    final maxTokens = int.tryParse(_maxTokensCtrl.text);
    final temperature = num.tryParse(_temperatureCtrl.text);

    if (_maxTokensCtrl.text.isNotEmpty && maxTokens == null) {
      Util.showSnackBar(
        context: context,
        content: const Text("Invalid Max Tokens"),
      );
      return;
    }

    if (_temperatureCtrl.text.isNotEmpty && temperature == null) {
      Util.showSnackBar(
        context: context,
        content: const Text("Invalid Temperature"),
      );
      return;
    }

    Config.bot.api = _api;
    Config.bot.maxTokens = maxTokens;
    Config.bot.temperature = temperature;
    final systemPrompts = _systemPromptsCtrl.text;
    Config.bot.systemPrompts = systemPrompts.isNotEmpty ? systemPrompts : null;

    Util.showSnackBar(
      context: context,
      content: const Text("Saved Successfully"),
    );

    await Config.save();
  }

  @override
  Widget build(BuildContext context) {
    final apiList = <DropdownMenuItem<String>>[];

    final apis = Config.apis.keys;
    for (final api in apis) {
      apiList.add(DropdownMenuItem(
          value: api, child: Text(api, overflow: TextOverflow.ellipsis)));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        DropdownButtonFormField<String>(
          value: _api,
          items: apiList,
          isExpanded: true,
          hint: const Text("API"),
          onChanged: (String? it) => setState(() {
            _api = it;
          }),
          decoration: const InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextField(
                controller: _temperatureCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Temperature",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: TextField(
                controller: _maxTokensCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Max Tokens",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // System Prompts 输入框
        TextField(
          maxLines: 4,
          controller: _systemPromptsCtrl,
          decoration: const InputDecoration(
            alignLabelWithHint: true,
            labelText: "System Prompts",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 重置和保存按钮
        Row(
          children: [
            Expanded(
              flex: 1,
              child: FilledButton.tonal(
                  child: const Text("重置"),
                  onPressed: () {
                    _maxTokensCtrl.text = "";
                    _temperatureCtrl.text = "";
                    _systemPromptsCtrl.text = "";
                    setState(() {
                      _api = null;
                    });
                  }),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: FilledButton(
                child: const Text("保存"),
                onPressed: () async => save(context),
              ),
            ),
          ],
        )
      ],
    );
  }
}
