import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:client/pages/mobile_scan_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/global.dart';
import '../../core/model/user.dart';
import '../../core/net/net.dart';
import '../../util/my_icon/my_icon.dart';
import '../../util/toast.dart';
import '../../widget/my_separator.dart';


// 二维码名片
class QrPage extends StatefulWidget {
  final User? user;
  const QrPage({super.key,this.user});

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  GlobalKey rootWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 检查并请求权限
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    // 检查存储权限状态
    var status = await Permission.storage.status;
    print("permission status is $status");

    // 如果没有权限，则请求权限
    if (!status.isGranted) {
      var result = await Permission.storage.request();
      print("permission request result is $result");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text('我的二维码名片',style: TextStyle(color: Colors.white),),
      ),
      body: SizedBox(
        width:1080.w,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(),
            ),
            // 二维码名片
            //RepaintBoundary是Flutter中用于截屏的组件，它将子组件的绘制结果保存到一个图片中，
            //它通常用于将Flutter应用程序的UI渲染为图片，以便在应用程序中显示或保存。
            RepaintBoundary(

              key: rootWidgetKey,
              child: Container(
                width: 840.w,
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(50),
                    vertical: 30.h
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(27))),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // 头像
                        SizedBox(
                          width: 90.h,
                          height: 90.h,
                          child: CircleAvatar(
                            backgroundImage: Global.profile.user!.avatarUrl ==null
                                ? const AssetImage("assets/images/app_logo.png")
                                : NetworkImage('${NetConfig.ip}/images/${Global.profile.user!.avatarUrl}'),
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(40)),
                        // 用户信息
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.user?.username??'',
                              style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                            ),
                            SizedBox(height: ScreenUtil().setHeight(20),),
                            Text('${widget.user?.followNum}关注 ${widget.user?.fanNum}粉丝',
                              style: TextStyle(fontSize: ScreenUtil().setSp(17),color: Colors.black87),
                            )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    // 分割线
                    MySeparator(color: Colors.grey[300]!,),
                    SizedBox(height: 25.h),
                    // 二维码
                    QrImageView(
                      data: "userId=${Global.profile.user!.userId.toString()}",
                      version: 2,
                    ),
                    Text('扫一扫，添加好友',style: TextStyle(color: Colors.black87,
                        fontSize: ScreenUtil().setSp(17)))
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(),
            ),
            SizedBox(
              // width: ScreenUtil().setWidth(800),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildGridItem(MyIcons.save, '保存到相册', () async {
                    var res = await ImageGallerySaver.saveImage(await _capturePng(rootWidgetKey));
                    if(res.contains('.jpg')){
                      Toast.popToast('保存成功');
                    }else{
                      Toast.popToast('保存失败请重试');
                    }
                  }),
                  _buildGridItem(MyIcons.scan, '扫一扫', () async {
                    //TODO
                    // 扫描二维码

                    Navigator.push(context,
                        CupertinoPageRoute(builder: (context) => const MobileScanCameraDialog()));
                  })
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String label, Function function) {
    return SizedBox(
      // width: ScreenUtil().setWidth(210),
      child: Column(
        children: <Widget>[
          TextButton(
            onPressed: function as void Function()?,
            child: Icon(icon,
              color: Colors.white,
              size: 40.h,
            ),
          ),
          Text(
            label,
            style: TextStyle(
                color: Colors.white, fontSize: ScreenUtil().setSp(20)),
          )
        ],
      ),
    );
  }

  Future<Uint8List> _capturePng(GlobalKey rootWidgetKey) async {
    try {
      // 1. 获取渲染边界（强制类型检查）
      final RenderObject? renderObject = rootWidgetKey.currentContext?.findRenderObject();
      if (renderObject == null) {
        throw Exception('无法找到 RepaintBoundary 的渲染对象');
      }
      if (renderObject is! RenderRepaintBoundary) {
        throw Exception('渲染对象类型不匹配 (预期: RenderRepaintBoundary)');
      }
      final RenderRepaintBoundary boundary = renderObject;

      // 2. 转换为图片
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // 3. 获取二进制数据
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('图片数据转换失败');
      }

      // 4. 返回确定的 Uint8List
      return byteData.buffer.asUint8List();
    } catch (e) {
      // 5. 捕获并包装异常
      throw Exception('截图捕获失败: $e');
    }
  }


}
