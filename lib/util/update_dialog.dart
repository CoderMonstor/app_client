import 'dart:io';

import 'package:client/util/toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';


import '../core/net/net_request.dart';
import 'line/line_progress.dart';


/*
这个类是一个更新弹窗，用于提示用户更新应用。
* */
class UpdateDialog extends StatefulWidget{
  final Map? res;

  const UpdateDialog({super.key, this.res});

  @override
  State<StatefulWidget> createState() {
    return _UpdateDialogState();
  }

}

class _UpdateDialogState extends State<UpdateDialog> {
  late String url;
  //更新内容，字符串描述
  late String content ;
  late String version ;
  late double progress = 0.0;
  CancelToken cancelToken = CancelToken();
  late String savePath;
  bool _downLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.res?['data'] ?? {};
    url = Platform.isAndroid ? data['androidUrl'] : data['iosUrl'];
    content = data['content'] ?? '';
    content = content.replaceAll('\\n', '\n');
    version = data['version'] ?? '';
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 600.h,
            left: 108.w,
            child: Container(
              color: Colors.white,
              width: 863.w,
              height: 300.h,
            ),
          ),
          Positioned(
            left: ScreenUtil().setWidth(108),
            top: ScreenUtil().setHeight(440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/update_top_bg.png',
                    width: ScreenUtil().setWidth(863)),
                Container(
                  width: ScreenUtil().setWidth(863),
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(57),
                      vertical: ScreenUtil().setHeight(36)),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft:
                        Radius.circular(ScreenUtil().setWidth(10)),
                        bottomRight:
                        Radius.circular(ScreenUtil().setWidth(10)),
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("是否升级到$version版本",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,color: Colors.black)),
                      SizedBox(height: ScreenUtil().setHeight(52)),
                      Text(content, style:const TextStyle(color: Colors.black)),
                      SizedBox(height: ScreenUtil().setHeight(30)),
                      SizedBox(
                        height: ScreenUtil().setHeight(120),
                        child: _downLoading
                            ? LineProgress(
                          progress: progress,
                          color: const Color(0xffe94339),
                          totalWidth: ScreenUtil().setWidth(749),
                        )
                            : TextButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all<Color>(const Color(0xffe94339)),
                                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3.0),
                                    ),
                                  ),
                                ),
                              child: Container(
                                alignment: Alignment.center,
                                width: ScreenUtil().setWidth(749),
                                child: const Text("升级"),
                              ),
                              onPressed: () async {
                                setState(() {
                                  _downLoading = true;
                                });
                                savePath = await _getSavePath(url);
                                _download(NetRequester.dio, url, savePath);
                                if (Platform.isAndroid) {
                                } else {
                                  if (await canLaunch(url)) {
                                    var res = await launch(url);
                                    if (kDebugMode) {
                                      print("launch$res");
                                    }
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                }
                              },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(114),
                  width: ScreenUtil().setWidth(1),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200)),
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      cancelToken.cancel('cancel');
                    },
                    child: Image.asset("assets/images/update_app_close.png",
                      width: ScreenUtil().setWidth(87),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _download(Dio dio, String url, savePath) async {
    try {
      await dio.download(url, savePath,
          onReceiveProgress: showDownloadProgress, cancelToken: cancelToken);
    } on DioException catch (e) {
      setState(() {
        _downLoading = false;
      });
      switch (e.type) {
        case DioExceptionType.cancel:
          Toast.popToast('下载已取消，可再次进入登录页面下载更新');
          break;
        case DioExceptionType.connectionTimeout:
          Toast.popToast('下载连接超时');
          break;
        case DioExceptionType.receiveTimeout:
          Toast.popToast('接收数据超时');
          break;
        case DioExceptionType.sendTimeout:
          Toast.popToast('发送请求超时');
          break;
        case DioExceptionType.badResponse:
          Toast.popToast('网络出错');
          break;
        case DioExceptionType.unknown:
          Toast.popToast('网络出错');
          break;
        case DioExceptionType.badCertificate:
          Toast.popToast('证书出错');
          break;
        case DioExceptionType.connectionError:
          Toast.popToast('网络出错');
          break;
      }
      if (kDebugMode) {
        print(e);
      }
    }
  }


  Future<void> showDownloadProgress(received, total) async {
    if (total != -1) {
      setState(() {
        progress = (received / total);
      });
    }else{
      Toast.popToast('下载失败啦');
      Navigator.pop(context);
    }
    if(received / total == 1){
      Navigator.pop(context);
      var openFileRes = await OpenFile.open(savePath);
      if (openFileRes.message.contains('permission denied')) {
        Toast.popToast('请开启允许安装来自未知来源的软件选项');
        Future.delayed(const Duration(seconds: 1), () async {
          await OpenFile.open(savePath);
        });
      }
    }
  }

  static Future<String> _getSavePath(url) async {
    final directory = await getExternalStorageDirectory();
    String path = directory!.path;
    path = path+"/bebro"+url.substring(url.lastIndexOf('.'),url.length);
    return path;
  }
}