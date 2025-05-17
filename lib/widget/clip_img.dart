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
  const ClipImgPage({super.key, this.image, this.type});

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
                  fontSize: ScreenUtil().setSp(24),
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
          // _imageEditorController.state = state;
          return EditorConfig(
              editorMaskColorHandler:(context,pointerDown)=> Colors.black.withOpacity(pointerDown ? 0.4 : 0.8),
              lineColor: Colors.black.withOpacity(0.7),
              maxScale: 8.0,
              cropRectPadding: const EdgeInsets.all(20.0),
              hitTestSize: 20.0,
              cropAspectRatio: CropAspectRatios.ratio1_1);
        },
        cacheRawData: true,
      ),
    );
  }
  _upLoadImg() async {
    print('---------------------------_upLoadImg have been called------------------------------------------');
    Toast.popLoading('上传中...');
    var path = widget.image?.path.toString();
    var type = path?.substring(path.lastIndexOf('.',path.length));
    String timeStamp=DateTime.now().millisecondsSinceEpoch.toString();
    var filename = Global.profile.user!.userId.toString()+timeStamp+type!;
    var fileData = await _clipImg();
    var res = await UpLoad.upLoad(fileData, filename);
    print('---------------------------now we well going to attach data to map------------------------------------------');
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
      print('-----------------------------we well send data to server just a moment--------------------------');
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
    // 获取 ExtendedImage 的编辑状态
    final state = editorKey.currentState;
    if (state == null) {
      throw Exception("Editor state is not available");
    }

    // 直接通过 state 获取裁剪区域
    final Rect? cropRect = state.getCropRect();
    if (cropRect == null) {
      throw Exception("Crop area not defined");
    }

    // 获取原始图片数据
    final Uint8List? rawImage = state.rawImageData;
    if (rawImage == null) {
      throw Exception("Image data is missing");
    }

    Uint8List? fileData;
    var msg = "";
    try {
      // 尝试裁剪图片
      List<int>? imageData = await cropImageDataWithNativeLibrary(editorKey.currentState);
      if (imageData == null) {
        throw Exception("Cropped image data is null");
      }
      // 将 List<int> 转换为 Uint8List
      fileData = Uint8List.fromList(imageData);
    } catch (e, stack) {
      msg = "保存失败: $e\n$stack";
      print(msg);
      throw Exception(msg); // 抛出异常或返回默认值
    }

    return fileData; // 返回非空的 fileData
  }
}
