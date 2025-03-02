/*
根据postId获取帖子信息，并显示
返回一个帖子卡片，点击可以跳转到帖子详情页
 */
import 'package:client/widget/image_build.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/list_repository/post_repo.dart';
import '../core/maps.dart';
import '../core/model/post.dart';
import '../core/net/my_api.dart';
import '../core/net/net.dart';
import '../core/net/net_request.dart';
import '../pages/user/profile_page.dart';
import '../pages/post/post_detail.dart';
import '../util/build_date.dart';
import '../util/my_icon/my_icon.dart';
import 'dialog_build.dart';
import 'my_list_tile.dart';


class PostCard extends StatefulWidget {
  final Post? post;
  final PostRepository? list;
  final int? index;

  const PostCard({this.post, this.list, this.index, super.key});
  @override
  State<StatefulWidget> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String textSend = '';
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(24),
            vertical: ScreenUtil().setHeight(30)),
        // 点击事件，如果点击了帖子，则跳转到帖子详情页
        // 长按帖子，则弹出一个对话框，让用户选择是否删除帖子
        child: InkWell(
          onLongPress: () {
            DialogBuild.showPostDialog(context, widget.post?.postId);
          },
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => PostDetailPage(
                      postId: widget.post?.postId,
                      offset: 0,
                    )));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[_postInfo(), _buildContent(), _likeBar(context)],
          ),
        ),
      ),
    );
  }
  // 帖子信息
  _postInfo() {
    return MyListTile(
      // top: 0,
      bottom: ScreenUtil().setWidth(20),
      // left: 0,
      // right: 0,
      // useScreenUtil: false,
      leading: SizedBox(
        width: ScreenUtil().setWidth(60),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) =>
                        ProfilePage(userId: widget.post?.userId)));
          },
          child: SizedBox(
            height: ScreenUtil().setWidth(60),
            child: widget.post?.avatarUrl == '' || widget.post?.avatarUrl == null
                ? Image.asset("assets/images/app_logo.png")
                : ClipOval(
                  child: ExtendedImage.network(
                      '${NetConfig.ip}/images/${widget.post!.avatarUrl}',
                      cache: true),
            ),
          ),
        ),
      ),
      center: Row(
        children: [
          SizedBox(width: ScreenUtil().setWidth(20)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(widget.post!.username!,
                  style: TextStyle(fontSize: ScreenUtil().setSp(20))),
              Text(buildDate(widget.post!.date!),
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(14), color: Colors.grey)),
            ],
          ),
        ],
      ),
      trailing: SizedBox(
        width: ScreenUtil().setWidth(40),
        child: TextButton(
          style: TextButton.styleFrom(
            // padding: const EdgeInsets.all(0),
          ),
          onPressed: () {
            DialogBuild.showPostDialog(context, widget.post?.postId);
          },
          child: const Icon(MyIcons.and_more, color: Colors.grey),
        ),
      ),
    );
  }

  _postText(String text) {
    return ExtendedText(
      text,
    );
  }

  _buildImage() {
    String url;
    if (widget.post?.forwardId != null) {
      url = widget.post?.forwardImageUrl ?? "";
    } else {
      url = widget.post?.imageUrl ?? "";
    }
    List images = url.split('￥');
    if (images[0] == '') {
      return Container();
    } else if (images.length == 1) {
      return ImageBuild.singlePostImage(images);
    } else {
      return ImageBuild.multiPostImage(images);
    }
  }

  _buildContent() {
    //如果不是转发，则显示文本和图片
    if (widget.post?.forwardId == null) {
      var text = widget.post?.text;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          text == '' ? Container() : _postText(text!),
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          _buildImage(),
        ],
      );
    } else {
      var text = widget.post?.text;
      var index = text?.indexOf('//@');
      if (widget.post?.imageUrl != '') {
        switch (index) {
          case -1:
            text = '$text ￥-${widget.post?.imageUrl}-￥';
            break;
          case 0:
            text = ' ￥-${widget.post?.imageUrl}-￥$text';
            break;
          default:
            text = '${text!.substring(0, index! - 1)} ￥-${widget.post?.imageUrl}-￥${text.substring(index, text.length)}';
        }
      }
      textSend = text!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          text == '' ? Container() : _postText(text),
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => PostDetailPage(
                        offset: 0,
                        postId: widget.post?.forwardId,
                      )));
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(20),
                  vertical: ScreenUtil().setHeight(10)),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.06),
                  borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(21))),
              child: _buildForward(),
            ),
          ),
        ],
      );
    }
  }

  _likeBar(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setHeight(60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
            onPressed: () async {
              if (widget.post != null && widget.post!.isLiked == 0) {
                var res = await NetRequester.request(Apis.likePost(widget.post!.postId!));
                if (res['code'] == '1') {
                  setState(() {
                    widget.post!.isLiked = 1;
                    widget.post!.likeNum = (widget.post!.likeNum ?? 0) + 1;
                  });
                }
              } else if (widget.post != null && widget.post!.isLiked == 1) {
                var res = await NetRequester.request(Apis.cancelLikePost(widget.post!.postId!));
                if (res['code'] == '1') {
                  setState(() {
                    widget.post!.isLiked = 0;
                    widget.post!.likeNum = (widget.post!.likeNum ?? 0) - 1;
                  });
                }
              }
            },
            style: TextButton.styleFrom(
              // padding: EdgeInsets.all(0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  widget.post?.isLiked == 1 ? MyIcons.like_fill : MyIcons.like,
                  color: widget.post?.isLiked == 1
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey,
                  size: ScreenUtil().setWidth(30),
                ),
                SizedBox(width: ScreenUtil().setWidth(5)),
                Text(
                  widget.post!.likeNum.toString(),
                  style: TextStyle(
                    color: widget.post?.isLiked == 1
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => PostDetailPage(
                    postId: widget.post?.postId,
                    offset: 1,
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  MyIcons.comment,
                  color: Colors.grey,
                  size: ScreenUtil().setWidth(30),
                ),
                SizedBox(width: ScreenUtil().setWidth(5)),
                Text(
                  widget.post!.commentNum.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () {
            },
            style: TextButton.styleFrom(
              // padding: EdgeInsets.all(0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  MyIcons.share,
                  color: Colors.grey,
                  size: ScreenUtil().setWidth(30),
                ),
                SizedBox(width: ScreenUtil().setWidth(5)),
                Text(
                  widget.post!.forwardNum.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }



  _buildForward() {
    if (widget.post?.forwardId != null && widget.post?.forwardName == null) {
      return const SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Icon(Icons.error_outline),
            Text('哦豁，内容已不在了'),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _postText('@${widget.post!.forwardName} ：${widget.post!.forwardText}' ?? ''),
          _buildImage(),
        ],
      );
    }
  }
}
