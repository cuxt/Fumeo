import 'package:flutter/material.dart';

class NavTopButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final bool isDark;

  const NavTopButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: IconTheme(
              data: IconThemeData(
                color: isDark ? Colors.white70 : Colors.black87,
                size: 20,
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
