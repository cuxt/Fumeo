import "package:flutter/material.dart";
import "package:markdown/markdown.dart" as md;
import "package:markdown/markdown.dart" hide Element;
import "package:flutter_markdown/flutter_markdown.dart";
import "package:flutter_highlighter/flutter_highlighter.dart";
import "package:flutter_markdown_latex/flutter_markdown_latex.dart";

class Message {
  String text;
  String? image;
  MessageRole role;

  Message({this.image, required this.role, required this.text});

  Map<String, String?> toJson() => {
        "text": text,
        "image": image,
        "role": role.name,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        text: json["text"],
        image: json["image"],
        role: switch (json["role"]) {
          "assistant" => MessageRole.assistant,
          "user" => MessageRole.user,
          _ => throw "bad role",
        },
      );
}

enum MessageRole {
  assistant,
  user,
}

enum MessageEvent {
  source,
  delete,
  copy,
  edit,
}

class MessageWidget extends StatelessWidget {
  final Message message;
  final VoidCallback longPress;

  const MessageWidget({
    super.key,
    required this.message,
    required this.longPress,
  });

  static final extensionSet = ExtensionSet(
    <BlockSyntax>[
      LatexBlockSyntax(),
      const TableSyntax(),
      const FootnoteDefSyntax(),
      const FencedCodeBlockSyntax(),
      const OrderedListWithCheckboxSyntax(),
      const UnorderedListWithCheckboxSyntax(),
    ],
    <InlineSyntax>[
      InlineHtmlSyntax(),
      LatexInlineSyntax(),
      StrikethroughSyntax(),
      AutolinkExtensionSyntax()
    ],
  );

  @override
  Widget build(BuildContext context) {
    String content = message.text;
    final Alignment alignment;
    final Color background;

    final colorScheme = Theme.of(context).colorScheme;
    final markdownStyleSheet = MarkdownStyleSheet(
      codeblockDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceContainer,
      ),
    );

    if (message.image != null) {
      content = "![image](${message.image})\n\n${message.text}";
    }

    switch (message.role) {
      case MessageRole.user:
        background = colorScheme.secondaryContainer;
        alignment = Alignment.centerRight;
        break;

      case MessageRole.assistant:
        background = colorScheme.surfaceContainerHighest;
        alignment = Alignment.centerLeft;
        break;
    }

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.all(8),
      child: GestureDetector(
        onLongPress: longPress,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: background, borderRadius: BorderRadius.circular(8)),
          child: MarkdownBody(
            data: content,
            shrinkWrap: true,
            extensionSet: extensionSet,
            builders: {
              "code": CodeElementBuilder(context: context),
              "latex": LatexElementBuilder(textScaleFactor: 1.2),
            },
            styleSheet: markdownStyleSheet,
            styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
          ),
        ),
      ),
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  CodeElementBuilder({required this.context});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = "";

    if (element.attributes["class"] != null) {
      language = element.attributes["class"]!.substring(9);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: HighlightView(
        tabSize: 2,
        language: language,
        element.textContent.trim(),
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}
