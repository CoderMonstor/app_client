import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:oktoast/oktoast.dart';

import '../../util/toast.dart';
import 'net.dart';

class NetRequester {
  // dio实例的配置
  static var options = BaseOptions(
    baseUrl:NetConfig.ip,
    contentType: Headers.formUrlEncodedContentType,
  );

  static Dio dio = Dio(options);
  // 使用 late 关键字延迟初始化 _response
  static late Response _response;

  // 再修改ip或端口后直接重设dio实例的baseUrl，不然请求的链接是不正确的，是旧的配置并没有更新
  static resetDio() {
    var newOptions = BaseOptions(
      baseUrl:NetConfig.ip,
      contentType: Headers.formUrlEncodedContentType,
    );
    dio = Dio(newOptions);
    if (kDebugMode) {
      print(dio.options.headers);
      print("::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
    }
  }

  /// 通用的网络请求方法，需传入@param[url]，
  /// @param[data]是可选参数，大部分[ApiAddress]返回的都是带参数的url，不需要[data]，提交审批结果那里是需要data的
  /// @param[file]也是可选参数，是上传图片的时候需要用到的
  static Future request(String url, {FormData? file, Map? data}) async {
    try {
      if (kDebugMode) {
        print('Full URL: ${options.baseUrl}$url'); // 打印完整 URL
/*
        print('Global profile ip: ${Global.profile.ip}');
        print('NetConfig ip: ${NetConfig.ip}');
 */
      }
      if (data != null) {
        _response = await dio.post(url, data: data);
      } else if (file != null) {
        _response = await dio.post(url, data: file);
      } else {
        _response = await dio.post(url);
      }
      // 获取验证码的时候需要cookie
      if (url.contains("sendEmail")) {
        var sessionId = _response.headers.value("set-cookie")?.substring(0, 43);
        if (sessionId != null) {
          if (dio.options.headers.containsKey('cookie')) {
            dio.options.headers['cookie'] = sessionId;
          } else {
            dio.options.headers.addAll({'cookie': sessionId});
          }
        }
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('dioError::::::::$e');
      }
      switch (e.type) {
        case DioExceptionType.cancel:
          Toast.popToast('请求已取消');
          break;
        case DioExceptionType.connectionTimeout:
          Toast.popToast('连接超时', ToastPosition.center);
          break;
        case DioExceptionType.receiveTimeout:
          Toast.popToast('接收数据超时', ToastPosition.center);
          break;
        case DioExceptionType.sendTimeout:
          Toast.popToast('发送请求超时', ToastPosition.center);
          break;
        case DioExceptionType.badResponse:
          Toast.popToast('网络出错', ToastPosition.center);
          break;
        case DioExceptionType.unknown:
          Toast.popToast('网络出错', ToastPosition.center);
        default:
          Toast.popToast('未知错误', ToastPosition.center);
      }
      rethrow;
    }
    // Log().i('返回的数据：' + _response.data.toString());
    return _response.data;
  }
}
