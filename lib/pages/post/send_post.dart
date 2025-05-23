import 'dart:io';

import 'package:client/core/global.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../core/model/post.dart';
import '../../core/model/user_model.dart';
import '../../core/net/net.dart';
import '../../core/net/net_request.dart';
import '../../util/my_icon/my_icon.dart';
import '../../util/permission_request.dart';
import '../../util/text_util/special_text_span.dart';
import '../../util/toast.dart';
import '../../util/upload.dart';

class SendPostPage extends StatefulWidget {
  //1:发布动态 2：转发动态
  final int? type;
  final Post? post;
  final String? text;
  const SendPostPage({super.key, this.type, this.post, this.text});
  @override
  State<SendPostPage> createState() => _SendPostPageState();
}

class _SendPostPageState extends State<SendPostPage> {

  List<AssetEntity> images = [];
  TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late int _maxImgNum;
  late PermissionUtil _permissionUtil;

  Future<void> _initializePermissionUtil() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _permissionUtil = PermissionUtil(context);
      } catch (e) {
        print('初始化权限工具失败: $e');
      }
    });
  }
  @override
  void initState() {
    _maxImgNum = widget.type==1 ? 9:1;
    if(widget.text!='' && widget.text!= null){
      _textController.text='@${widget.post?.username} :${widget.text}';
      _textController.selection = const TextSelection.collapsed(offset: 0);
    }
    _initializePermissionUtil();
    super.initState();
  }
  @override
  void dispose() {
    _textController.dispose();
    _focusNode.unfocus();
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0) {
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text("发表动态"),
        actions: <Widget>[
          Consumer<UserModel>(builder: (BuildContext context, model, _) {
            return IconButton(
              icon: const Icon(MyIcons.send),
              onPressed: () {
                _sendHandler(model);
              },
            );
          })
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                //输入框
                Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(33)),
                  height: ScreenUtil().setHeight(300),
                  child: ExtendedTextField(
                    specialTextSpanBuilder: MySpecialTextSpanBuilder(context: context),
                    focusNode: _focusNode,
                    controller: _textController,
                    autofocus: true,
                    style: TextStyle(fontSize: ScreenUtil().setSp(23)),
                    keyboardType: TextInputType.multiline,
                    onEditingComplete: _changeRow,
                    maxLines: 5,
                    decoration: const InputDecoration.collapsed(hintText: "分享当下的想法吧..."),
                  ),
                ),
                _buildSingleImg(),
                //图片
                widget.type ==2?_buildForwardPost():buildGridView(),
              ],
            ),
          ),
        ],
      ),

    );
  }

  void _changeRow() {
    _textController.text += '\n';
  }
  Widget buildGridView() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
      constraints: BoxConstraints(
          maxHeight: ScreenUtil().setWidth(_getHeight(images.length))
      ),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
        mainAxisSpacing: ScreenUtil().setWidth(18),
        crossAxisSpacing: ScreenUtil().setWidth(18),
        crossAxisCount: 3,
        children:
        List.generate(images.length < 9 ? images.length + 1 : 9, (index) {
          if (images.length < 9 && index == images.length) {
            return _buildAdd();
          } else {
            AssetEntity asset = images[index];
            return Stack(
              children: <Widget>[
                FutureBuilder<Uint8List?>(
                  future: asset.thumbnailDataWithSize(
                    const ThumbnailSize(300, 300),
                    quality: 80,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      return Image.memory(snapshot.data!);
                    } else {
                      return const SizedBox(height: 300, width: 300);
                    }
                  },
                ),
                deleteButton(index)
              ],
            );
          }
        }),
      ),
    );
  }
  Widget deleteButton(int index) => Positioned(
    right: 0,
    top: 0,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          images.removeAt(index);
        });
      },
      child: Icon(
        Icons.dangerous,
        size: ScreenUtil().setWidth(25.0),
        color: Colors.black54,
      ),
    ),
  );

  Future<void> loadAssets() async {
    try {
      // 检查并请求权限
      Permission permission;
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        permission = Permission.storage;
      } else {
        permission = Permission.photos;
      }
      await _permissionUtil.checkPermission(permission);

      // 如果权限已授予，继续选择图片
      List<AssetEntity>? resultList = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: _maxImgNum,
          selectedAssets: images,
          requestType: RequestType.image,
          gridThumbnailSize: const ThumbnailSize.square(80),
          previewThumbnailSize: const ThumbnailSize.square(150),
        ),
      );

      if (!mounted || resultList == null) return;
      setState(() => images = resultList);
    } catch (e) {
      print('图片选择错误: $e');
      Toast.popToast('图片选择错误，请重试');
    }
  }


  Widget _buildAdd() {
    return Container(
      color: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: loadAssets,
        child: Icon(
          MyIcons.plus,
          size: ScreenUtil().setWidth(50),
          color: Colors.grey,
        ),
      ),
    );
  }

  Future<void> _sendHandler(UserModel model) async {
    if(images.isEmpty && _textController.text.isEmpty && widget.type ==1){
      Toast.popToast('请输入文字内容或选择图片');
      return;
    }
    if (images.isNotEmpty) {
      Toast.popLoading('上传中...',20);
    }
    var flag = 1;
    String imageUrl='';
    for (final asset in images) {
      try {
        // 1. 获取文件名和扩展名
        final String? fileName = asset.title; // 获取带扩展名的文件名（如 "IMG_1234.JPG"）
        final String extension = fileName != null && fileName.contains('.')
            ? '.${fileName.split('.').last}' // 提取扩展名（如 ".JPG"）
            : '.jpg'; // 默认扩展名
        // 2. 生成唯一文件名
        final String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String filename = '${model.user.userId}_$timeStamp$extension';

        // 3. 获取文件二进制数据
        final File? file = await asset.file; // 获取原图文件
        if (file == null) {
          Toast.popToast('文件读取失败');
          flag = 0;
          continue;
        }
        final Uint8List fileData = await file.readAsBytes();

        // 4. 上传文件
        final res = await UpLoad.upLoad(fileData, filename);
        if (res == 0) {
          Toast.popToast('上传失败请重试');
          flag = 0;
        } else {
          imageUrl += "/images/$filename￥";
        }
      } catch (e) {
        flag = 0;
        debugPrint('上传错误: $e');
      }
    }
    if(flag == 1){
      var now = DateTime.now();
      var result;
      int? forwardId;
      if(widget.type==1){
        forwardId=null;
      }else {
        forwardId=widget.post?.forwardId ??widget.post?.postId;
      }
      String text = _textController.text;
      if(widget.type ==2 && _textController.text==''){
        text= '转发动态';
      }
      if(widget.type ==2
          &&_textController.text=='//@${widget.post?.username} :${widget.post?.text}'){
        text= '转发动态'+text;
      }
      if(images.isNotEmpty){
        imageUrl=imageUrl.substring(0,imageUrl.length-1);
      }
      var map ={
        'userId':Global.profile.user?.userId,
        'text': text,
        'imageUrl':imageUrl,
        'date':now.toString().substring(0,19),
        'forwardId':forwardId
      };

      result = await NetRequester.request('/post/addPost',data: map);
      if(result['code'] =='1'){
        Toast.popToast('发布成功');
        Navigator.pop(context);
        model.user.postNum=model.user.postNum!+1;
        model.notifyListeners();
      }else{
        Toast.popToast('发布失败，请检查网络重试');
      }
    }
  }
  num _getHeight(int length) {
    if(length<3){
      return 130;
    }else if(length <6){
      return 240;
    }else{
      return 350;
    }
  }

  _buildForwardPost() {
    var url =widget.post?.forwardId==null?widget.post?.imageUrl:widget.post?.forwardImageUrl;
    url ??= '';
    List images = url.split('￥');
    return Container(
      width: ScreenUtil().setWidth(1080),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setHeight(15),
            horizontal: ScreenUtil().setWidth(20)
        ),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.06),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20))
        ),
        child: Row(
          children: <Widget>[
            images[0]==''
                ?const SizedBox(width: 0)
                :ExtendedImage.network(NetConfig.ip+images[0],
              height: ScreenUtil().setHeight(120),
              width: ScreenUtil().setHeight(120),
              fit: BoxFit.cover,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.post!.forwardId == null
                        ? '@${widget.post?.username ?? '未知用户'}'
                        : '@${widget.post?.forwardName ?? '未知用户'}',
                    style: TextStyle(fontSize: ScreenUtil().setSp(24)),
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(819),
                    child:
                    ExtendedText(
                      widget.post?.forwardId == null
                          ? widget.post?.text ?? ''
                          : widget.post?.forwardText ?? '',
                      maxLines: 1,
                      style: TextStyle(color: Colors.grey, fontSize: ScreenUtil().setSp(20)),
                      specialTextSpanBuilder: MySpecialTextSpanBuilder(context: context),
                      overflowWidget: CustomTextOverflowWidget(
                        overflowText: "...",
                        child: Container(), // 添加一个空的容器或其他合适的 widget
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleImg() {
    return widget.type == 2 && images.isNotEmpty
        ? Stack(
      children: <Widget>[
          AssetEntityImage(
            images[0],
            width: 50,
            height: 50,
            thumbnailSize: const ThumbnailSize(300, 300),
          ),
        deleteButton(0),
      ],
    )
        : const SizedBox(height: 0);
  }

}

class CustomTextOverflowWidget extends TextOverflowWidget {
  final String overflowText;

  // 添加 key 和 child 参数并使用 const 关键字
  const CustomTextOverflowWidget({
    required this.overflowText,
    required super.child, // 添加 child 参数
  });

  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    double textWidth = 0;

    return Text(
      "...$overflowText",
      style: TextStyle(color: Colors.grey, fontSize: ScreenUtil().setSp(38)),
    );
  }
}


