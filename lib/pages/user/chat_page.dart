import 'dart:async';
import 'dart:convert';


import 'package:extended_image/extended_image.dart';
import 'package:extended_list/extended_list.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../core/global.dart';
import '../../core/model/message.dart';
import '../../core/model/user.dart';




class ChatPage extends StatefulWidget {
  final User? user;

  const ChatPage({super.key, this.user}) ;
  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _textController = TextEditingController();
  late double _keyboardHeight;
  late bool _showEmoji;
  FocusNode _focusNode = FocusNode();
  List<Message> _messageList = [];
  late WebSocketChannel channel ;
  @override
  void initState() {
    // channel = IOWebSocketChannel.connect("ws://192.168.1.110:8003");
    channel = IOWebSocketChannel.connect("ws://127.0.0.1:8003");
    var data = {
      "userId" : Global.profile.user!.userId.toString(),
      "type" : "REGISTER"
    };
    //注册登录
    channel.sink.add(JsonEncoder().convert(data));
    channel.stream.listen((data){
      Map res = jsonDecode(data);
      if (kDebugMode) {
        print(res);
      }
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
      // appBar: MyAppbar.simpleAppbar(widget.user!.username),
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
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(12)),
      child: Row(
        mainAxisAlignment:
        msg.sender == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          msg.sender == 2 ? _buildAvatar(msg.sender) : SizedBox(width: 0),
          ChatBubble(
            clipper: ChatBubbleClipper7(
              type: msg.sender == 1 ? BubbleType.sendBubble : BubbleType.receiverBubble,
            ),
            alignment: msg.sender == 1 ? Alignment.topRight : Alignment.topLeft,
            margin: const EdgeInsets.only(top: 20),
            backGroundColor: msg.sender == 1 ? Color(0xff95ec69) : Colors.white,
            child: Container(
              constraints: BoxConstraints(maxWidth: ScreenUtil().setWidth(640)),
              child: ExtendedText(
                msg.text,
                maxLines: null,
                specialTextSpanBuilder:
                MySpecialTextSpanBuilder(context: context),
              ),
            ),
          ),
          msg.sender == 1 ? _buildAvatar(msg.sender) : SizedBox(width: 0)
        ],
      ),
    );
  }

  _inputBar() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Container(
        constraints: BoxConstraints(maxHeight: ScreenUtil().setHeight(310)),
        padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(10),
            bottom: ScreenUtil().setHeight(20)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(140),
              height: ScreenUtil().setWidth(120),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  minimumSize: Size.zero, // 移除默认的最小尺寸
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 使按钮尽可能小
                ),
                onPressed: () {
                  if (_showEmoji && _focusNode.canRequestFocus) {
                    updateEmojiStatus();
                    Future.delayed(Duration(milliseconds: 50), () {
                      SystemChannels.textInput.invokeMethod('TextInput.show');
                    });
                  } else {
                    updateEmojiStatus();
                  }
                },
                child: Icon(
                  _showEmoji ? FontAwesome.keyboard_o : MyIcons.smile,
                  color: Color(0xff757575),
                ),
              ),
            ),
            Expanded(
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
                    focusedBorder: InputBorder.none),
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(130),
              height: ScreenUtil().setWidth(120),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                ),
                onPressed: _sendHandler,
                child: const Icon(MyIcons.send, color: Color(0xff757575)),
              ),
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

  void updateEmojiStatus() {
    final change = () {
      _showEmoji = !_showEmoji;
      if (mounted) setState(() {});
    };
    if (_showEmoji) {
      change();
    } else {
      //if (MediaQuery.of(context).viewInsets.bottom > 0.0) {
      SystemChannels.textInput.invokeMethod('TextInput.hide').whenComplete(
            () {
          Future.delayed(Duration(milliseconds: 40), () {
            change();
          });
        },
      );
      /*} else {
        change();
      }*/
    }
  }

  _sendHandler() {
    if (_textController.text.isNotEmpty) {
      var data = {
        "fromUserId": Global.profile.user!.userId.toString(),
        "toUserId": widget.user?.userId.toString(),
        "content": _textController.text,
        "type": "SINGLE_SENDING"
      };
      var msg = Message(_textController.text, 1);
      setState(() {
        _messageList.insert(0, msg);
      });
      channel.sink.add(JsonEncoder().convert(data));
      _textController.text = '';
    }
  }

  _buildAvatar(int type) {
    var avatar =
    type == 1 ? Global.profile.user!.avatarUrl : widget.user?.avatarUrl;
    return Container(
      height: ScreenUtil().setHeight(110),
      child: avatar == ''
          ? Image.asset("images/flutter_logo.png")
          : ClipOval(
        child: ExtendedImage.network('${NetConfig.ip}/images/$avatar', cache: true),
      ),
    );
  }
}
