import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/global.dart';
import '../../core/net/net.dart';
import '../../widget/clip_img.dart';

class ChangeAvatarPage extends StatelessWidget {
  final int? type;

  const ChangeAvatarPage({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(type == 1 ? '更改头像' : '更改背景'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(150)),
            child: _buildImage(),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(300),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? xImage = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 60,
                );
                if (xImage != null) {
                  final File image = File(xImage.path);
                  print('image: $image');
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => ClipImgPage(image: image, type: type),),);
                }
              },
              child: Text(
                '选择图片',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(23),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    var widget;
    if (type == 1) {
      widget = Global.profile.user!.avatarUrl == null
          ? Image.asset("assets/images/head/head1.jpg")
          : ExtendedImage.network('${NetConfig.ip}/images/${Global.profile.user!.avatarUrl!}');
    } else {
      widget = Global.profile.user!.backImgUrl == null
          ? Image.asset('assets/images/back.jpg')
          : ExtendedImage.network('${NetConfig.ip}/images/${Global.profile.user!.backImgUrl!}');
    }
    return widget;
  }
}
