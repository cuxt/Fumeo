import 'package:flutter/material.dart';
import 'services/feature_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fumeo/core/providers/app_state.dart';
import 'package:fumeo/features/note/models/note_item.dart';
import 'package:fumeo/features/todo/models/todo_item.dart';
import 'package:fumeo/features/note/screens/note_detail_screen.dart';
import 'widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 动画控制器 - 用于控制边缘手势提示动画
  late AnimationController _hintController;
  late Animation<Offset> _hintAnimation;
  bool _showDrawerHint = false;

  // 使用FeatureService获取功能列表
  final FeatureService _featureService = FeatureService();

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _hintAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _hintController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  // 显示侧边栏提示
  void _showSidebarHint() {
    if (!_showDrawerHint) {
      setState(() {
        _showDrawerHint = true;
      });
      _hintController.forward().then((_) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _hintController.reverse().then((_) {
              setState(() {
                _showDrawerHint = false;
              });
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 只需获取AppState实例
    Provider.of<AppState>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      // 侧边栏 - 显示所有功能
      drawer: AppDrawer(featureMap: _featureService.getDrawerFeatures()),

      // 应用栏
      appBar: AppBar(
        title: const Text('Fumeo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          // 添加设置按钮
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),

      // 主体内容
      body: GestureDetector(
        // 保留水平拖动手势功能
        onHorizontalDragStart: (details) {
          if (details.localPosition.dx < 20) {
            _showSidebarHint();
          }
        },
        onHorizontalDragUpdate: (details) {
          if (details.primaryDelta != null &&
              details.primaryDelta! > 0 &&
              details.localPosition.dx >
                  MediaQuery.of(context).size.width * 0.15) {
            _scaffoldKey.currentState?.openDrawer();
          }
        },

        // 新的主页内容区
        child: Stack(
          children: [
            // 主要内容 - 使用ListView而不是Column以支持滚动
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                children: [
                  // 欢迎信息
                  _buildWelcomeSection(context),

                  const SizedBox(height: 24),

                  // 主要功能区
                  _buildMainFeaturesSection(context),

                  const SizedBox(height: 24),

                  // 最近使用的笔记/待办事项区域
                  _buildRecentItemsSection(context),
                ],
              ),
            ),

            // 侧边栏提示动画(保持原有功能)
            if (_showDrawerHint)
              Positioned(
                left: 0,
                top: MediaQuery.of(context).size.height * 0.4,
                child: SlideTransition(
                  position: _hintAnimation,
                  child: Container(
                    width: 40,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: 230,
                      ), // 0.9 * 255 = 229.5 ≈ 230
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),

            // 悬浮按钮
            Positioned(
              right: 20,
              bottom: 20,
              child: _buildQuickActionButton(context),
            ),
          ],
        ),
      ),
    );
  }

  // 欢迎区域
  Widget _buildWelcomeSection(BuildContext context) {
    // 获取当前时间，用于显示不同的问候语
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = '早上好';
    } else if (hour < 18) {
      greeting = '下午好';
    } else {
      greeting = '晚上好';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '欢迎使用Fumeo应用',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // 主要功能区
  Widget _buildMainFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            '主要功能',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),

        // 功能卡片网格
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildFeatureCard(
              context,
              '笔记',
              Icons.note_alt_outlined,
              Theme.of(context).colorScheme.primary,
              () => context.go('/note'),
            ),
            _buildFeatureCard(
              context,
              '待办事项',
              Icons.check_circle_outline,
              Colors.green,
              () => context.go('/todo'),
            ),
            _buildFeatureCard(
              context,
              '探索',
              Icons.explore_outlined,
              Colors.orange,
              () => context.go('/explore'),
            ),
            _buildFeatureCard(
              context,
              '主题设置',
              Icons.color_lens_outlined,
              Colors.purple,
              () => context.go('/settings/theme'),
            ),
          ],
        ),
      ],
    );
  }

  // 单个功能卡片
  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 最近项目区域
  Widget _buildRecentItemsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近项目',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        // 只使用Consumer<AppState>
        Consumer<AppState>(
          builder: (context, appState, child) {
            // 合并笔记和待办事项到一个列表，并按更新/创建时间排序
            final recentItems = _getRecentItems(appState);

            if (recentItems.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '暂无最近项目',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children:
                  recentItems.take(5).map((item) {
                    if (item is NoteItem) {
                      // 构建笔记卡片
                      return _buildNoteCard(context, item, () {
                        // 点击笔记时导航到笔记详情页
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChangeNotifierProvider.value(
                                  value: appState,
                                  child: NoteDetailScreen(noteId: item.id),
                                ),
                          ),
                        );
                      });
                    } else if (item is TodoItem) {
                      // 构建待办事项卡片
                      return _buildTodoCard(context, item, () {
                        // 点击待办时导航到待办列表页
                        context.go('/todo');
                      });
                    }
                    return const SizedBox.shrink();
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  // 从笔记和待办事项中获取最近项目 - 修改为只接收AppState参数
  List<dynamic> _getRecentItems(AppState appState) {
    final notes = appState.noteProvider.notes;
    final todos = appState.todoProvider.items; // 现在通过appState获取待办事项

    // 合并两个列表
    final allItems = <dynamic>[];
    allItems.addAll(notes);
    allItems.addAll(todos);

    // 根据更新时间排序（笔记用updatedAt，待办用createdAt）
    allItems.sort((a, b) {
      final DateTime timeA = a is NoteItem ? a.updatedAt : a.createdAt;
      final DateTime timeB = b is NoteItem ? b.updatedAt : b.createdAt;
      return timeB.compareTo(timeA); // 降序排序，最新的排在前面
    });

    return allItems;
  }

  // 构建笔记卡片
  Widget _buildNoteCard(
    BuildContext context,
    NoteItem note,
    VoidCallback onTap,
  ) {
    // 从笔记内容中提取摘要（去掉Markdown标记）
    final summary = _extractNoteSummary(note.content);

    return _buildRecentItemCard(
      context,
      note.title,
      summary,
      Icons.note_alt_outlined,
      note.updatedAt,
      onTap,
    );
  }

  // 构建待办事项卡片
  Widget _buildTodoCard(
    BuildContext context,
    TodoItem todo,
    VoidCallback onTap,
  ) {
    final statusText = todo.completed ? '（已完成）' : '（待完成）';

    return _buildRecentItemCard(
      context,
      todo.title,
      '待办事项 $statusText',
      Icons.check_circle_outline,
      todo.createdAt,
      onTap,
      backgroundColor:
          todo.completed
              ? Colors.green.withValues(alpha: 26)
              : null, // 0.1 * 255 = 25.5 ≈ 26
      iconColor:
          todo.completed ? Colors.green : Theme.of(context).colorScheme.primary,
    );
  }

  // 从笔记内容中提取摘要（简化版本的Markdown解析）
  String _extractNoteSummary(String content) {
    if (content.isEmpty) {
      return '空笔记';
    }

    // 简单移除一些常见的Markdown标记
    final plainText = content
        .replaceAll(RegExp(r'#{1,6}\s'), '') // 标题
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // 粗体
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // 斜体
        .replaceAll(RegExp(r'```.*?```', dotAll: true), '') // 代码块
        .replaceAll(RegExp(r'`(.*?)`'), r'$1') // 行内代码
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1') // 链接
        .replaceAll(RegExp(r'!\[(.*?)\]\(.*?\)'), '[图片]') // 图片
        .replaceAll(RegExp(r'^\s*[-+*]\s', multiLine: true), '') // 列表
        .replaceAll(RegExp(r'^\s*\d+\.\s', multiLine: true), ''); // 有序列表

    return plainText.trim();
  }

  // 单个最近项目卡片
  Widget _buildRecentItemCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    DateTime time,
    VoidCallback onTap, {
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(time),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  // 悬浮操作按钮
  Widget _buildQuickActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showQuickActionMenu(context);
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.add),
    );
  }

  // 快速操作菜单
  void _showQuickActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '创建新内容',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.note_add,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('新建笔记'),
                onTap: () {
                  Navigator.pop(context);
                  // 导航到新建笔记页面
                  context.go('/note');
                },
              ),
              ListTile(
                leading: Icon(Icons.add_task, color: Colors.green),
                title: const Text('新建待办'),
                onTap: () {
                  Navigator.pop(context);
                  // 导航到新建待办页面
                  context.go('/todo');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
