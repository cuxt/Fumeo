import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/github_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateDialog extends StatefulWidget {
  final Map<String, dynamic> updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  UpdateDialogState createState() => UpdateDialogState();
}

class UpdateDialogState extends State<UpdateDialog> {
  double _progress = 0.0;
  bool _downloading = false;
  String? _selectedDownloadUrl;
  String _currentDescription = '';
  bool _remindLater = false;

  @override
  void initState() {
    super.initState();
    String version = widget.updateInfo['version'] as String;
    String customUrl = 'https://cloud.xbxin.com/app/fumeo/v$version.apk';

    final List<Map<String, String>> downloadUrls = [
      ...widget.updateInfo['downloadUrls'] as List<Map<String, String>>,
      {
        'name': 'custom_arm64-v8a.apk',
        'url': customUrl,
        'isCustom': 'true',
      }
    ];

    if (downloadUrls.isNotEmpty) {
      // 尝试自动选择适合当前设备的版本
      String? preferredUrl = _getPreferredDownloadUrl(downloadUrls);
      _selectedDownloadUrl = preferredUrl ?? downloadUrls.first['url'];

      final selectedItem = downloadUrls.firstWhere(
        (item) => item['url'] == _selectedDownloadUrl,
        orElse: () => {'name': '', 'url': '', 'isCustom': 'false'},
      );

      _currentDescription = _getArchitectureDescription(
          selectedItem['name'] ?? '', selectedItem['isCustom'] == 'true');
    }

    // 记录最近一次显示更新的版本
    _saveLastUpdateVersion(version);
  }

  String? _getPreferredDownloadUrl(List<Map<String, String>> downloadUrls) {
    if (Platform.isAndroid) {
      // 检测当前Android设备CPU架构并选择合适的APK
      if (defaultTargetPlatform == TargetPlatform.android) {
        // 首选自建线路的arm64版本
        final armv8Custom = downloadUrls.firstWhere(
          (item) =>
              item['name']?.contains('arm64-v8a') == true &&
              item['isCustom'] == 'true',
          orElse: () => {'url': ''},
        );

        if (armv8Custom['url']?.isNotEmpty == true) {
          return armv8Custom['url'];
        }

        // 其次选择GitHub的arm64版本
        final armv8 = downloadUrls.firstWhere(
          (item) => item['name']?.contains('arm64-v8a') == true,
          orElse: () => {'url': ''},
        );

        if (armv8['url']?.isNotEmpty == true) {
          return armv8['url'];
        }

        // 最后选择通用版本
        final universal = downloadUrls.firstWhere(
          (item) => item['name']?.contains('universal') == true,
          orElse: () => {'url': ''},
        );

        if (universal['url']?.isNotEmpty == true) {
          return universal['url'];
        }
      }
    }
    return null;
  }

