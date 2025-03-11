
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/model/msg_model.dart';
import 'message_details_page.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> with AutomaticKeepAliveClientMixin {
  List<MsgModel> data = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    // 模拟异步数据加载
    // await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求延迟
    setState(() {
      data.addAll([
        MsgModel(
          imageUrl: 'https://w.wallhaven.cc/full/jx/wallhaven-jxl31y.png',
          msg: '所以，这也仅仅是无用的令戒：🐮🐎',
          name: '造物主动态桌面Ⅰ群',
          time: '下午4:20',
        ),
        MsgModel(
          imageUrl: 'https://w.wallhaven.cc/full/jx/wallhaven-jxl31y.png',
          msg: '所以，这也仅仅是无用的令戒：🐮🐎',
          name: '造物主动态桌面Ⅰ群',
          time: '下午4:20',
        ),
        // 其他数据...
      ]);
      loading = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: loading
                ? ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(MessageDetailsPage(msgModel: data[index]),
                            transition: Transition.rightToLeft);
                      },
                      child: msgItem(data[index]),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 15);
                  },
                  itemCount: data.length,
                )
                : const Center(child: CircularProgressIndicator()), // 显示加载指示器
          ),
        ],
      ),
    );
  }

  Widget msgItem(MsgModel model) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          ClipOval(
            child: ExtendedImage.network(
              model.imageUrl, // 添加默认图片
              cache: true,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              loadStateChanged: (state) {
                if (state.extendedImageLoadState == LoadState.loading ||
                    state.extendedImageLoadState == LoadState.failed) {
                  return Shimmer.fromColors(
                    baseColor: Colors.red,
                    highlightColor: const Color.fromARGB(255, 240, 240, 240),
                    child: Container(
                      height: 50,
                      width: 50,
                      color: Colors.white,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        model.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        model.msg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      model.time,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

