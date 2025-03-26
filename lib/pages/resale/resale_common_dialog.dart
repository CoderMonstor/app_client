import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../core/global.dart';
import '../../core/net/net_request.dart';
import '../../util/my_icon/my_icon.dart';
import '../../util/text_util/special_text_span.dart';
import '../../util/toast.dart';
import '../../util/upload.dart';

class ResaleCommentDialog extends StatefulWidget{

  final int? goodsId;
  final int? commentId;
  final String? beReplyName;
  final LoadingMoreBase? list;
  const ResaleCommentDialog({super.key, this.goodsId, this.commentId, this.list, this.beReplyName});
  @override
  State<StatefulWidget> createState() => _ResaleCommentDialogState();
}

class _ResaleCommentDialogState extends State<ResaleCommentDialog> {
  final TextEditingController _textController = TextEditingController();
  late bool _showEmoji;
  final FocusNode _focusNode = FocusNode();
  List<AssetEntity> images = [];

  @override
  void initState() {
    _showEmoji = false;
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
      _showEmoji = false;
    }
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: (){
                _focusNode.unfocus();
                Navigator.pop(context);
              },
            ),
          ),
          _buildTextFiled(),
          _inputBar(),
          // emoticonPad(context)
        ],
      ),

    );
  }

  _inputBar() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: SizedBox(
        // height: ScreenUtil().setHeight(110),
        child: Row(
          children: [
            const Expanded(flex:1,child: SizedBox()),
            Expanded(
              flex: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                    onPressed: loadAssets,
                    child: const Icon(
                      MyIcons.image,
                      color: Color(0xff757575),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _sendHandler();
                    },
                    child: const Icon(
                      MyIcons.send,
                      color: Color(0xff757575),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(flex:1,child: SizedBox()),

          ],
        ),
      ),
    );
  }
  void _changeRow() {
    _textController.text += '\n';
  }

  void updateEmojiStatus() {
    change() {
      _showEmoji = !_showEmoji;
      if (mounted) setState(() {});
    }
    if (_showEmoji) {
      change();
    } else {
      if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
        SystemChannels.textInput.invokeMethod('TextInput.hide').whenComplete(
              () {Future.delayed(const Duration(milliseconds: 40), (){
            change();
          });},);
      } else {
        change();
      }
    }
  }

  _buildTextFiled() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius:BorderRadius.only(
        topLeft: Radius.circular(ScreenUtil().setWidth(0)),
        topRight: Radius.circular(ScreenUtil().setWidth(0)),
      )),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(42),
            vertical: ScreenUtil().setHeight(15)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('发评论',style: TextStyle(color: Colors.grey)),
            const Divider(color: Colors.grey),
            ExtendedTextField(
              specialTextSpanBuilder: MySpecialTextSpanBuilder(context: context),
              focusNode: _focusNode,
              controller: _textController,
              autofocus: true,
              style: TextStyle(fontSize: ScreenUtil().setSp(23)),
              keyboardType: TextInputType.multiline,
              onEditingComplete: _changeRow,
              // maxLines: 5,
              decoration: const InputDecoration.collapsed(hintText: "说点什么吧..."),
            ),
            // SizedBox(height: ScreenUtil().setHeight(10)),
            _buildImage(),
          ],
        ),

      ),
    );
  }

  Future<void> loadAssets() async {
    List<AssetEntity>? resultList = [];
    final ThemeData theme = Theme.of(context);

    try {
      resultList = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 1, // 原 maxImages → maxAssets
          selectedAssets: images,
          requestType: RequestType.image, // 指定只选择图片
          specialPickerType: SpecialPickerType.noPreview, // 可选配置
          themeColor: theme.primaryColor, // 主题色
          textDelegate: const AssetPickerTextDelegate(), // 支持中文
        ),
      );
    } catch (e) {
      print("选择图片出错: $e");
    }

    if (!mounted) return;
    setState(() {
      images = resultList!;
    });
  }

  _buildImage() {
    if (images.isNotEmpty) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: ScreenUtil().setWidth(365),
        ),
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          // padding: const EdgeInsets.all(0),
          // mainAxisSpacing: ScreenUtil().setWidth(18),
          // crossAxisSpacing: ScreenUtil().setWidth(18),
          crossAxisCount: 3,
          children: <Widget>[
            AssetEntityImage(
              images.first,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            )
          ],
        ),
      );
    }
    return const SizedBox(height: 0);
  }

  Future<void> _sendHandler() async {
    if (_textController.text == '' && images.isEmpty) {
      Toast.popToast('请输入文字或选择图片');
      return;
    }

    String text = '';
    String? imageUrl; // 允许变量为空

    if (images.isNotEmpty) {
      final AssetEntity asset = images.first;
      final String? name = asset.title;
      final String? type = name?.substring(name.lastIndexOf('.'));
      final String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filename =
          '${Global.profile.user!.userId}$timeStamp${type ?? '.jpg'}'; // 处理可能的空类型

      // 获取图片二进制数据
      final Uint8List? imageData = await asset.originBytes; //  直接获取 Uint8List?
      if (imageData == null) {
        Toast.popToast('图片数据读取失败');
        return;
      }

      try {
        final int res = await UpLoad.upLoad(imageData, filename); //  直接传递 Uint8List
        if (res == 0) {
          Toast.popToast('上传失败请重试');
          return; // 提前返回，避免后续使用未赋值的 imageUrl
        } else {
          imageUrl = "/images/$filename";
        }
      } catch (e) {
        print('上传错误: $e');
        Toast.popToast('上传异常');
        return;
      }

      text = _textController.text.isEmpty ? '图片评论' : _textController.text;
    } else {
      text = _textController.text;
    }

    // 确保 imageUrl 在未上传图片时为 null 或空字符串
    final Map<String, dynamic> map;
    final String url;

    final now = DateTime.now().toString().substring(0, 19);
    if (widget.goodsId != null) {
      map = {
        'userId': Global.profile.user?.userId,
        'text': text,
        'imageUrl': imageUrl ?? '', // 处理可能的空值
        'date': now,
        'goodsId': widget.goodsId,
      };
      url = '/goodsComment/addComment';
    } else {
      map = {
        'userId': Global.profile.user?.userId,
        'text': text,
        'date': now,
        'imageUrl': imageUrl ?? '', // 处理可能的空值
        'beReplyName': widget.beReplyName,
        'commentId': widget.commentId,
      };
      url = '/goodsReply/addReply';
    }

    try {
      final result = await NetRequester.request(url, data: map);
      if (result['code'] == '1') {
        Toast.popToast('发布成功');
        Navigator.pop(context);
        widget.list?.refresh();
      } else {
        Toast.popToast('发布失败，请检查网络重试');
      }
    } catch (e) {
      print('请求错误: $e');
      Toast.popToast('网络异常');
    }
  }
}