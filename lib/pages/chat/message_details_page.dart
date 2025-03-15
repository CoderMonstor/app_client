// import 'package:client/core/global.dart';
// import 'package:client/core/net/net.dart';
// import 'package:extended_image/extended_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import 'package:get/get.dart';
// import 'package:shimmer/shimmer.dart';
//
// import '../../core/model/message.dart';
// import '../../core/model/msg_list.dart';
// import '../../core/model/user.dart';
//
// class MessageDetailsPage extends StatefulWidget {
//   final MsgModel msgModel;
//   final User? user;
//   const MessageDetailsPage({super.key, required this.msgModel, this.user});
//
//   @override
//   State<MessageDetailsPage> createState() => _MessageDetailsPageState();
// }
//
// class _MessageDetailsPageState extends State<MessageDetailsPage> {
//   late TextEditingController textEditingController = TextEditingController();
//   late List<Message> msg=[];
//
//   void addData() {
//     msg.add(Message("a123a", 1));
//     msg.add(Message("a123a", 2));
//     msg.add(Message("a123a", 1));
//     msg.add(Message("a123a", 2));
//     msg.add(Message("a123a", 1));
//   }
//
//   late double height = 0;
//   late ScrollController scrollController = ScrollController();
//   //实例化
//   FocusNode focusNode = FocusNode();
//   @override
//   void initState() {
//     super.initState();
//     addData();
//     //监听滚动到底后，列表拉到指定位置输入框获取焦点
//     scrollController.addListener(() {
//       if (scrollController.offset < -130) {
//         FocusScope.of(context).requestFocus(focusNode);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 245, 245, 245),
//       extendBodyBehindAppBar: true,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: GestureDetector(
//                 onTap: () {
//                   FocusScope.of(context).requestFocus(FocusNode());
//                   if (mounted) setState(() {});
//                   setState(() {});
//                 },
//                 child: ListView.separated(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   reverse: true,
//                   shrinkWrap: true,
//                   controller: scrollController,
//                   physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics(),
//                   ),
//                   itemCount: msg.length,
//                   itemBuilder: (context, index) {
//                     return DefaultTextStyle(style: const TextStyle(fontSize: 16, color: Colors.black),
//                         child: item(msg[index]));
//                   },
//                   separatorBuilder: (BuildContext context, int index) {
//                     return const SizedBox(height: 20);
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget item(Message message) {
//     double width = MediaQuery.sizeOf(Get.context!).width * .7;
//     return message.senderType == 1
//         ? Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//                 Container(
//                 constraints: BoxConstraints(maxWidth: width),
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                     color: Colors.blue,
//                     borderRadius: BorderRadius.circular(8)),
//                 child: Text(
//                   message.text,
//                   style: const TextStyle(color: Colors.white),
//                 )),
//                 const SizedBox(width: 10),
//                 _buildAvatar(message.senderType),
//               ],
//             )
//         : Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildAvatar(message.senderType),
//               const SizedBox(width: 10),
//                   Container(
//                   constraints: BoxConstraints(maxWidth: width),
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8)),
//                   child: Text(
//                     message.text,
//                     style: const TextStyle(color: Colors.black),
//                   )),
//             ],
//     );
//   }
//   _buildAvatar(int type) {
//     var avatar =
//     type == 1 ? Global.profile.user?.avatarUrl : widget.user?.avatarUrl;
//     return SizedBox(
//       width: ScreenUtil().setWidth(35),
//       height: ScreenUtil().setHeight(35),
//       child: avatar == ''
//           ? Image.asset("images/app_logo.png")
//           : ClipOval(
//             child: ExtendedImage.network('${NetConfig.ip}/images/$avatar', cache: true),
//       ),
//     );
//   }
// }
//
//
//
