import 'dart:io';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../core/global.dart';
import '../core/net/net_request.dart';
import '../util/clip_editor_helper.dart';
import '../util/toast.dart';
import '../util/upload.dart';


class ClipImgPage extends StatefulWidget {
  final File? image;
  final int? type;
  ClipImgPage({super.key, this.image, this.type});

  @override
  State<StatefulWidget> createState() => _ClipImgPageState();
}

class _ClipImgPageState extends State<ClipImgPage> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
  GlobalKey<ExtendedImageEditorState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('裁剪'),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
            width: ScreenUtil().setWidth(180),
            child: TextButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(0)),
                backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
              ),
              child: Text(
                '完成',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: ScreenUtil().setSp(48),
                ),
              ),
              onPressed: () {
                _upLoadImg();
              },
            ),

          ),
        ],

      ),
      body: ExtendedImage.file(
        widget.image!,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.editor,
        extendedImageEditorKey: editorKey,
        initEditorConfigHandler: (state) {
          return EditorConfig(
              editorMaskColorHandler:(context,pointerDown)=> Colors.black.withOpacity(pointerDown ? 0.4 : 0.8),
              lineColor: Colors.black.withOpacity(0.7),
              maxScale: 8.0,
              cropRectPadding: EdgeInsets.all(20.0),
              hitTestSize: 20.0,
              cropAspectRatio: CropAspectRatios.ratio1_1);
        },
      ),
    );
  }

  _upLoadImg() async {
    Toast.popLoading('上传中...');
    var path = widget.image?.path.toString();
    var type = path?.substring(path.lastIndexOf('.',path.length));
    String timeStamp=DateTime.now().millisecondsSinceEpoch.toString();
    var filename = Global.profile.user!.userId.toString()+timeStamp+type!;
    var fileData = await _clipImg();
    var res = await UpLoad.upLoad(fileData, filename);
    if (res == 0) {
      print('上传失败');
      Toast.popToast('上传失败请重试');
    } else {
      var remoteFilePath = filename;
      var map ={
        'userId':Global.profile.user!.userId,
        'property': widget.type ==1 ? 'avatarUrl' :'backImgUrl',
        'value': remoteFilePath
      };
      var result = await NetRequester.request('/user/updateUserProperty',data: map);
      if(result['code'] == '1'){
        Toast.popToast('上传成功');
        Navigator.pop(context);
        if( widget.type ==1){
          Global.profile.user!.avatarUrl = remoteFilePath;
        }else{
          Global.profile.user!.backImgUrl = remoteFilePath;
        }
        Global.saveProfile();
      }
    }
  }

  Future<Uint8List> _clipImg() async {
    Uint8List? fileData;
    var msg = "";
    try {
      fileData =
      (await cropImageDataWithNativeLibrary(state: editorKey.currentState!)) as Uint8List;
      /*final filePath = await ImageSaver.save('cropped_image.jpg', fileData);
      msg = "图片保存路径 : $filePath";
      res = filePath;*/
    } catch (e, stack) {
      msg = "save faild: $e\n $stack";
    }
    print(msg);
    //showToast(msg);
    return fileData!;
  }
}
