import 'package:flutter/material.dart';
import 'package:fumeo/theme/color.dart';

class BottomNavBar extends StatefulWidget {
  final void Function(int)? onTabChange;
  final int selectedIndex;

  const BottomNavBar(
      {super.key, required this.onTabChange, required this.selectedIndex});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      selectedItemColor: FmColors.primary, // 选中标签的颜色
      unselectedItemColor: Colors.grey, // 未选中标签的颜色
      onTap: (index) {
        widget.onTabChange?.call(index);
      },
      items: [
        _buildBottomNavItem('lib/images/icons/ic_home.png', '首页', 0),
        _buildBottomNavItem('lib/images/icons/ic_edit.png', '小记', 1),
        _buildBottomNavItem('lib/images/icons/ic_focus.png', '发现', 2),
        _buildBottomNavItem('lib/images/icons/ic_me.png', '我的', 3),
      ],
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(
      String assetPath, String label, int index) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        assetPath,
        width: 24.0,
        height: 24.0,
        color: widget.selectedIndex == index ? FmColors.primary : Colors.grey,
      ),
      label: label,
    );
  }
}
