import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/feature_model.dart';
import 'feature_card.dart';
import 'package:fumeo/core/services/feature_service.dart';

class HomeContent extends StatelessWidget {
  final Map<String, List<FeatureModel>> featureMap;
  final String searchText;
  final FocusNode focusNode;

  const HomeContent({
    super.key,
    required this.featureMap,
    required this.searchText,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildContent(context),
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    final List<Widget> children = [];
    final featureService = FeatureService();

    // 根据搜索文本过滤功能
    final filteredFeatureMap = searchText.isEmpty
        ? featureMap
        : featureService.searchHomeFeatures(searchText);

    // 添加搜索栏
    children.add(Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchBar(
        hintText: '请输入功能名称',
        focusNode: focusNode,
        onChanged: (value) {
          // 搜索功能在父组件中处理
        },
      ),
    ));

    // 添加功能网格
    filteredFeatureMap.forEach((category, features) {
      // 如果该类别没有要显示的功能，则跳过
      if (features.isEmpty) {
        return;
      }

      final List<Widget> featureWidgets = [];

      for (final feature in features) {
        featureWidgets.add(
          FeatureCard(
            title: feature.text,
            onTap: () {
              focusNode.unfocus();
              context.go(feature.route);
            },
            color: Theme.of(context).colorScheme.primary,
            icon: feature.icon,
          ),
        );
      }

      // 显示类别标题
      children.add(
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
          ),
          child: Text(
            '$category(${featureWidgets.length})',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );

      // 使用网格布局显示功能卡片
      children.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2, // 每行2个卡片
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: featureWidgets,
          ),
        ),
      );
    });

    // 如果没有匹配的功能，显示空状态
    if (filteredFeatureMap.isEmpty) {
      children.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '没有找到匹配的功能',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return children;
  }
}
