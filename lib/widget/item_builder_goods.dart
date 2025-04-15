import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../core/global.dart';
import '../core/list_repository/goods_comment_repo.dart';
import '../core/list_repository/goods_reply_repo.dart';
import '../core/model/goods_comment.dart';
import '../core/model/goods_reply.dart';
import '../core/net/my_api.dart';
import '../core/net/net.dart';
import '../core/net/net_request.dart';
import '../pages/resale/goods_reply_page.dart';
import '../pages/resale/resale_common_dialog.dart';
import '../pages/user/profile_page.dart';
import '../pages/view_images.dart';
import '../util/build_date.dart';
import '../util/text_util/special_text_span.dart';
import '../util/toast.dart';
import 'my_list_tile.dart';

class ItemBuilderGoods {

  static buildGoodsReplyRow(BuildContext context, GoodsReply reply, GoodsReplyRepository list, int index) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Stack(
        children: [
          MyListTile(
            onTap: () {
              _showDialog(context,
                  buildGoodsReplyDialogCard(context,reply,list,index),reply.userId!);
            },
            crossAxis: CrossAxisAlignment.start,
            betweenLeadingAndCenter: 10,
            left: 20,
            leading: InkWell(
              onTap: () {
                Navigator.push(context,
                    CupertinoPageRoute(
                        builder: (context) => ProfilePage(userId: reply.userId)));
              },
              child: Column(
                children: [
                  SizedBox(height: ScreenUtil().setHeight(10)),
                  SizedBox(
                    height: ScreenUtil().setHeight(60),
                    child: reply.avatarUrl == '' || reply.avatarUrl == null
                        ? Image.asset("images/flutter_logo.png")
                        : ClipOval(
                      child: ExtendedImage.network('${NetConfig.ip}/images/${reply.avatarUrl!}', cache: true),
                    ),
                  ),
                ],
              ),
            ),
            center: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reply.username ?? '用户${reply.userId}',
                            style: TextStyle(fontSize: ScreenUtil().setSp(24))),
                        Text(buildDate(reply.date!),
                            style: TextStyle(
                                color: Colors.grey, fontSize: ScreenUtil().setSp(17))),
                      ],
                    ),
                    SizedBox(width: ScreenUtil().setWidth(90),),
                  ],
                ),
                SizedBox(height: ScreenUtil().setHeight(10)),
                SizedBox(
                  width: ScreenUtil().setWidth(300),
                  child: ExtendedText(
                    buildGoodsReply(reply, false),
                    style: TextStyle(fontSize: ScreenUtil().setSp(23)),
                    specialTextSpanBuilder: MySpecialTextSpanBuilder(context: context),
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight(15)),
                reply.imageUrl != ''
                    ? InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ViewImgPage(
                                      images: [reply.imageUrl],
                                      index: 0,
                                      id: reply.goodsCommentId.toString())));
                    },
                    child: Hero(
                        tag: '${reply.goodsCommentId}${reply.imageUrl}0',
                        child: Container(
                            constraints: BoxConstraints(
                                maxHeight: ScreenUtil().setHeight(300),
                                maxWidth: ScreenUtil().setWidth(300)),
                            child: ExtendedImage.network(
                                NetConfig.ip + reply.imageUrl!,
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
                )
                    : const SizedBox(height: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showDialog(BuildContext context, List<Widget> card,int userId) {
    showDialog(
        context: context,
        builder: (context) {
          return Material(
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
                    height: ScreenUtil().setHeight(1920),
                  ),
                ),
                Center(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(21)),),
                    child: Container(
                      width: ScreenUtil().setWidth(300),
                      height: ScreenUtil().setHeight(userId != Global.profile.user?.userId ? 105 : 150),
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
          );
        }
    );
  }

  static List<Widget> buildGoodsReplyDialogCard(BuildContext context, GoodsReply reply, LoadingMoreBase list, int index) {
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
                return ResaleCommentDialog(
                    commentId: reply.goodsCommentId,beReplyName: reply.username, list: list);
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
                Apis.deleteGoodsReply(reply.replyId!));
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

  static String buildGoodsReply(GoodsReply reply, bool showUsername) {
    var center = '';
    if (reply.beReplyName != '') {
      center = '回复@${reply.beReplyName} ';
    }
    if (showUsername) {
      return '${reply.username} $center:${reply.text}';
    }
    return '$center${reply.text}';
  }

  static buildGoodsCommentDialogCard(BuildContext context, GoodsComment comment, LoadingMoreBase list, int index) {
    return <Widget>[
      MyListTile(
        onTap: () {
          Navigator.pop(context);
          showDialog(context: context,
              builder: (context) {
                return ResaleCommentDialog(commentId: comment.commentId, list: list);
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
            var res = await NetRequester.request(Apis.deleteGoodsComment(comment.commentId!));
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

  static buildGoodsComment(BuildContext context, GoodsComment comment, GoodsCommentRepository list, int index) {
    String reply='';
    if (comment.replyNum == 1) {
      reply = buildGoodsReply(comment.goodsReplyList![0], true);
    } else if (comment.goodsReplyList?.length == 2) {
      reply = '${buildGoodsReply(comment.goodsReplyList![0], true)}\n${buildGoodsReply(comment.goodsReplyList![1], true)}';
    }
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      child: MyListTile(
        onTap: () {
          _showDialog(context,
              buildGoodsCommentDialogCard(context, comment, list, index),comment.userId!);
        },
        crossAxis: CrossAxisAlignment.start,
        betweenLeadingAndCenter: 10,
        top: 10,
        left: 10,
        leading: InkWell(
          onTap: () {
            Navigator.push(context,
                CupertinoPageRoute(
                    builder: (context) => ProfilePage(userId: comment.userId)));
          },
          child: Column(
            children: [
              SizedBox(height: ScreenUtil().setHeight(10)),
              SizedBox(
                height: ScreenUtil().setHeight(50),
                child: comment.avatarUrl == '' || comment.avatarUrl == null
                    ? Image.asset("images/flutter_logo.png")
                    : ClipOval(
                      child: ExtendedImage.network('${NetConfig.ip}/images/${comment.avatarUrl!}', cache: true),
                ),
              ),
            ],
          ),
        ),
        center: SizedBox(
          width: 330.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.username ?? '用户${comment.userId}',
                      style: TextStyle(fontSize: ScreenUtil().setSp(24))),
                  Text(buildDate(comment.date!),
                      style: TextStyle(
                          color: Colors.grey, fontSize: ScreenUtil().setSp(17))),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              ExtendedText(
                comment.text!,
                style: TextStyle(fontSize: ScreenUtil().setSp(20)),
                specialTextSpanBuilder: MySpecialTextSpanBuilder(context: context),
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              comment.imageUrl != ''
                  ? SizedBox(
                height: ScreenUtil().setHeight(200),
                width: ScreenUtil().setWidth(200),
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ViewImgPage(
                                          images: [comment.imageUrl],
                                          index: 0,
                                          id: comment.commentId.toString())));
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
              )
                  : const SizedBox(height: 0),
              SizedBox(height: ScreenUtil().setHeight(10)),
              comment.replyNum! > 0
                  ? InkWell(
                onTap: () {
                  Navigator.push(context,
                      CupertinoPageRoute(
                          builder: (context) => GoodsReplyPage(comment: comment,)));
                },
                    child: Container(
                      width: ScreenUtil().setWidth(350),
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
                            specialTextSpanBuilder: MySpecialTextSpanBuilder(context: context),
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(23)
                            ),
                          ),
                          comment.replyNum! > 2
                              ? Container(
                            margin: EdgeInsets.symmetric(
                                vertical: ScreenUtil().setHeight(15)),
                                child: Text(
                                  '共${comment.replyNum}条回复',
                                  style: TextStyle(color: Theme
                                      .of(context)
                                      .colorScheme.secondary),
                                ),
                              )
                              : const SizedBox(height: 0),
                        ],
                      ),
                    ),
              )
                  : const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }

}



