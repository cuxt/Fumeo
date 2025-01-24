import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:fumeo/core/utils/launch_url.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:fumeo/pages/note/models/note.dart';

class MarkdownPreviewPage extends StatelessWidget {
  final Note note;

  const MarkdownPreviewPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(note.title.isEmpty ? '预览' : note.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Markdown(
        data: note.content,
        selectable: true,
        padding: const EdgeInsets.all(16),
        onTapLink: (text, href, title) {
          if (href != null) {
            launchURL(href);
          }
        },
        builders: {
          'code': CodeElementBuilder(),
        },
        styleSheet: MarkdownStyleSheet(
          codeblockPadding: EdgeInsets.zero,
          codeblockDecoration: const BoxDecoration(),
          h1: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.5,
            color: isDark ? Colors.white : Colors.black,
          ),
          h2: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.5,
            color: isDark ? Colors.white : Colors.black,
          ),
          h3: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.5,
            color: isDark ? Colors.white : Colors.black,
          ),
          p: TextStyle(
            fontSize: 16,
            height: 1.7,
            color: isDark ? Colors.white : Colors.black,
          ),
          blockquote: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontSize: 16,
            height: 1.7,
          ),
          blockquoteDecoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 4,
              ),
            ),
          ),
          blockquotePadding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          listBullet: TextStyle(
            fontSize: 16,
            height: 1.7,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';
    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }

    final syntax = _getSyntax(language);
    final isSupported = syntax != null;
    final code = element.textContent;

    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: isDark ? 0 : 2,
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isDark
              ? const BorderSide(color: Color(0xFF404040))
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (language.isNotEmpty) _buildCodeHeader(language, code, isDark),
            if (!isSupported && language.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: Colors.orange.withAlpha(26),
                child: Text(
                  '提示：暂不支持 $language 语言的语法高亮',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
            if (isSupported)
              SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SyntaxView(
                    code: code,
                    syntax: syntax,
                    syntaxTheme: isDark
                        ? SyntaxTheme.vscodeDark()
                        : SyntaxTheme.vscodeLight(),
                    fontSize: 14,
                    withZoom: true,
                    withLinesCount: true,
                    expanded: false,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color:
                    isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                child: SelectableText(
                  code,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildCodeHeader(String language, String code, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF363636) : Colors.grey[100],
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF404040) : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            language.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.copy_outlined,
              size: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
            constraints: const BoxConstraints(),
            tooltip: '复制代码',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
            },
          ),
        ],
      ),
    );
  }

  Syntax? _getSyntax(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
        return Syntax.DART;
      case 'c':
        return Syntax.C;
      case 'cpp':
      case 'c++':
        return Syntax.CPP;
      case 'java':
        return Syntax.JAVA;
      case 'kotlin':
        return Syntax.KOTLIN;
      case 'swift':
        return Syntax.SWIFT;
      case 'javascript':
      case 'js':
        return Syntax.JAVASCRIPT;
      case 'yaml':
        return Syntax.YAML;
      case 'rust':
        return Syntax.RUST;
      default:
        return null;
    }
  }
}
