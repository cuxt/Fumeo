import 'package:flutter/material.dart';
import 'package:fumeo/controllers/nav.dart';
import 'package:fumeo/pages/explore/explore.dart';
import 'package:fumeo/pages/home/home.dart';
import 'package:fumeo/pages/mine/mine.dart';
import 'package:fumeo/pages/nav/bottom_nav_bar.dart';
import 'package:fumeo/pages/todo/todo.dart';
import 'package:get/get.dart';

class NavView extends GetView<NavController> {
  NavView({super.key});

  final List<Widget> _pages = [
    const HomeView(),
    const TodoView(),
    const ExploreView(),
    const MineView(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final shouldPop = await controller.onWillPop();
        if (shouldPop) {
          Get.back(result: result);
        }
      },
      child: Scaffold(
        body: Obx(
              () => IndexedStack(
            index: controller.currentIndex,
            children: _pages,
          ),
        ),
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }
}
