import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/global.dart';
import '../../core/model/user.dart';
import '../../core/net/net.dart';
import '../../util/my_icon/my_icon.dart';
import '../../widget/my_separator.dart';


// 二维码名片
class QrPage extends StatelessWidget {
  final User? user;
  const QrPage({super.key,this.user});
  @override
  Widget build(BuildContext context) {
    GlobalKey rootWidgetKey = GlobalKey();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('我的二维码名片'),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(-8),
            child: Container()),
      ),
      body: Container(width:1080.w,
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
                    vertical: 55.h
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
                        Container(
                          width: 150.h,
                          height: 150.h,
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
                            Text(user?.username??'',
                              style: TextStyle(fontSize: ScreenUtil().setSp(52)),),
                            SizedBox(height: ScreenUtil().setHeight(20),),
                            Text('${user?.followNum}关注 ${user?.fanNum}粉丝',
                              style: TextStyle(fontSize: ScreenUtil().setSp(34),color: Colors.black87),)
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 55.h),
                    // 分割线
                    MySeparator(color: Colors.grey[300]!,),
                    SizedBox(height: 60.h),
                    // 二维码
                    // QrImage(
                    //   data: "userId=${Global.profile.user.userId.toString()}",
                    //   version: 2,
                    //   size: 600.w,
                    //   embeddedImage: AssetImage("assets/images/app_logo.png"),
                    // ),
                    Text('扫一扫，添加好友',style: TextStyle(color: Colors.black87,
                        fontSize: ScreenUtil().setSp(34)))
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(),
            ),
            Container(
              width: ScreenUtil().setWidth(800),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildGridItem(MyIcons.save, '保存到相册', () async {
                    //TODO
                    // var res = await ImageSaver.save(await _capturePng(rootWidgetKey));
                    // if(res.contains('.jpg')){
                    //   Toast.popToast('保存成功');
                    // }else{
                    //   Toast.popToast('保存失败请重试');
                    // }
                  }),
                  _buildGridItem(MyIcons.share, '分享二维码', () {}),
                  _buildGridItem(MyIcons.scan, '扫一扫', () async {
                    //TODO
                    //扫描二维码
                    // rScanCameras= await availableRScanCameras();
                    // Navigator.push(context,
                    //     CupertinoPageRoute(builder: (context) => RScanCameraDialog()));
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
    return Container(
      width: ScreenUtil().setWidth(210),
      child: Column(
        children: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(35)),
              shape: const CircleBorder(),
              backgroundColor: Colors.white38,
            ),
            onPressed: function as void Function()?,
            child: Icon(icon,
              color: Colors.white,
              size: 70.h,
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(15)),
          Text(
            label,
            style: TextStyle(
                color: Colors.white, fontSize: ScreenUtil().setSp(40)),
          )
        ],
      ),
    );
  }

  Future<Uint8List?> _capturePng(GlobalKey rootWidgetKey) async {
    try {
      RenderRepaintBoundary? boundary = rootWidgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) return null;

      Uint8List pngBytes = byteData.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      print(e);
    }
    return null;
  }


}
