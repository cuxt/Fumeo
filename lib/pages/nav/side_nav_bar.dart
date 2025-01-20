import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fumeo/controllers/side_nav.dart';
import 'package:fumeo/controllers/theme.dart';
import 'package:fumeo/controllers/update.dart';
import 'package:fumeo/pages/nav/components/menu_item.dart';
import 'package:fumeo/pages/nav/components/top_button.dart';
import 'package:get/get.dart';
import 'package:heroicons/heroicons.dart';

class SideNavBar extends StatefulWidget {
  const SideNavBar({super.key});

  @override
  State<SideNavBar> createState() => _SideNavBarState();
}

class _SideNavBarState extends State<SideNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _rotationAnimation;
  final UpdateController updateController = Get.find();
  final SideNavController controller = Get.find();
  final ThemeController themeController = Get.find();
  Worker? _worker;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    _worker = ever(updateController.isChecking, (bool checking) {
      if (!mounted) return;

      if (checking) {
        if (_animationController.isAnimating) {
          _animationController.stop();
        }
        _animationController.repeat();
      } else {
        if (_animationController.isAnimating) {
          _animationController
              .animateTo(
            1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCirc,
          )
              .then((_) {
            if (mounted) {
              _animationController.reset();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _playSingleRotation() {
    if (!mounted) return;
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NavTopButton(
                  icon: AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 2 * pi,
                        child: child,
                      );
                    },
                    child: const HeroIcon(
                      HeroIcons.arrowPath,
                      style: HeroIconStyle.outline,
                    ),
                  ),
                  onPressed: () {
                    if (!updateController.isChecking.value) {
                      _playSingleRotation();
                      updateController.checkUpdate();
                    }
                  },
                  isDark: isDark,
                ),
                NavTopButton(
                  icon: Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: HeroIcon(
                        themeController.isDarkMode.value
                            ? HeroIcons.sun
                            : HeroIcons.moon,
                        style: HeroIconStyle.outline,
                        key: ValueKey(themeController.isDarkMode.value),
                      ),
                    ),
                  ),
                  onPressed: () async => await themeController.toggleTheme(),
                  isDark: isDark,
                ),
                NavTopButton(
                  icon: const HeroIcon(
                    HeroIcons.beaker,
                    style: HeroIconStyle.outline,
                  ),
                  onPressed: () {
                    Get.defaultDialog(
                      title: '实验室',
                      titleStyle: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor:
                          isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      content: Text(
                        '敬请期待！',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('确定'),
                        ),
                      ],
                      radius: 12,
                    );
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                ...controller.menuItems.map(
                  (item) => NavMenuItem(
                    icon: item.icon,
                    title: item.title,
                    color: item.color,
                    onTap: () => controller.handleMenuItemTap(item.route),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withAlpha(26)
                      : Colors.black.withAlpha(26),
                ),
                const SizedBox(height: 16),
                ...controller.settingsItems.map(
                  (item) => NavMenuItem(
                    icon: item.icon,
                    title: item.title,
                    color: item.color,
                    onTap: () => controller.handleMenuItemTap(item.route),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
