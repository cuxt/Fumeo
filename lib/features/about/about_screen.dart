import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _version = '未知';
        _buildNumber = '未知';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  // 顶部应用栏
                  SliverAppBar(
                    expandedHeight: 240,
                    pinned: true,
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text('关于'),
                      centerTitle: true,
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 渐变背景
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary.withAlpha(150),
                                ],
                              ),
                            ),
                          ),
                          // 装饰图案
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.1,
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                    ),
                                itemCount: 64,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder:
                                    (_, __) => Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          // Logo和应用信息
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Hero(
                                  tag: 'app_logo',
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(50),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Image.asset(
                                      'assets/img/logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Fumeo',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'v$_version ($_buildNumber)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 内容部分
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 应用描述卡片
                          _buildInfoCard(
                            context: context,
                            title: '应用简介',
                            content:
                                'Fumeo是一款简洁高效的笔记和待办事项管理工具，帮助您更高效地组织思想和任务。采用现代化设计，同时保证轻量快速的使用体验。',
                            icon: Icons.info_outline_rounded,
                          ),

                          const SizedBox(height: 24),

                          // 功能特点部分
                          _buildFeaturesList(context),

                          const SizedBox(height: 24),

                          // 开发团队部分
                          _buildTeamSection(context),

                          const SizedBox(height: 24),

                          // 联系方式和社交媒体
                          _buildContactSection(context),

                          const SizedBox(height: 32),

                          // 版权信息
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  '© ${DateTime.now().year} Fumeo Team',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '保留所有权利',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  // 信息卡片
  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // 功能特点列表
  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {
        'icon': Icons.article_outlined,
        'title': 'Markdown笔记',
        'description': '支持Markdown格式编辑和预览，轻松创建格式丰富的笔记',
      },
      {
        'icon': Icons.check_circle_outline,
        'title': '任务管理',
        'description': '简洁高效的待办事项管理，帮助您合理规划时间和任务',
      },
      {
        'icon': Icons.color_lens,
        'title': '主题定制',
        'description': '多种主题颜色选择，打造个性化使用体验',
      },
      {
        'icon': Icons.devices,
        'title': '多设备支持',
        'description': '支持在多种设备上使用，数据随时随地同步',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
          child: Text(
            '主要功能',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...features.map(
          (feature) => _buildFeatureItem(
            context: context,
            icon: feature['icon'] as IconData,
            title: feature['title'] as String,
            description: feature['description'] as String,
          ),
        ),
      ],
    );
  }

  // 单个功能项
  Widget _buildFeatureItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withAlpha(50), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withAlpha(100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 开发团队部分
  Widget _buildTeamSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
          child: Text(
            '开发团队',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.withAlpha(25), width: 1),
          ),
          child: Column(
            children: [
              Text(
                'Fumeo是一个致力于创造简单高效工具的小型团队，我们希望通过简洁的设计和实用的功能，帮助您更高效地管理日常工作和生活。',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTeamMember(
                    context: context,
                    role: '设计',
                    icon: Icons.design_services,
                  ),
                  const SizedBox(width: 24),
                  _buildTeamMember(
                    context: context,
                    role: '开发',
                    icon: Icons.code,
                  ),
                  const SizedBox(width: 24),
                  _buildTeamMember(
                    context: context,
                    role: '测试',
                    icon: Icons.bug_report,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 团队成员展示
  Widget _buildTeamMember({
    required BuildContext context,
    required String role,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withAlpha(100),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          role,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // 联系方式部分
  Widget _buildContactSection(BuildContext context) {
    final contactOptions = [
      {
        'icon': Icons.code,
        'title': 'GitHub开源仓库',
        'action': () async {
          final url = Uri.parse('https://github.com/cuxt/fumeo');
          await launchUrl(url, mode: LaunchMode.externalApplication);
        },
      },
      {
        'icon': Icons.email_outlined,
        'title': '发送邮件反馈',
        'action': () async {
          final Uri emailUri = Uri(
            scheme: 'mailto',
            path: 'vua@live.com',
            queryParameters: {
              'subject': 'Fumeo应用反馈',
              'body': '设备信息：\n应用版本：$_version ($_buildNumber)\n\n问题描述：\n',
            },
          );
          await launchUrl(emailUri);
        },
      },
      {
        'icon': Icons.star_outline,
        'title': '应用商店评分',
        'action': () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('感谢您的支持！'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
          child: Text(
            '联系我们',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...contactOptions.map(
          (option) => _buildContactOption(
            context: context,
            icon: option['icon'] as IconData,
            title: option['title'] as String,
            onTap: option['action'] as Function(),
          ),
        ),
      ],
    );
  }

  // 单个联系选项
  Widget _buildContactOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withAlpha(50), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
