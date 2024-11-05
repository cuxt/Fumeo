import 'package:flutter/material.dart';
import 'package:fumeo/pages/nav/side_nav_bar.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
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
      body: Center(
        child: Text('Mine Page'),
      ),
    );
  }
}
