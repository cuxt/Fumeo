import 'package:flutter/material.dart';
import 'package:fumeo/components/launch_url.dart';
import 'package:fumeo/pages/nav/side_nav_bar.dart';

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
          launchURL('https://web.xbxin.com');
        },
      ),
      ExploreItem(
        logoPath: 'lib/images/nextchat.png',
        title: 'NextChat',
        onTap: () {
          launchURL('https://next.bxin.top');
        },
      ),
      ExploreItem(
        logoPath: 'lib/images/newapi.png',
        title: 'NewAPI',
        onTap: () {
          launchURL('https://llm.bxin.top');
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Icon(Icons.menu),
            ),
          ),
        ),
      ),
      drawer: const SideNavBar(),
      body: ListView(
        children: items.map((item) => _buildRow(item)).toList(),
      ),
    );
  }

  Widget _buildRow(ExploreItem item) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: item.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.0),
          ),
          height: 70.0,
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
              const Padding(
                padding: EdgeInsets.only(right: 16.0), // 右边距
                child: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
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
