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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 顶部背景和应用图标
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // 顶部背景
                      Container(
                        width: double.infinity,
                        height: 150,
                        color: colorScheme.primary,
                      ),

                      // 应用图标（位于背景下方，部分露出）
                      Positioned(
                        bottom: -50,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.9),
                              ),
                              child: Center(
                                // 这里使用Icon作为临时替代，您可以替换为实际的应用图标
                                child: Icon(
                                  Icons.note_alt_outlined,
                                  size: 60,
                                  color: Colors.white,
                                ),
                                // 若要使用实际应用图标，请取消下面注释并提供正确的图标路径
                                // child: Image.asset(
                                //   'assets/img/app_icon.png',
                                //   width: 100,
                                //   height: 100,
                                //   fit: BoxFit.cover,
                                // ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 70),

                  // 应用名称和版本
                  Text(
                    'Fumeo',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'v$_version ($_buildNumber)',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 分隔线
                  Divider(color: Colors.grey[300]),

                  // 应用描述
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Card(
                      elevation: 0,
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Fumeo是一款简洁高效的笔记和待办事项管理工具，帮助您更高效地组织思想和任务。',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),

                  // 分隔线
                  Divider(color: Colors.grey[300]),

                  // 功能特点
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildSectionTitle(context, '主要功能'),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          context: context,
                          icon: Icons
                              .article_outlined, // 使用 article_outlined 替代 markdown
                          title: 'Markdown笔记',
                          description: '支持Markdown格式的笔记编辑和预览',
                        ),
                        _buildFeatureCard(
                          context: context,
                          icon: Icons.check_circle_outline,
                          title: '待办事项',
                          description: '简洁易用的待办事项管理',
                        ),
                        _buildFeatureCard(
                          context: context,
                          icon: Icons.color_lens,
                          title: '主题定制',
                          description: '支持多种主题颜色选择',
                        ),
                      ],
                    ),
                  ),

                  // 联系方式
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    child: Column(
                      children: [
                        _buildSectionTitle(context, '联系我们'),
                        const SizedBox(height: 16),

                        // GitHub链接
                        Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading:
                                Icon(Icons.code, color: colorScheme.primary),
                            title: const Text('GitHub开源仓库'),
                            trailing: Icon(Icons.open_in_new,
                                color: colorScheme.primary),
                            onTap: () =>
                                _launchURL('https://github.com/cuxt/fumeo'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 版权信息
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      '© ${DateTime.now().year} Fumeo Team. 保留所有权利。',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFeatureCard(
      {required BuildContext context,
      required IconData icon,
      required String title,
      required String description}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
