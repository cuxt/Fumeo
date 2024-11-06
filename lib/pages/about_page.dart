import 'package:flutter/material.dart';
import 'package:fumeo/components/launch_url.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  final List<Map<String, String>> _developers = [
    {
      'name': 'zhoubinxin',
      'nickname': 'bx',
      'avatar': 'https://avatars.githubusercontent.com/u/123720843?v=4',
    },
    {
      'name': 'Assianc',
      'nickname': 'Assianc',
      'avatar': 'https://avatars.githubusercontent.com/u/153348472?v=4',
    },
  ];

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version; // 获取版本号
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 应用图标
            Image.asset(
              'lib/images/logo.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            // 应用名称和版本
            const Text(
              'Fumeo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '版本 $_version',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // 简介
            const Text(
              'Fumeo 是一款优秀的应用程序',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            // 开发者信息
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft, // 左对齐
                child: Text(
                  '开发者',
                  style: TextStyle(
                      fontWeight: FontWeight.w200,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),

            // 开发者信息列表
            ..._developers.map((developer) {
              return InkWell(
                onTap: () =>
                    launchURL('https://github.com/${developer['name']}'),
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 70,
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      // 开发者头像
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            NetworkImage(developer['avatar']!), // 使用网络头像
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${developer['nickname']} (${developer['name']})',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