  Future<void> _saveLastUpdateVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_shown_update_version', version);
  }

  String _formatDisplayName(String fileName, bool isCustom) {
    if (isCustom) {
      return 'Android ARM64版本（自建）';
    }

    if (fileName.toLowerCase().endsWith('.apk')) {
      if (fileName.contains('arm64-v8a')) {
        return 'Android ARM64版本（GitHub）';
      } else if (fileName.contains('armeabi-v7a')) {
        return 'Android ARM32版本（GitHub）';
      } else if (fileName.contains('x86_64')) {
        return 'Android X86_64版本（GitHub）';
      } else if (fileName.contains('x86')) {
        return 'Android X86版本（GitHub）';
      } else if (fileName.contains('universal')) {
        return 'Android通用版本（GitHub）';
      } else {
        return 'Android版本（GitHub）';
      }
    } else if (fileName.toLowerCase().endsWith('.ipa')) {
      return 'iOS版本';
    }
    return fileName;
  }

  String _getArchitectureDescription(String fileName, bool isCustom) {
    if (isCustom) {
      return '自建线路，适用于搭载ARM64处理器的设备';
    }

    if (fileName.toLowerCase().endsWith('.apk')) {
      if (fileName.contains('arm64-v8a')) {
        return '适用于搭载ARM64处理器的设备（推荐）';
      } else if (fileName.contains('armeabi-v7a')) {
        return '适用于搭载ARM32处理器的设备（兼容老设备）';
      } else if (fileName.contains('x86_64')) {
        return '适用于搭载X86_64处理器的设备';
      } else if (fileName.contains('x86')) {
        return '适用于搭载X86处理器的设备';
      } else if (fileName.contains('universal')) {
        return '通用版本，支持所有架构（体积较大）';
      }
    }
    return '';
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.toLowerCase().endsWith('.apk')) {
      return Icons.android;
    } else if (fileName.toLowerCase().endsWith('.ipa')) {
      return Icons.apple;
    }
    return Icons.file_present;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String version = widget.updateInfo['version'] as String;
    String customUrl = 'https://cloud.xbxin.com/app/fumeo/v$version.apk';

    final List<Map<String, String>> downloadUrls = [
      ...widget.updateInfo['downloadUrls'] as List<Map<String, String>>,
      {
        'name': 'custom_arm64-v8a.apk',
        'url': customUrl,
        'isCustom': 'true',
      }
    ];

    return AlertDialog(
      backgroundColor: theme.dialogTheme.backgroundColor,
      title: Row(
        children: [
          Icon(
            Icons.system_update_alt,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '发现新版本',
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 版本号显示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer
                  .withValues(alpha: 128), // 0.5 * 255 = 127.5 ≈ 128
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '最新版本: ${widget.updateInfo['version']}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 更新内容
          Text(
            '更新内容:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: MarkdownBody(
                  data: widget.updateInfo['description'],
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    h1: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                    h2: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                    h3: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleSmall?.color,
                    ),
                    listBullet: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 下载版本选择
          if (downloadUrls.isNotEmpty) ...[
            Text(
              '选择下载版本',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey.withAlpha(75),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    value: _selectedDownloadUrl,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(8),
                    icon: Icon(Icons.arrow_drop_down,
                        color: theme.iconTheme.color),
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 14,
                    ),
                    dropdownColor: theme.dialogTheme.backgroundColor,
                    menuMaxHeight: 400,
                    items: downloadUrls.map((item) {
                      String fileName = item['name'] ?? '';
                      bool isCustom = item['isCustom'] == 'true';
                      String displayName =
                          _formatDisplayName(fileName, isCustom);

                      return DropdownMenuItem<String>(
                        value: item['url'],
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                _getFileIcon(fileName),
                                size: 20,
                                color: theme.iconTheme.color,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _downloading
                        ? null
                        : (String? newValue) {
                            final selectedItem = downloadUrls.firstWhere(
                              (item) => item['url'] == newValue,
                              orElse: () =>
                                  {'name': '', 'url': '', 'isCustom': 'false'},
                            );
                            setState(() {
                              _selectedDownloadUrl = newValue;
                              _currentDescription = _getArchitectureDescription(
                                  selectedItem['name'] ?? '',
                                  selectedItem['isCustom'] == 'true');
                            });
                          },
                  ),
                ),
              ),
            ),
            if (_currentDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _currentDescription,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ],

          // 下载进度条
          if (_downloading) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor:
                    isDark ? Colors.grey[800] : Colors.grey.withAlpha(26),
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '下载进度: ${(_progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                if (_progress > 0.05)
                  Text(
                    '剩余时间: ${_estimateRemainingTime()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
              ],
            ),
          ],

          // 稍后提醒选项
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _remindLater,
                onChanged: (value) {
                  setState(() {
                    _remindLater = value ?? false;
                  });
                },
              ),
              const SizedBox(width: 4),
              Text(
                '暂不更新，24小时后再提醒',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_remindLater) {
              _setRemindLater();
            }
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: theme.textTheme.bodyMedium?.color,
          ),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _downloading || _selectedDownloadUrl == null
              ? null
              : _startDownload,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: Text(_downloading ? '下载中...' : '更新'),
        ),
      ],
    );
  }

  String _estimateRemainingTime() {
    if (_progress <= 0) return '计算中...';

    int totalSeconds = ((1.0 - _progress) / (_progress * 0.05) * 10).round();

    if (totalSeconds > 60) {
      int minutes = totalSeconds ~/ 60;
      int seconds = totalSeconds % 60;
      return '$minutes分$seconds秒';
    } else {
      return '$totalSeconds秒';
    }
  }

  Future<void> _setRemindLater() async {
    // 设置24小时后再提醒
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final remindTime = now.add(const Duration(hours: 24));
    await prefs.setInt(
        'update_remind_later_time', remindTime.millisecondsSinceEpoch);
  }

  Future<void> _startDownload() async {
    if (_selectedDownloadUrl == null) {
      _showMessage('请选择下载地址');
      return;
    }

    if (Platform.isAndroid) {
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
    }

    setState(() {
      _downloading = true;
      _progress = 0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath =
          '${dir.path}/update${Platform.isAndroid ? '.apk' : '.ipa'}';

      bool success = await GithubService.downloadUpdate(
        _selectedDownloadUrl!,
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
