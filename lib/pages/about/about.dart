import 'package:flutter/material.dart';
import 'package:fumeo/controllers/about.dart';
import 'package:get/get.dart';
import 'package:fumeo/core/utils/launch_url.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    'lib/images/logo.png',
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Fumeo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                        '${controller.packageInfo.value?.version}-${controller.packageInfo.value?.buildNumber}',
                        style: const TextStyle(fontSize: 14),
                      )),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        '作者',
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  ...controller.developers.map((developer) {
                    return InkWell(
                      onTap: () =>
                          launchURL('https://github.com/${developer['name']}'),
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 70,
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  NetworkImage(developer['avatar']!),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                developer['nickname']!,
                                style: const TextStyle(fontSize: 16),
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

            // 底部版权信息
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Text(
                    '© ${DateTime.now().year} cuxt. All rights reserved.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
