import 'package:flutter/material.dart';
import 'package:fumeo/pages/update/github_service.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class UpdateDialog extends StatefulWidget {
  final Map<String, dynamic> updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  UpdateDialogState createState() => UpdateDialogState();
}

class UpdateDialogState extends State<UpdateDialog> {
  double _progress = 0.0;
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('发现新版本'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('最新版本: ${widget.updateInfo['version']}'),
          const SizedBox(height: 8),
          Text('更新内容:\n${widget.updateInfo['description']}'),
          if (_downloading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress),
            Text('下载进度: ${(_progress * 100).toStringAsFixed(1)}%'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _downloading ? null : _startDownload,
          child: const Text('更新'),
        ),
      ],
    );
  }

  Future<void> _startDownload() async {
    if (widget.updateInfo['downloadUrl'] == null) {
      _showMessage('未找到适配当前平台的安装包');
      return;
    }

    var status = await Permission.requestInstallPackages.status;
    if (status.isDenied) {
      status = await Permission.requestInstallPackages.request();
      if (status.isDenied) {
        _showMessage('需要安装应用权限才能更新，请在设置中开启');
        return;
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    setState(() {
      _downloading = true;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath =
          '${dir.path}/update${Platform.isAndroid ? '.apk' : '.ipa'}';

      bool success = await GithubService.downloadUpdate(
        widget.updateInfo['downloadUrl'],
        savePath,
        (progress) {
          setState(() {
            _progress = progress;
          });
        },
      );

      if (success) {
        if (Platform.isAndroid) {
          final result = await OpenFile.open(savePath);
          if (result.type != ResultType.done) {
            _showMessage('安装失败: ${result.message}');
          }
        } else if (Platform.isIOS) {
          _showMessage('iOS版本请通过App Store更新');
        }
      } else {
        _showMessage('下载更新失败');
      }
    } catch (e) {
      _showMessage('更新失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _downloading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
