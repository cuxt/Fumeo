import "package:fumeo/config.dart";
import "package:fumeo/pages/chat/setting/settings.dart";
import "package:fumeo/util.dart";

import "package:flutter/material.dart";

class APIWidget extends StatefulWidget {
  const APIWidget({super.key});

  @override
  State<APIWidget> createState() => _APIWidgetState();
}

class _APIWidgetState extends State<APIWidget> {
  @override
  Widget build(BuildContext context) {
    final shared = SettingsShared.of(context);
    final apis = Config.apis.entries.toList();

    return Column(
      children: [
        FilledButton(
          child: const Text("新增"),
          onPressed: () async {
            final changed = await showDialog<bool>(
              context: context,
              builder: (context) => ApiInfoWidget(shared: shared),
            );
            if (changed != null && changed) {
              await Config.save();
              setState(() {}); // 更新 UI
            }
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: apis.length,
            itemBuilder: (context, index) {
              return Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(apis[index].key),
                  leading: const Icon(Icons.api),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final changed = await showDialog<bool>(
                        context: context,
                        builder: (context) =>
                            ApiInfoWidget(shared: shared, entry: apis[index]),
                      );
                      if (changed != null && changed) {
                        await Config.save();
                        setState(() {}); // 更新 UI
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ApiInfoWidget extends StatefulWidget {
  final SettingsShared shared;
  final MapEntry<String, ApiConfig>? entry;

  const ApiInfoWidget({
    super.key,
    this.entry,
    required this.shared,
  });

  @override
  State<ApiInfoWidget> createState() => _ApiInfoWidgetState();
}

class _ApiInfoWidgetState extends State<ApiInfoWidget> {
  late TextEditingController _nameCtrl;
  late TextEditingController _modelsCtrl;
  late TextEditingController _apiUrlCtrl;
  late TextEditingController _apiKeyCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
        text: widget.entry != null ? widget.entry!.key : '');
    _apiUrlCtrl = TextEditingController(
        text: widget.entry != null ? widget.entry!.value.url : '');
    _apiKeyCtrl = TextEditingController(
        text: widget.entry != null ? widget.entry!.value.key : '');
    _modelsCtrl = TextEditingController(
        text:
            widget.entry != null ? widget.entry!.value.models.join(", ") : '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _apiUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    _modelsCtrl.dispose();
    super.dispose();
  }

  void fix() {
    final api = Config.bot.api;
    final model = Config.bot.model;

    if (api != null) {
      final apis = Config.apis[api];
      if (apis == null) {
        Config.bot.api = null;
        Config.bot.model = null;
      } else if (!apis.models.contains(model)) {
        Config.bot.model = null;
      }
    } else if (model != null) {
      Config.bot.model = null;
    }
  }

  bool save(BuildContext context) {
    final name = _nameCtrl.text.trim();
    final apiUrl = _apiUrlCtrl.text.trim();
    final apiKey = _apiKeyCtrl.text.trim();

    if (name.isEmpty || apiUrl.isEmpty || apiKey.isEmpty) {
      Util.showSnackBar(
        context: context,
        content: const Text("Please complete all fields except Model List"),
      );
      return false;
    }

    if (Config.apis.containsKey(name) &&
        (widget.entry == null || name != widget.entry!.key)) {
      Util.showSnackBar(
        context: context,
        content: Text("The '$name' API already exists"),
      );
      return false;
    }

    if (widget.entry != null) {
      widget.shared.setState(() => Config.apis.remove(widget.entry!.key));
    }

    widget.shared.setState(() {
      Config.apis[name] = ApiConfig(
        url: apiUrl,
        key: apiKey,
        models: widget.entry != null ? widget.entry!.value.models : [],
      );
      fix();
    });

    Util.showSnackBar(
      context: context,
      content: const Text("Saved Successfully"),
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text("API"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // API Name 输入框
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // API URL 输入框
            TextField(
              controller: _apiUrlCtrl,
              decoration: const InputDecoration(
                labelText: "API Url",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // API Key 输入框
            TextField(
              controller: _apiKeyCtrl,
              decoration: const InputDecoration(
                labelText: "API Key",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Model List 输入框（只读）
            TextField(
              controller: _modelsCtrl,
              readOnly: true, // 设置为只读
              decoration: const InputDecoration(
                labelText: "Model List (read-only)",
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                helperText: "The model list is automatically fetched",
              ),
            ),
            const SizedBox(height: 16),
            // 按钮行
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text("取消"),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.entry != null) ...[
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      onPressed: () {
                        widget.shared.setState(() {
                          Config.apis.remove(widget.entry!.key);
                          fix();
                        });
                        Navigator.of(context).pop(true);
                      },
                      child: const Text("删除"),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (save(context)) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: const Text("保存"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
