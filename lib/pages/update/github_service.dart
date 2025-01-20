import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class GithubService {
  static const String owner = 'cuxt';
  static const String repo = 'fumeo';

  static const String apiUrl =
      'https://api.github.com/repos/$owner/$repo/releases/latest';

  static final Dio _dio = Dio();

  // 检查更新
  static Future<Map<String, dynamic>> checkUpdate() async {
    try {
      // 获取当前应用版本
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (kDebugMode) {
        print(packageInfo);
      }
      String currentVersion = packageInfo.version;
      // 获取最新release信息
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final releaseInfo = json.decode(response.body);
        if (kDebugMode) {
          print(releaseInfo);
        }
        String latestVersion =
            releaseInfo['tag_name'].toString().replaceAll('v', '');
        if (kDebugMode) {
          print(latestVersion);
        }
        bool hasUpdate = _compareVersions(currentVersion, latestVersion);

        if (hasUpdate || kDebugMode) {
          String? downloadUrl;
          List assets = releaseInfo['assets'];
          for (var asset in assets) {
            if (Platform.isAndroid &&
                asset['name'].toString().endsWith('.apk')) {
              downloadUrl = asset['browser_download_url'];
              if (kDebugMode) {
                print(downloadUrl);
              }
              break;
            } else if (Platform.isIOS &&
                asset['name'].toString().endsWith('.ipa')) {
              downloadUrl = asset['browser_download_url'];
              break;
            }
          }

          return {
            'hasUpdate': true,
            'version': latestVersion,
            'description': releaseInfo['body'] ?? '无更新说明',
            'downloadUrl': downloadUrl,
          };
        }
        return {'hasUpdate': false};
      }
      final responseData = json.decode(response.body);
      throw Exception(responseData['message']);
    } catch (e) {
      rethrow;
    }
  }

  // 下载更新包
  static Future<bool> downloadUpdate(
      String url, String savePath, Function(double) onProgress) async {
    try {
      // 获取重定向后的真实下载地址
      final response = await http.head(Uri.parse(url));
      String realUrl = response.headers['location'] ?? url;

      await _dio.download(
        realUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) {
            return status != null && status < 500;
          },
          headers: {
            'Accept': 'application/octet-stream',
          },
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // 版本号比较
  static bool _compareVersions(String currentVersion, String latestVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> latest = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }
    return false;
  }
}
