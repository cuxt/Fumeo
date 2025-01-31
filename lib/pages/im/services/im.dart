import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_status.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class IMService extends GetxService {
  static int sdkAppID = int.parse(dotenv.env['TENCENT_SDKAPPID']!);
  final _loginState = false.obs;

  bool get isLoggedIn => _loginState.value;

  // 获取SDK实例
  final _timManager = TencentImSDKPlugin.v2TIMManager;

  Future<IMService> init() async {
    try {
      // 设置SDK监听器
      V2TimSDKListener sdkListener = V2TimSDKListener(
        onConnectFailed: (int code, String error) {
          if (kDebugMode) {
            print('连接失败: $code - $error');
          }
          _loginState.value = false;
        },
        onConnectSuccess: () {
          if (kDebugMode) {
            print('连接成功');
          }
          _loginState.value = true;
        },
        onConnecting: () {
          if (kDebugMode) {
            print('正在连接...');
          }
        },
        onKickedOffline: () {
          if (kDebugMode) {
            print('用户被踢下线');
          }
          _loginState.value = false;
          // 可以在这里添加重新登录的逻辑或者跳转到登录页面
          Get.offAllNamed('/login');
        },
        onSelfInfoUpdated: (V2TimUserFullInfo info) {
          if (kDebugMode) {
            print('用户资料更新: ${info.nickName}');
          }
          // 可以在这里更新用户信息到本地存储
        },
        onUserSigExpired: () {
          if (kDebugMode) {
            print('用户票据过期');
          }
          _loginState.value = false;
          // 可以在这里处理票据过期的逻辑
          Get.offAllNamed('/login');
        },
        onUserStatusChanged: (List<V2TimUserStatus> userStatusList) {
          if (kDebugMode) {
            print('用户状态变更: ${userStatusList.length}个用户');
          }
          // 可以在这里处理用户状态变更的逻辑
        },
      );

      // 初始化SDK
      V2TimValueCallback<bool> initSDKRes = await _timManager.initSDK(
        sdkAppID: sdkAppID,
        loglevel: LogLevelEnum.V2TIM_LOG_ALL,
        listener: sdkListener,
      );

      if (initSDKRes.code == 0) {
        if (kDebugMode) {
          print('腾讯云 IM SDK 初始化成功');
        }
        return this;
      } else {
        throw Exception('初始化失败: ${initSDKRes.code} - ${initSDKRes.desc}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('腾讯云 IM SDK 初始化异常: $e');
      }
      rethrow;
    }
  }

  Future<bool> login(String userID, String userSig) async {
    try {
      V2TimCallback result = await _timManager.login(
        userID: userID,
        userSig: userSig,
      );

      if (result.code == 0) {
        _loginState.value = true;
        return true;
      } else {
        if (kDebugMode) {
          print('登录失败：${result.code} - ${result.desc}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('登录异常：$e');
      }
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      V2TimCallback result = await _timManager.logout();
      if (result.code == 0) {
        _loginState.value = false;
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('登出异常：$e');
      }
      return false;
    }
  }

  // 获取当前登录用户信息
  Future<V2TimUserFullInfo?> getSelfUserInfo() async {
    try {
      var result = await _timManager.getUsersInfo(userIDList: []);
      if (result.code == 0 && result.data!.isNotEmpty) {
        return result.data![0];
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('获取用户信息异常：$e');
      }
      return null;
    }
  }
}
