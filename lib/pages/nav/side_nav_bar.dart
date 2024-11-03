import 'package:flutter/material.dart';
import 'package:fumeo/pages/about_page.dart';
import 'package:fumeo/theme/color.dart';
import 'package:fumeo/pages/settings_page.dart'; // 确保导入你的设置页面

class SideNavBar extends StatefulWidget {
  const SideNavBar({super.key});

  @override
  State<SideNavBar> createState() => _SideNavBarState();
}

class _SideNavBarState extends State<SideNavBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const DrawerHeader(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "F",
                        style: TextStyle(
                          color: FmColors.primary,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "umeo",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Divider(
                  color: Colors.grey[800],
                ),
              ),
              // 页面
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: Colors.grey[800],
                ),
                title: Text(
                  '关于',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // 使用 Navigator.push 替代
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()), // 确保你有 AboutPage
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.settings,
                color: Colors.grey[800],
              ),
              title: Text(
                '设置',
                style: TextStyle(color: Colors.grey[800]),
              ),
              onTap: () {
                Navigator.pop(context);
                // 使用 Navigator.push 替代
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
