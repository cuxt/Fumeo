import 'package:flutter/material.dart';
import 'package:fumeo/controllers/explore.dart';
import 'package:fumeo/pages/nav/side_nav_bar.dart';
import 'package:get/get.dart';
import 'components/feature_card.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Icon(Icons.menu),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 实现搜索功能
            },
          ),
        ],
      ),
      drawer: const SideNavBar(),
      body: Obx(
            () => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.features.length,
          itemBuilder: (context, index) {
            final feature = controller.features[index];
            return FeatureCard(
              title: feature['title'] as String,
              icon: feature['icon'] as IconData,
              color: feature['color'] as Color,
              onTap: () => controller.handleFeatureTap(index),
            );
          },
        ),
      ),
    );
  }
}
