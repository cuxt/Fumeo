import 'package:flutter/material.dart';
import 'widgets/feature_list_item.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('探索'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 欢迎文本
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              'Fumeo 探索中心',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 功能卡片
          _buildSectionTitle(context, '推荐功能'),

          FeatureListItem(
            title: 'Markdown笔记',
            description: '使用Markdown格式创建和编辑笔记，支持实时预览。',
            icon: Icons.edit_note,
            color: Colors.blue,
            onTap: () {},
          ),

          FeatureListItem(
            title: '待办事项',
            description: '创建和管理您的待办事项，提高工作效率。',
            icon: Icons.check_circle_outline,
            color: Colors.green,
            onTap: () {},
          ),

          _buildSectionTitle(context, '即将推出'),

          FeatureListItem(
            title: '即时通讯',
            description: '与团队成员进行实时沟通和协作。',
            icon: Icons.chat_bubble_outline,
            color: Colors.orange,
            onTap: () {},
            isComingSoon: true,
          ),

          FeatureListItem(
            title: '云同步',
            description: '将您的笔记和待办事项同步到云端，随时随地访问。',
            icon: Icons.cloud_sync,
            color: Colors.purple,
            onTap: () {},
            isComingSoon: true,
          ),

          _buildSectionTitle(context, '关于 Fumeo'),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Fumeo 是一款注重简洁性和实用性的生产力工具，旨在帮助您更好地组织思想、管理任务并提高工作效率。',
              style: TextStyle(fontSize: 16),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
