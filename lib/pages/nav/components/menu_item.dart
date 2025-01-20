import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class NavMenuItem extends StatelessWidget {
  final HeroIcons icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const NavMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? color.withAlpha(51)
                : color.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: HeroIcon(
            icon,
            style: HeroIconStyle.outline,
            color: isDark ? color.withAlpha(230) : color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        minLeadingWidth: 20,
        horizontalTitleGap: 12,
        onTap: onTap,
        hoverColor: isDark
            ? Colors.white.withAlpha(179)
            : Colors.black.withAlpha(122),
      ),
    );
  }
}
