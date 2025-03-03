import 'dart:async';
import 'dart:convert';

import 'package:bubble_box/bubble_box.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_list/extended_list.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/global.dart';
import '../../core/model/message.dart';
import '../../core/model/receive_msg.dart';
import '../../core/model/user.dart';
import '../../core/net/net.dart';
import '../../util/my_icon/my_icon.dart';
import '../../util/text_util/emoji_text.dart';
import '../../util/text_util/special_text_span.dart';

class ChatPage extends StatefulWidget {
  final User? user;

  const ChatPage({super.key, this.user});
  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  double _keyboardHeight=0;
  late bool _showEmoji;
  final FocusNode _focusNode = FocusNode();
  final List<Message> _messageList = [];
  late WebSocketChannel channel ;
  @override
  void initState() {
    channel = IOWebSocketChannel.connect("ws://47.109.108.66:8003");
    var data = {
      "userId" : Global.profile.user?.userId.toString(),
      "type" : "REGISTER"
    };
    //注册登录
    channel.sink.add(const JsonEncoder().convert(data));
    channel.stream.listen((data){
      Map res = jsonDecode(data);
      print(res);
      if(res['status']!=-1){
        var receive = ReceiveMsg.fromJson(res['data']);
        if(receive.fromUserId
            !=null&&receive.fromUserId==widget.user?.userId.toString()){
          _messageList.insert(0, Message(receive.content!,2));
          setState(() {});
        }
      }

    });
    _showEmoji = false;
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.unfocus();
    _focusNode.dispose();
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0) {
      _keyboardHeight = keyboardHeight;
      _showEmoji = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user!.username!),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child:ExtendedListView.builder(
              padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setHeight(30),
                  horizontal: ScreenUtil().setWidth(20)),
              reverse: true,
              extendedListDelegate: const ExtendedListDelegate(closeToTrailing: true),
              itemBuilder: (context, index) {
                var msg = _messageList[index];
                return _buildMessage(msg);
              },
              itemCount: _messageList.length,
            ),
          ),
          _inputBar(),
          emoticonPad(context),
        ],
      ),
    );
  }

  Widget _buildMessage(Message msg) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: msg.sender == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (msg.sender == 2) _buildAvatar(msg.sender),
          BubbleBox(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
            shape: BubbleShapeBorder(
              // border: BubbleBoxBorder(
              //   width: 3
              // ),
              position: const BubblePosition.start(3),
              direction:msg.sender==1? BubbleDirection.right:BubbleDirection.left,
            ),
            backgroundColor: msg.sender == 1? Colors.green.withOpacity(0.8):Colors.white,
            child: Text(
              msg.text,
            ),
          ),
          if (msg.sender == 1) _buildAvatar(msg.sender)
        ],
      ),
    );
  }

  _inputBar() {
    return Card(
      // margin: const EdgeInsets.all(0),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Container(
        padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(5),
            bottom: ScreenUtil().setHeight(5)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 10), // 左边距10
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: ScreenUtil().setHeight(100), // 设置最大高度
                ),
                child: ExtendedTextField(
                  specialTextSpanBuilder:
                  MySpecialTextSpanBuilder(context: context),
                  focusNode: _focusNode,
                  controller: _textController,
                  onEditingComplete: _changeRow,
                  maxLines: null,
                  decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.05),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none
                  ),
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0),
              ),
              onPressed: _sendHandler,
              child: const Icon(MyIcons.send, color: Color(0xff757575)),
            ),
          ],
        ),
      ),
    );
  }

  Widget emoticonPad(context) {
    return EmotionPad(
      active: _showEmoji,
      height: _keyboardHeight,
      controller: _textController,
    );
  }

  void _changeRow() {
    _textController.text += '\n';
  }


  _sendHandler() {
    if (_textController.text.isNotEmpty) {
      var data = {
        "fromUserId": Global.profile.user?.userId.toString(),
        "toUserId": widget.user?.userId.toString(),
        "content": _textController.text,
        "type": "SINGLE_SENDING"
      };
      var msg = Message(_textController.text, 1);
      setState(() {
        _messageList.insert(0, msg);
      });
      channel.sink.add(const JsonEncoder().convert(data));
      _textController.text = '';
    }
  }

  _buildAvatar(int type) {
    var avatar =
    type == 1 ? Global.profile.user?.avatarUrl : widget.user?.avatarUrl;
    return SizedBox(
      height: ScreenUtil().setHeight(40),
      child: avatar == ''
          ? Image.asset("images/app_logo.png")
          : ClipOval(
            child: ExtendedImage.network('${NetConfig.ip}/images/$avatar', cache: true),
      ),
    );
  }
}
