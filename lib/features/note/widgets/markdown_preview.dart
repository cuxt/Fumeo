import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownPreview extends StatelessWidget {
  final String markdownData;

  const MarkdownPreview({
    super.key,
    required this.markdownData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: markdownData.isEmpty
          ? const Center(
              child: Text(
                '预览区域\n\n开始输入内容以查看预览效果',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Markdown(
              data: markdownData,
              selectable: true,
              onTapLink: (text, href, title) {
                _launchURL(href);
              },
              styleSheet: MarkdownStyleSheet(
                h1: Theme.of(context).textTheme.headlineMedium,
                h2: Theme.of(context).textTheme.headlineSmall,
                h3: Theme.of(context).textTheme.titleLarge,
                h4: Theme.of(context).textTheme.titleMedium,
                p: const TextStyle(fontSize: 16),
                code: TextStyle(
                  backgroundColor: Colors.grey[200],
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                codeblockDecoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
    );
  }

  Future<void> _launchURL(String? url) async {
    if (url == null) return;

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
