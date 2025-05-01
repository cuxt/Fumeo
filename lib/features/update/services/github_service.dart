import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ProgressCallback = void Function(double progress);

class GithubService {
  static const String apiUrl = 'https://api.github.com/repos';
  static const String repoOwner = 'yourusername'; // 请替换为您的实际GitHub用户名
  static const String repoName = 'fumeo';

  /// 获取当前更新源配置
  static Future<Map<String, String>> getUpdateSource() async {
    final prefs = await SharedPreferences.getInstance();
    final useGitHub = prefs.getBool('update_use_github') ?? true;
    final customApiUrl = prefs.getString('update_custom_api') ?? '';

    if (useGitHub || customApiUrl.isEmpty) {
      return {
        'type': 'github',
        'url': apiUrl,
        'owner': repoOwner,
        'repo': repoName
      };
    } else {
      return {
        'type': 'custom',
        'url': customApiUrl,
      };
    }
  }

  /// 设置更新源
  static Future<void> setUpdateSource(
      {bool? useGitHub, String? customApiUrl}) async {
    final prefs = await SharedPreferences.getInstance();
    if (useGitHub != null) {
      await prefs.setBool('update_use_github', useGitHub);
    }
    if (customApiUrl != null) {
      await prefs.setString('update_custom_api', customApiUrl);
    }
  }

  /// 检查更新
  static Future<Map<String, dynamic>?> checkForUpdates(
      String currentVersion) async {
    try {
      final source = await getUpdateSource();

      if (source['type'] == 'github') {
        return await _checkGithubUpdates(
            source['url']!, source['owner']!, source['repo']!, currentVersion);
      } else {
        return await _checkCustomServerUpdates(source['url']!, currentVersion);
      }
    } catch (e) {
      debugPrint('检查更新失败: $e');
      return null;
    }
  }

  /// 从GitHub检查更新
  static Future<Map<String, dynamic>?> _checkGithubUpdates(
      String apiUrl, String owner, String repo, String currentVersion) async {
    try {
      // 添加缓存系数防止GitHub API限流
      final cacheBreaker = DateTime.now().millisecondsSinceEpoch;
      final response = await http.get(
        Uri.parse('$apiUrl/$owner/$repo/releases/latest?_cb=$cacheBreaker'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name'].toString().replaceAll('v', '');

        // 检查新版本
        if (_isNewerVersion(latestVersion, currentVersion)) {
          final List<Map<String, String>> downloadUrls = [];

          for (final asset in data['assets']) {
            downloadUrls.add({
              'name': asset['name'],
              'url': asset['browser_download_url'],
              'isCustom': 'false',
            });
          }

          return {
            'version': latestVersion,
            'description': data['body'] ?? '无更新说明',
            'downloadUrls': downloadUrls,
            'publishedAt': data['published_at'] ?? '',
            'isPrerelease': data['prerelease'] ?? false,
          };
        }
      } else if (response.statusCode == 403) {
        // GitHub API限流，记录错误
        debugPrint('GitHub API限流，请稍后再试');
        return {
          'error': 'rate_limited',
          'message': 'GitHub API限流，请稍后再试',
        };
      }
      return null;
    } catch (e) {
      debugPrint('从GitHub检查更新失败: $e');
      return null;
    }
  }

  /// 从自定义服务器检查更新
  static Future<Map<String, dynamic>?> _checkCustomServerUpdates(
      String apiUrl, String currentVersion) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['version'].toString();

        // 检查新版本
        if (_isNewerVersion(latestVersion, currentVersion)) {
          return {
            'version': latestVersion,
            'description': data['description'] ?? '无更新说明',
            'downloadUrls': List<Map<String, String>>.from(
              data['downloadUrls']?.map((url) => {
                        'name': url['name'] ?? '',
                        'url': url['url'] ?? '',
                        'isCustom': url['isCustom'] ?? 'false',
                      }) ??
                  [],
            ),
            'publishedAt': data['publishedAt'] ?? '',
            'isPrerelease': data['isPrerelease'] ?? false,
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('从自定义服务器检查更新失败: $e');
      return null;
    }
  }

  /// 下载更新
  static Future<bool> downloadUpdate(
    String url,
    String savePath,
    ProgressCallback onProgress,
  ) async {
    try {
      // 配置Dio
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 60);

      // 添加重试机制
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          await dio.download(
            url,
            savePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = received / total;
                onProgress(progress);
              }
            },
          );
          return true;
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) rethrow;

          // 延迟一段时间后重试
          await Future.delayed(
              Duration(seconds: math.pow(2, retryCount).toInt()));
          debugPrint('下载重试 $retryCount/$maxRetries');
        }
      }

      return false;
    } catch (e) {
      debugPrint('下载更新失败: $e');
      return false;
    }
  }

  /// 版本比较
  static bool _isNewerVersion(String latestVersion, String currentVersion) {
    final latestParts = latestVersion.split('.');
    final currentParts = currentVersion.split('.');

    for (int i = 0;
        i < math.min(latestParts.length, currentParts.length);
        i++) {
      final latest = int.parse(latestParts[i]);
      final current = int.parse(currentParts[i]);

      if (latest > current) {
        return true;
      } else if (latest < current) {
        return false;
      }
    }

    return latestParts.length > currentParts.length;
  }

  /// 测试更新服务器连接
  static Future<Map<String, dynamic>> testUpdateServer(String apiUrl) async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          if (data.containsKey('version')) {
            return {
              'success': true,
              'message': '连接成功，当前最新版本：${data['version']}',
              'data': data,
            };
          } else {
            return {
              'success': false,
              'message': '响应格式不正确，缺少版本信息',
            };
          }
        } catch (e) {
          return {
            'success': false,
            'message': '解析响应内容失败：$e',
          };
        }
      } else {
        return {
          'success': false,
          'message': '服务器返回错误码：${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '连接失败：$e',
      };
    }
  }
}
