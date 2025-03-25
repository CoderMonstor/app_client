import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../core/global.dart';
import '../core/list_repository/comment_repo.dart';
import '../core/list_repository/reply_repo.dart';
import '../core/model/comment.dart';
import '../core/model/post.dart';
import '../core/model/reply.dart';
import '../core/model/user.dart';
import '../core/model/user_model.dart';
import '../core/net/my_api.dart';
import '../core/net/net.dart';
import '../core/net/net_request.dart';
import '../pages/chat/chat_page.dart';
import '../pages/post/common_dialog.dart';
import '../pages/post/reply_page.dart';
import '../pages/user/profile_page.dart';
import '../pages/view_images.dart';
import '../util/build_date.dart';
import '../util/my_icon/my_icon.dart';
import '../util/text_util/special_text_span.dart';
import '../util/toast.dart';
import 'my_list_tile.dart';

class ItemBuilder {
  static Widget buildUserRow(BuildContext context, User user, int type) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: MyListTile(
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ProfilePage(userId: user.userId)));
          },
          left: 40,
          leading: SizedBox(
            height: ScreenUtil().setHeight(110),
            child: user.avatarUrl?.isNotEmpty == true
                ? ClipOval(
              child: ExtendedImage.network('${NetConfig.ip}/images/${user.avatarUrl}', cache: true),
            )
                : Image.asset("images/flutter_logo.png"),
          ),
          center: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(user.username ?? '用户${user.userId}',
                  style: TextStyle(fontSize: ScreenUtil().setSp(48))),
              Row(
                children: <Widget>[
                  Text('${user.followNum}关注',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: ScreenUtil().setSp(34))),
                  SizedBox(width: ScreenUtil().setWidth(10)),
                  Text('${user.fanNum}粉丝',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: ScreenUtil().setSp(34))),
                ],
              ),
              if (user.bio?.isNotEmpty == true)
                Text(user.bio!,
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: ScreenUtil().setSp(34))),
            ],
          ),
          trailing: type == 1
              ? FollowButton(user: user)
              : type == 2
              ? IconButton(
                  icon: const Icon(
                    Icons.mail_outline,
                    color: Colors.grey,
                  ),
                  onPressed: () async {
                    try {
                      await Navigator.push(context,
                          CupertinoPageRoute(builder: (context) =>
                              ChatPage(user: user)));
                    } catch (e) {
                      // Handle navigation error
                      print('Navigation error: $e');
                    }
                  },
              )
              : Container()),
    );
  }

  static buildForwardRow(BuildContext context, Post post) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: MyListTile(
        onTap: () async {
          try {
            await Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ProfilePage(userId: post.userId)));
          } catch (e) {
            // Handle navigation error
            print('Navigation error: $e');
          }
        },
        left: 40,
        leading: Container(
          height: ScreenUtil().setHeight(110),
          child: post.avatarUrl?.isNotEmpty == true
              ? ClipOval(
                child: ExtendedImage.network(NetConfig.ip+'/images/'+post.avatarUrl!, cache: true),
              )
              : Image.asset("images/flutter_logo.png"),
        ),
        center: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(post.username ?? '用户${post.userId}',
                style: TextStyle(fontSize: ScreenUtil().setSp(24))),
            Text(buildDate(post.date!),
                style: TextStyle(
                    color: Colors.grey, fontSize: ScreenUtil().setSp(34))),
            ExtendedText(
              post.text!,
              specialTextSpanBuilder:
              MySpecialTextSpanBuilder(context: context),
            )
          ],
        ),
      ),
    );
  }

  static buildComment(BuildContext context, Comment comment,
      CommentRepository list, int index) {
    String reply = '';
    if (comment.replyNum == 1) {
      reply = buildReply(comment.replyList![0], true);
    } else if (comment.replyList?.length == 2) {
      reply = '${buildReply(comment.replyList![0], true)}\n${buildReply(comment.replyList![1], true)}';
    }
    return Card(
      elevation: 0,
      child: MyListTile(
        onTap: () async {
          try {
            _showDialog(context,
                buildCommentDialogCard(context, comment, list, index), comment.userId!);
          } catch (e) {
            // Handle dialog error
            print('Dialog error: $e');
          }
        },
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                try {
                  await Navigator.push(context,
                      CupertinoPageRoute(
                          builder: (context) => ProfilePage(userId: comment.userId)));
                } catch (e) {
                  // Handle navigation error
                  print('Navigation error: $e');
                }
              },
              child: SizedBox(
                height: ScreenUtil().setHeight(50),
                child: comment.avatarUrl?.isNotEmpty == true
                    ? ClipOval(
                      child: ExtendedImage.network('${NetConfig.ip}/images/${comment.avatarUrl!}', cache: true),
                    )
                    : Image.asset("images/flutter_logo.png"),
              ),
            ),
          ],
        ),
        center: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(comment.username ?? '用户${comment.userId}',
                    style: TextStyle(fontSize: ScreenUtil().setSp(24))),
                SizedBox(width: ScreenUtil().setWidth(200)),
                SizedBox(
                  height: ScreenUtil().setHeight(60),
                  width: ScreenUtil().setWidth(150),
                  child: TextButton.icon(
                    onPressed: () async {
                      try {
                        var url = comment.isLiked == 1
                            ? Apis.cancelLikeComment(comment.commentId!)
                            : Apis.likeComment(comment.commentId!);
                        var res = await NetRequester.request(url);
                        if (res['code'] == '1') {
                            if (comment.isLiked == 1) {
                              comment.isLiked = 0;
                              comment.likeNum = (comment.likeNum ?? 0) - 1;
                            } else {
                              comment.isLiked = 1;
                              comment.likeNum = (comment.likeNum ?? 0) + 1;
                            }
                        }
                      } catch (e) {
                        // Handle network request error
                        print('Network request error: $e');
                      }
                    },
                    icon: Icon(
                      comment.isLiked == 1 ? MyIcons.like_fill : MyIcons.like,
                      color: comment.isLiked == 1
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey,
                      size: ScreenUtil().setHeight(25),
                    ),
                    label: Text(comment.likeNum.toString()),
                    style: TextButton.styleFrom(
                      foregroundColor: comment.isLiked == 1
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey,
                    ),
                  ),
                )
              ],
            ),
            Text(buildDate(comment.date!),
                style: TextStyle(
                    color: Colors.grey, fontSize: ScreenUtil().setSp(17))),
            SizedBox(height: ScreenUtil().setHeight(20)),
            ExtendedText(
              comment.text!,
              style: TextStyle(fontSize: ScreenUtil().setSp(23)),
              specialTextSpanBuilder:
              MySpecialTextSpanBuilder(context: context),
            ),
            SizedBox(height: ScreenUtil().setHeight(15)),
            if (comment.imageUrl?.isNotEmpty == true)
              SizedBox(
                height: ScreenUtil().setHeight(200),
                width: ScreenUtil().setWidth(200),
                child: InkWell(
                  onTap: () async {
                    try {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ViewImgPage(
                                      images: [comment.imageUrl],
                                      index: 0,
                                      id: comment.commentId.toString())));
                    } catch (e) {
                      // Handle navigation error
                      print('Navigation error: $e');
                    }
                  },
                  child: Hero(
                      tag: '${comment.commentId}${comment.imageUrl}0',
                      child: Container(
                          constraints: BoxConstraints(
                              maxHeight: ScreenUtil().setHeight(600),
                              maxWidth: ScreenUtil().setWidth(600)),
                          child: ExtendedImage.network(
                              NetConfig.ip + comment.imageUrl!,
                              cache: true,
                              fit: BoxFit.cover,
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                  color: Colors.black12, width: 0.5),
                              borderRadius: BorderRadius.circular(
                                  ScreenUtil().setWidth(21))
                          )
                      )
                  )
                ),
              ),
            SizedBox(height: ScreenUtil().setHeight(10)),
            if (comment.replyNum! > 0)
              InkWell(
                onTap: () async {
                  try {
                    await Navigator.push(context,
                        CupertinoPageRoute(
                            builder: (context) => ReplyPage(comment: comment)));
                  } catch (e) {
                    // Handle navigation error
                    print('Navigation error: $e');
                  }
                },
                child: Container(
                  width: ScreenUtil().setWidth(820),
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(20),
                      vertical: ScreenUtil().setHeight(10)),
                  margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(15)),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.06),
                      borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(21))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ExtendedText(
                        reply,
                        specialTextSpanBuilder: MySpecialTextSpanBuilder(
                            context: context),
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(46)
                        ),
                      ),
                      if (comment.replyNum! > 2)
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setHeight(15)),
                          child: Text(
                            '共${comment.replyNum}条回复',
                            style: TextStyle(color: Theme
                                .of(context)
                                .colorScheme.secondary),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            Container(
              width: ScreenUtil().setWidth(800),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.3, color: Colors.grey[200]!)
              ),
            )
          ],
        ),
      ),
    );
  }

  static buildReplyRow(BuildContext context, Reply reply, ReplyRepository list,
      int index) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: MyListTile(
        onTap: () async {
          try {
            _showDialog(context,
                buildReplyDialogCard(context, reply, list, index), reply.userId!);
          } catch (e) {
            // Handle dialog error
            print('Dialog error: $e');
          }
        },
        left: 40,
        leading: InkWell(
          onTap: () async {
            try {
              await Navigator.push(context,
                  CupertinoPageRoute(
                      builder: (context) => ProfilePage(userId: reply.userId)));
            } catch (e) {
              // Handle navigation error
              print('Navigation error: $e');
            }
          },
          child: Container(
            height: ScreenUtil().setHeight(110),
            child: reply.avatarUrl?.isNotEmpty == true
                ? ClipOval(
                  child: ExtendedImage.network(reply.avatarUrl!, cache: true),
                )
                : Image.asset("images/flutter_logo.png"),
          ),
        ),
        center: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(reply.username ?? '用户${reply.userId}',
                    style: TextStyle(fontSize: ScreenUtil().setSp(48))),
                SizedBox(width: ScreenUtil().setWidth(610)),
                SizedBox(height: ScreenUtil().setHeight(60),
                  width: ScreenUtil().setWidth(150),
                  child:
                  TextButton.icon(onPressed: () async {
                    try {
                      var url = reply.isLiked == 1
                          ? Apis.cancelLikeReply(reply.replyId!)
                          : Apis.likeReply(reply.replyId!);
                      var res = await NetRequester.request(url);
                      if (res['code'] == '1') {
                          if (reply.isLiked == 1) {
                            reply.isLiked = 0;
                            reply.likeNum = reply.likeNum! - 1;
                          } else {
                            reply.isLiked = 1;
                            reply.likeNum = reply.likeNum! + 1;
                          }
                      }
                    } catch (e) {
                      // Handle network request error
                      print('Network request error: $e');
                    }
                  },
                      icon: Icon(
                        reply.isLiked == 1 ? MyIcons.like_fill : MyIcons.like,
                        color: reply.isLiked == 1
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.grey,
                        size: ScreenUtil().setHeight(50),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: reply.isLiked == 1
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.grey,
                      ),
                      label: Text(reply.likeNum.toString())
                  ),
                )
              ],
            ),
            Text(buildDate(reply.date!),
                style: TextStyle(
                    color: Colors.grey, fontSize: ScreenUtil().setSp(34))),
            SizedBox(height: ScreenUtil().setHeight(20)),
            ExtendedText(
              buildReply(reply, false),
              style: TextStyle(fontSize: ScreenUtil().setSp(46)),
              specialTextSpanBuilder:
              MySpecialTextSpanBuilder(context: context),
            ),
            SizedBox(height: ScreenUtil().setHeight(15)),
            if (reply.imageUrl?.isNotEmpty == true)
              InkWell(
                onTap: () async {
                  try {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ViewImgPage(
                                    images: [reply.imageUrl],
                                    index: 0,
                                    id: reply.commentId.toString())));
                  } catch (e) {
                    // Handle navigation error
                    print('Navigation error: $e');
                  }
                },
                child: Hero(
                    tag: '${reply.commentId}${reply.imageUrl}0',
                    child: Container(
                        constraints: BoxConstraints(
                            maxHeight: ScreenUtil().setHeight(600),
                            maxWidth: ScreenUtil().setWidth(500)),
                        child: ExtendedImage.network(
                            NetConfig.ip + reply.imageUrl!,
                            cache: true,
                            fit: BoxFit.cover,
                            shape: BoxShape.rectangle,
                            border: Border.all(
                                color: Colors.black12, width: 0.5),
                            borderRadius: BorderRadius.circular(
                                ScreenUtil().setWidth(21)))))),
            Container(
              width: ScreenUtil().setWidth(800),
              margin: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.3, color: Colors.grey[200]!)
              ),
            )
          ],
        ),
      ),
    );
  }

  static String buildReply(Reply reply, bool showUsername) {
    var center = '';
    if (reply.beReplyName != '') {
      center = '回复@${reply.beReplyName} ';
    }
    if (showUsername) {
      return '@${reply.username} $center:${reply.text}';
    }
    return '$center${reply.text}';
  }

  static void _showDialog(BuildContext context, List<Widget> card,int userId) {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            child: Material(
              textStyle: TextStyle(fontSize: ScreenUtil().setSp(24),
                  color: Colors.black),
              color: Colors.black12,
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: Colors.transparent,
                      width: ScreenUtil().setWidth(1080),
                      height: ScreenUtil().setHeight(1920),),
                  ),
                  Center(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(21)),),
                      child: Container(
                        width: ScreenUtil().setWidth(740),
                        height: ScreenUtil().setHeight(
                            userId != Global.profile.user?.userId ? 300 : 400),
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(60),
                            vertical: ScreenUtil().setHeight(40)
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: card
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  static buildCommentDialogCard(BuildContext context, Comment comment,
      LoadingMoreBase list, int index) {
    return <Widget>[
      MyListTile(
        onTap: () {
          Navigator.pop(context);
        },
        leading: const Text('复制'),
      ),
      MyListTile(
        onTap: () {
          Navigator.pop(context);
          showDialog(context: context,
              builder: (context) {
                return CommentDialog(
                    commentId: comment.commentId, list: list);
              }
          );
        },
        leading: const Text('回复'),
      ),
      Offstage(
        offstage: comment.userId != Global.profile.user?.userId,
        child: MyListTile(
          onTap: () async {
            Navigator.pop(context);
            var res = await NetRequester.request(
                Apis.deleteComment(comment.commentId!));
            if (res['code'] == '1') {
              list.removeAt(index);
              list.setState();
              Toast.popToast('已删除');
            }
          },
          leading: const Text('删除'),
        ),
      ),
    ];
  }

  static List<Widget> buildReplyDialogCard(BuildContext context, Reply reply,
      LoadingMoreBase list, int index) {
    return <Widget>[
      MyListTile(
        onTap: () {
          Navigator.pop(context);
        },
        leading: const Text('复制'),
      ),
      MyListTile(
        onTap: () {
          Navigator.pop(context);
          showDialog(context: context,
              builder: (context) {
                return CommentDialog(
                    commentId: reply.commentId,beReplyName: reply.username,
                    list: list);
              }
          );
        },
        leading: const Text('回复'),
      ),
      Offstage(
        offstage: reply.userId != Global.profile.user?.userId,
        child: MyListTile(
          onTap: () async {
            Navigator.pop(context);
            var res = await NetRequester.request(
                Apis.deleteReply(reply.replyId!));
            if (res['code'] == '1') {
              list.removeAt(index);
              list.setState();
              Toast.popToast('已删除');
            }
          },
          leading: Text('删除'),
        ),
      ),
    ];
  }
}

