import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fumeo/core/providers/app_state.dart';
import 'package:fumeo/features/update/providers/update_controller.dart';
import 'package:fumeo/core/services/feature_service.dart'; // 导入功能服务
import 'widgets/app_drawer.dart';
import 'widgets/home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String searchText = '';
  final FocusNode _focusNode = FocusNode();
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
    ).animate(CurvedAnimation(
      parent: _hintController,
      curve: Curves.easeOutCubic,
    ));

    // 在首页初始化时检查更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  void _checkForUpdates() {
    final updateController =
        Provider.of<UpdateController>(context, listen: false);
    updateController.checkForUpdates(context);
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
    return Scaffold(
      key: _scaffoldKey,
      // 侧边栏 - 只显示标记为在侧边栏显示的功能
      drawer: AppDrawer(
        featureMap: _featureService.getDrawerFeatures(),
      ),

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
          // 添加检查更新按钮
          IconButton(
            icon: const Icon(Icons.system_update),
            onPressed: _checkForUpdates,
            tooltip: '检查更新',
          ),
        ],
      ),

      // 主体内容
      body: GestureDetector(
        // 监听水平拖动手势，从左边缘向右滑动打开侧边栏
        onHorizontalDragStart: (details) {
          // 如果是从屏幕左边缘开始拖动
          if (details.localPosition.dx < 20) {
            _showSidebarHint();
          }
        },
        onHorizontalDragUpdate: (details) {
          // 如果拖动距离超过屏幕宽度的15%，打开侧边栏
          if (details.primaryDelta != null &&
              details.primaryDelta! > 0 &&
              details.localPosition.dx >
                  MediaQuery.of(context).size.width * 0.15) {
            _scaffoldKey.currentState?.openDrawer();
          }
        },

        // 主内容区
        child: Stack(
          children: [
            // 主内容 - 只显示标记为在首页显示的功能
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: HomeContent(
                    featureMap: _featureService.getHomeFeatures(),
                    searchText: searchText,
                    focusNode: _focusNode,
                  ),
                ),
              ),
            ),

            // 侧边栏提示动画
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
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.9),
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
          ],
        ),
      ),

      // 悬浮按钮 - 主题切换
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showThemeSelector(context);
        },
        tooltip: '切换主题',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.color_lens),
      ),
    );
  }

  // 主题选择器弹窗
  void _showThemeSelector(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final themeManager = appState.themeManager;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '选择主题颜色',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.blue),
                title: const Text('蓝色主题'),
                onTap: () {
                  themeManager.setPrimaryColor(Colors.blue);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.green),
                title: const Text('绿色主题'),
                onTap: () {
                  themeManager.setPrimaryColor(Colors.green);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.red),
                title: const Text('红色主题'),
                onTap: () {
                  themeManager.setPrimaryColor(Colors.red);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.purple),
                title: const Text('紫色主题'),
                onTap: () {
                  themeManager.setPrimaryColor(Colors.purple);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
