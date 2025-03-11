import 'dart:ui';

import 'package:client/widget/search_field.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/model/msg_model.dart';
import '../../core/model/send_msg_model.dart';

class MessageDetailsPage extends StatefulWidget {
  const MessageDetailsPage({super.key, required this.msgModel});
  final MsgModel msgModel;

  @override
  State<MessageDetailsPage> createState() => _MessageDetailsPageState();
}

class _MessageDetailsPageState extends State<MessageDetailsPage> {
  late TextEditingController textEditingController = TextEditingController();
  late bool displaySend = false;
  late String me = "https://foruda.gitee.com/avatar/1677180609201628769/9580418_zhangnull_1639032531.png";
  late List<UserSendUserMsgModel> msg = [];

  void addData() {
    msg.add(UserSendUserMsgModel(
        imageUrl: widget.msgModel.imageUrl,
        msg: '感觉我这种臭鱼烂虾进去要坐大牢',
        role: "receiver"));
    msg.add(UserSendUserMsgModel(
        imageUrl: widget.msgModel.imageUrl, msg: '这里的invoke没有啊', role: "you"));
    msg.add(UserSendUserMsgModel(
        imageUrl: widget.msgModel.imageUrl,
        msg: '我的识别码:364819064使用向日葵即可对我发起远程协助向日葵下载地址:http://url.oray.com/tGJdas/',
        role: "receiver"));
    msg.add(UserSendUserMsgModel(
        imageUrl: widget.msgModel.imageUrl, msg: '谢谢你，大屌侠', role: "you"));
    msg.add(UserSendUserMsgModel(
      imageUrl: me,
      msg: '所以说，点不出来就等于没有吗',
    ));
  }

  late bool isDisplay = false;
  late double height = 0;
  late ScrollController scrollController = ScrollController();
  //实例化
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    addData();
    //监听输入框的焦点，是否弹出选项列表
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        displaySend = true;
        if (isDisplay) {
          height = 0;
        }
        setState(() {});
      }
    });
    //监听滚动到底后，列表拉到指定位置输入框获取焦点
    scrollController.addListener(() {
      if (scrollController.offset < -130) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: PreferredSize(
        preferredSize: const Size(0, 60),
        child: getFilterWidget(
          child: AppBar(
            backgroundColor: Colors.transparent,
            leading: const BackButton(
              style: ButtonStyle(
                  overlayColor: WidgetStatePropertyAll(Colors.transparent)),
            ),
            leadingWidth: 70,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.msgModel.name,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (isDisplay) {
                    isDisplay = !isDisplay;
                    height = 0;
                  }
                  displaySend = textEditingController.text.isNotEmpty;
                  if (mounted) setState(() {});
                  setState(() {});
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  reverse: true,
                  shrinkWrap: true,
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics(),
                  ),
                  itemCount: msg.length,
                  itemBuilder: (context, index) {
                    return DefaultTextStyle(style: const TextStyle(fontSize: 16, color: Colors.black),
                        child: item(msg[index]));
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 20);
                  },
                ),
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 247, 247, 247),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // const Icon(Icons.mic_none_outlined),
                  const SizedBox(width: 5),
                  Expanded(
                    child: BLMSearchField(
                      "",
                      "colse",
                      textEditingController,
                      autofocus: false,
                      textInputType: TextInputType.text,
                      focusNode: focusNode,
                      onSubmitted: (p0) {
                        if (p0.isEmpty) return;
                        msg.insert(
                            0, UserSendUserMsgModel(imageUrl: me, msg: p0));
                        textEditingController.clear();
                        //displaySend = false;
                        Future.delayed(const Duration(seconds: 2), () {
                          msg.insert(
                              0,
                              UserSendUserMsgModel(
                                  imageUrl: widget.msgModel.imageUrl,
                                  role: "receiver",
                                  msg: "${widget.msgModel.name}:$p0"));
                          setState(() {});
                        });
                        setState(() {});
                      },
                      onchange: (text) {
                        displaySend = textEditingController.text.isNotEmpty;
                        if (mounted) setState(() {});
                      },
                      backgrund: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  !displaySend
                      ? GestureDetector(
                          onTap: () {
                            isDisplay = !isDisplay;
                            if (isDisplay) {
                              height = 300;
                              scrollController.animateTo(-20,
                                  curve: Curves.ease,
                                  duration: const Duration(milliseconds: 500));
                            } else {
                              height = 0;
                            }
                            setState(() {});
                          },
                          child: SvgPicture.asset(
                            "assets/svg/Add_Plus_Circle.svg",
                            color: !isDisplay ? Colors.black : Colors.blue,
                          ),
                        )
                      : SizedBox(
                          width: 60,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              if (textEditingController.text.isEmpty) return;
                              msg.insert(
                                  0,
                                  UserSendUserMsgModel(
                                      imageUrl: me,
                                      msg: textEditingController.text));
                              String youtext = textEditingController.text;
                              textEditingController.clear();
                              //displaySend = false;

                              scrollController.animateTo(0,
                                  curve: Curves.ease,
                                  duration: const Duration(milliseconds: 300));
                              Future.delayed(const Duration(seconds: 2), () {
                                msg.insert(
                                    0,
                                    UserSendUserMsgModel(
                                        imageUrl: widget.msgModel.imageUrl,
                                        role: "you",
                                        msg:
                                            "${widget.msgModel.name}:$youtext"));
                                setState(() {});
                              });

                              setState(() {});
                            },
                            style: ButtonStyle(
                                padding: const WidgetStatePropertyAll(
                                    EdgeInsets.zero),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                backgroundColor: WidgetStatePropertyAll(
                                    Colors.blue.shade400)),
                            child: const Text(
                              "发送",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                  const SizedBox(width: 5)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget item(UserSendUserMsgModel userMsgModel) {
    double width = MediaQuery.sizeOf(Get.context!).width * .7;
    Widget loading = Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: const Color.fromARGB(255, 240, 240, 240),
        child: Container(
          height: 50,
          width: double.infinity,
          color: Colors.white,
        ));
    return userMsgModel.role == "i"
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
                        userMsgModel.msg,
                        style: const TextStyle(color: Colors.white),
                      )),
              const SizedBox(width: 10),
              ClipOval(
                  child: ExtendedImage.network(
                userMsgModel.imageUrl,
                cache: true,
                width: 35,
                height: 35,
                fit: BoxFit.cover,
                loadStateChanged: (state) {
                  if (state.extendedImageLoadState == LoadState.loading) {
                    return loading;
                  } else if (state.extendedImageLoadState == LoadState.failed) {
                    return loading;
                  }
                  return null;
                },
              )),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                  child: ExtendedImage.network(
                userMsgModel.imageUrl,
                cache: true,
                width: 35,
                height: 35,
                fit: BoxFit.cover,
                loadStateChanged: (state) {
                  if (state.extendedImageLoadState == LoadState.loading) {
                    return loading;
                  } else if (state.extendedImageLoadState == LoadState.failed) {
                    return loading;
                  }
                  return null;
                },
              )),
              const SizedBox(width: 10),
                  Container(
                      constraints: BoxConstraints(maxWidth: width),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        userMsgModel.msg,
                        style: const TextStyle(color: Colors.black),
                      )),
            ],
          );
  }
}


