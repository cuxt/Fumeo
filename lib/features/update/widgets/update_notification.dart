import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:provider/provider.dart';
import '../providers/update_controller.dart';

class UpdateNotification {
  // 显示更新通知
  static void show(Map<String, dynamic> updateInfo) {
    // 使用全局 key 来获取当前 BuildContext
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    final context = navigatorKey.currentContext;

    if (context != null) {
      _showSnackBar(context, updateInfo);
    }
  }

  // 在应用中构建更新按钮和徽标
  static Widget buildUpdateButton(BuildContext context) {
    final updateController = Provider.of<UpdateController>(context);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.system_update_alt),
          tooltip: '检查更新',
          onPressed: () => updateController.checkForUpdates(context),
        ),
        if (updateController.isChecking)
          Positioned(
            right: 8,
            top: 8,
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 显示自定义 SnackBar
  static void _showSnackBar(
      BuildContext context, Map<String, dynamic> updateInfo) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: '发现新版本',
        message: '新版本 ${updateInfo['version']} 可供下载，点击查看详情',
        contentType: ContentType.success,
      ),
      action: SnackBarAction(
        label: '查看',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          final updateController =
              Provider.of<UpdateController>(context, listen: false);
          updateController.checkForUpdates(context);
        },
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // 在首次启动时显示的版本更新气泡提示
  static void showUpdateTooltip(BuildContext context, GlobalKey buttonKey) {
    final RenderBox? renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + size.height,
        left: position.dx - 100, // 气泡宽度的一半
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '发现新版本可用',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '点击这里更新到最新版本',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      entry?.remove();
                    },
                    child: Text(
                      '知道了',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(entry);

    // 5秒后自动关闭
    Future.delayed(const Duration(seconds: 5), () {
      entry?.remove();
    });
  }
}
