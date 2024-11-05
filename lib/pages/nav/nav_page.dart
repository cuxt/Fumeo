import 'package:flutter/material.dart';
import 'package:fumeo/pages/chat/chat_page.dart';
import 'package:fumeo/pages/explore/explore_page.dart';
import 'package:fumeo/pages/mine/mine_page.dart';
import 'package:fumeo/pages/nav/bottom_nav_bar.dart';
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
    const ChatPage(),
    const TodoPage(),
    const ExplorePage(),
    const MinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: BottomNavBar(
        onTabChange: navigationBottomBar,
        selectedIndex: _selectedIndex,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }
}