Widget getFilterWidget({
  Widget? child,
  double sigmaX = 20,
  double sigmaY = 20,
}) {
  return ClipRect(
    //背景模糊化
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: sigmaX,
        sigmaY: sigmaY,
      ),
      child: child,
    ),
  );
}

class DetailPage extends StatefulWidget {
  const DetailPage(this.url, {super.key});
  final String url;
  @override
  State<DetailPage> createState() => _NewDetailPageState();
}

class _NewDetailPageState extends State<DetailPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: ExtendedImageSlidePage(
        slideAxis: SlideAxis.both,
        slideType: SlideType.onlyImage,
        slidePageBackgroundHandler: (offset, pageSize) {
          return Colors.transparent;
        },
        resetPageDuration: const Duration(milliseconds: 200),
        child: ExtendedImageGesturePageView(
          children: [
            ExtendedImage.network(
              widget.url,
              fit: BoxFit.contain,
              enableSlideOutPage: true,
              heroBuilderForSlidingPage: (image) => Hero(
                tag: widget.url,
                flightShuttleBuilder: (
                  flightContext,
                  animation,
                  flightDirection,
                  fromHeroContext,
                  toHeroContext,
                ) {
                  final hero = (flightDirection == HeroFlightDirection.pop
                      ? fromHeroContext.widget
                      : toHeroContext.widget) as Hero;
                  return hero.child;
                },
                child: image,
              ),
              mode: ExtendedImageMode.gesture,
              initGestureConfigHandler: (s) {
                return GestureConfig(
                    minScale: 0.9,
                    animationMinScale: 0.7,
                    maxScale: 5.0,
                    animationMaxScale: 5.5,
                    speed: 1.0,
                    inertialSpeed: 100.0,
                    initialScale: 1.0,
                    inPageView: false);
              },
              loadStateChanged: (state) {
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
