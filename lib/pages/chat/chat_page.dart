import 'dart:convert';

import 'package:client/core/net/net_request.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_list/extended_list.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/global.dart';
import '../../core/model/message.dart';
import '../../core/model/receive_msg.dart';
import '../../core/model/user.dart';
import '../../core/net/my_api.dart';
import '../../core/net/net.dart';
import '../../util/my_icon/my_icon.dart';
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
  final FocusNode _focusNode = FocusNode();
  final List<Message> _messageList = [];
  late List<Message> _historyMessageList = [];
  late WebSocketChannel channel ;

  int get sender => Global.profile.user!.userId!;
  int get receiver => widget.user!.userId!;
  @override
  void initState() {
    super.initState();
    // 调用独立的异步方法
    initializeAsyncTask();
  }

  // 定义异步方法
  Future<void> initializeAsyncTask() async {
    print("======================获取数据===========================】");
    var res = await NetRequester.request(Apis.getMsg(sender, receiver));
    if (res['code'] == '1') {
      print("=========================插入数据=============${res['data']}==============");

      // _messageList.addAll(res['data'].toList());
      var messages = (res['data'] as List).map((item) {
        return Message(item['message'], item['senderType']);
      }).toList();

      _historyMessageList.addAll(messages);
      //把_historyMessageList顺序反转，message.messageType保持不变
      _historyMessageList = _historyMessageList.reversed.toList();
      // 更新 _messageList，确保历史消息能够显示
      setState(() {
        _messageList.addAll(_historyMessageList);
      });
    }

    try {
      channel = IOWebSocketChannel.connect("ws://47.109.108.66:8003");
      print("WebSocket连接尝试中...");

      channel.ready.then((_) {
        print("WebSocket连接成功");
        var registerData = {
          "userId": Global.profile.user?.userId.toString(),
          "type": "REGISTER"
        };
        channel.sink.add(jsonEncode(registerData));
      });

      channel.stream
        ..handleError((error) => print("WebSocket错误: $error"))
        ..listen((data) {
          print("收到服务器数据: $data");
          // 原有处理逻辑...
        });
    } catch (e) {
      print("初始化WebSocket失败: $e");
    }
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
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user!.username!),
      ),
      body: Column(
        children: <Widget>[
          // _historyMessage(),
          Expanded(
            child:ExtendedListView.builder(
              padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setHeight(30),
                  horizontal: ScreenUtil().setWidth(20)),
              reverse: true,
              extendedListDelegate: const ExtendedListDelegate(closeToTrailing: true),
              itemBuilder: (context, index) {
                var msg = _messageList[index];
                // return _buildMessage(msg);
                return item(msg);
              },
              itemCount: _messageList.length,
            ),
          ),
          _inputBar(),
          // emoticonPad(context),
        ],
      ),
    );
  }


  Widget item(Message message) {
    // double width = MediaQuery.sizeOf(Get.context!).width * .7;
    double width = MediaQuery.of(context).size.width * .7;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: message.senderType == 1
              ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      constraints: BoxConstraints(maxWidth: width),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        message.text,
                        style: const TextStyle(color: Colors.white),
                      )),
                  const SizedBox(width: 10),
                  _buildAvatar(message.senderType),
                ],
          )
          : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(message.senderType),
              const SizedBox(width: 10),
              Container(
                  constraints: BoxConstraints(maxWidth: width),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    message.text,
                    style: const TextStyle(color: Colors.black),
                  )),
            ],
      ),
    );
  }
  _buildAvatar(int type) {
    var avatar =
    type == 1 ? Global.profile.user?.avatarUrl : widget.user?.avatarUrl;
    return SizedBox(
      width: ScreenUtil().setWidth(35),
      height: ScreenUtil().setHeight(35),
      child: avatar == ''
          ? Image.asset("images/head/head.jpg")
          : ClipOval(
            child: ExtendedImage.network('${NetConfig.ip}/images/$avatar', cache: true),
      ),
    );
  }
  _inputBar() {
    return Card(
      child: Container(
        padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(5),
            bottom: ScreenUtil().setHeight(5)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(width: 10), // 左边距10
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
    // if (_textController.text.isEmpty) return;
    //
    // final message = {
    //   "fromUserId": Global.profile.user?.userId,
    //   "toUserId": widget.user?.userId,
    //   "content": _textController.text,
    //   "type": "SINGLE_SENDING"  // 根据服务器协议调整
    // };
    //
    // print("发送消息: ${jsonEncode(message)}");
    //
    // if (channel.closeCode != null) {
    //   print("连接已关闭，尝试重连...");
    //   initializeAsyncTask(); // 尝试重新连接
    //   return;
    // }
    //
    // try {
    //   channel.sink.add(jsonEncode(message));
    //   setState(() {
    //     _messageList.insert(0, Message(_textController.text, 1));
    //   });
    //   _textController.clear();
    // } catch (e) {
    //   print("消息发送失败: $e");
    // }
  }

}
