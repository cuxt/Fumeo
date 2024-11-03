import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late final List<ExploreItem> items;

  @override
  void initState() {
    super.initState();
    items = [
      ExploreItem(
        logoPath: 'lib/images/logo.png',
        title: '官网',
        onTap: () {
          _launchURL('https://web.xbxin.com');
        },
      ),
      ExploreItem(
        logoPath: 'lib/images/nextchat.png',
        title: 'NextChat',
        onTap: () {
          _launchURL('https://next.bxin.top');
        },
      ),
      ExploreItem(
        logoPath: 'lib/images/newapi.png',
        title: 'NewAPI',
        onTap: () {
          _launchURL('https://llm.bxin.top');
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) => _buildRow(item)).toList(),
    );
  }

  Widget _buildRow(ExploreItem item) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: item.onTap,
        child: Container(
          color: Colors.grey[200],
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 16.0),
                  Image.asset(
                    item.logoPath,
                    width: 24.0,
                    height: 24.0,
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  // 打开网页
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class ExploreItem {
  final String logoPath;
  final String title;
  final VoidCallback onTap;

  ExploreItem({
    required this.logoPath,
    required this.title,
    required this.onTap,
  });
}
