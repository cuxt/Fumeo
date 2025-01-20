import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// 打开网页
Future<void> launchURL(String url) async {
  final Uri uri = Uri.parse(url);

  // 显示确认对话框
  final bool? confirm = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: Get.theme.dialogBackgroundColor,
      title: Text(
        '即将离开 Fumeo',
        style: TextStyle(
          color: Get.theme.textTheme.titleLarge?.color,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '您即将访问以下链接：',
            style: TextStyle(
              color: Get.theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            url,
            style: TextStyle(
              // 在深色模式下使用更亮的蓝色
              color: Get.theme.brightness == Brightness.dark
                  ? Colors.lightBlue[300]
                  : Get.theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '是否继续？',
            style: TextStyle(
              color: Get.theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actions: [
        // 取消按钮
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(
            '取消',
            style: TextStyle(
              color: Get.theme.brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
        ),
        // 确认按钮
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text(
            '确认',
            style: TextStyle(
              // 在深色模式下使用更亮的蓝色
              color: Get.theme.brightness == Brightness.dark
                  ? Colors.lightBlue[300]
                  : Get.theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
    barrierDismissible: false,
  );

  // 如果用户确认，则打开链接
  if (confirm == true) {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackbar('无法打开链接');
      }
    } catch (e) {
      _showErrorSnackbar('打开链接失败: ${e.toString()}');
    }
  }
}

// 显示错误提示的辅助方法
void _showErrorSnackbar(String message) {
  Get.snackbar(
    '错误',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Get.theme.brightness == Brightness.dark
        ? Colors.red.shade900
        : Colors.red,
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
    borderRadius: 8,
    snackStyle: SnackStyle.FLOATING,
  );
}