class FollowButton extends StatefulWidget {
  final User? user;

  const FollowButton({super.key, this.user});
  @override
  State<StatefulWidget> createState() {
    return _FollowButtonState();
  }
}

class _FollowButtonState extends State<FollowButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(180),
      height: ScreenUtil().setHeight(70),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          side: BorderSide(color: Theme.of(context).primaryColor),
        ),
        child: Text(
          widget.user?.isFollow == 1 ? '相互关注' : '未关注',
          style: TextStyle(fontSize: ScreenUtil().setSp(36)),
        ),
        onPressed: () async {
          var fanId = Global.profile.user?.userId;
          var res = await NetRequester.request(widget.user?.isFollow == 0
              ? Apis.followAUser(fanId!, widget.user!.userId!)
              : Apis.cancelFollowAUser(fanId!, widget.user!.userId!));
          if (res['code'] == '1') {
            setState(() {
              widget.user?.isFollow = widget.user?.isFollow == 1 ? 0 : 1;
            });
            if (widget.user?.isFollow == 1) {
              if (Global.profile.user != null) {
                Global.profile.user!.followNum = (Global.profile.user!.followNum ?? 0) + 1;
                UserModel().notifyListeners();
              }
            } else {
              if (Global.profile.user != null && Global.profile.user!.followNum! > 0) {
                Global.profile.user!.followNum = (Global.profile.user!.followNum ?? 0) - 1;
                UserModel().notifyListeners();
              }
            }

          }
        },
      ),
    );
  }
}


