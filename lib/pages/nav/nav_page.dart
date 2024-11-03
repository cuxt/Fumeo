import 'package:flutter/material.dart';
import 'package:fumeo/pages/explore/explore_page.dart';
import 'package:fumeo/pages/mine/mine_page.dart';
import 'package:fumeo/pages/nav/bottom_nav_bar.dart';
import 'package:fumeo/pages/nav/side_nav_bar.dart';
import 'package:fumeo/pages/home/home_page.dart';
import 'package:fumeo/pages/todo/todo_page.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _selectedIndex = 0;

  void navigationBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const TodoPage(),
    const ExplorePage(),
    const MinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      bottomNavigationBar: BottomNavBar(
        onTabChange: navigationBottomBar,
        selectedIndex: _selectedIndex,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Fumeo'),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Icon(Icons.menu, color: Colors.black),
            ),
          ),
        ),
      ),
      drawer: const SideNavBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}
