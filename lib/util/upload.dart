import 'package:client/core/net/net.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';


class UpLoad {
  static final Dio _dio=MyDio.createDio();
  static Response? _response; // 修改为可空类型并初始化为 null

  // 上传图片
  static Future<int> upLoad(Uint8List fileData, String filename) async {


    FormData formData = FormData.fromMap({"file": MultipartFile.fromBytes(fileData, filename: filename)});

    try {
      _response = await _dio.post("/upLoad", data: formData,
          onSendProgress: (send, total) {
            if (kDebugMode) {
              print('${(send / total * 100).toStringAsFixed(2)}% total ${(total / 1024).toStringAsFixed(2)}k');
            }
          });
      return _response?.data as int;
    } catch (e) {
      throw Exception('上传失败: $e');
    }
  }
}

class MyDio {
  static late Dio dio;

  static Dio createDio() {
      var options = BaseOptions(
        baseUrl: NetConfig.ip,
        contentType: Headers.formUrlEncodedContentType,
      );
      dio = Dio(options);
    return dio;
  }
}