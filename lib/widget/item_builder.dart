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
import '../core/net/my_api.dart';
import '../core/net/net_request.dart';
import '../util/toast.dart';
import 'my_list_tile.dart';
class ItemBuilder {
  static Widget buildUserRow(BuildContext context, User user, int type) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child:Text("${user.email}"),
    );
  }

  static buildForwardRow(BuildContext context, Post post) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Text(post.text!),
    );
  }

  static buildComment(BuildContext context, Comment comment, CommentRepository list, int index) {
    late String reply;
    if (comment.replyNum == 1) {
      reply = buildReply(comment.replyList![0], true);
    } else if (comment.replyList?.length == 2) {
      reply = '${buildReply(comment.replyList![0], true)}\n${buildReply(comment.replyList![1], true)}';
    }
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Text('${comment.likeNum}'),
    );
  }

  static buildReplyRow(BuildContext context, Reply reply, ReplyRepository list,
      int index) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Text('${reply.text}'),
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
              textStyle: TextStyle(fontSize: ScreenUtil().setSp(48),
                  color: Colors.black),
              color: Colors.black12,
              child: Text("$userId"),
            ),
          );
        }
    );
  }

  static buildCommentDialogCard(BuildContext context, Comment comment, LoadingMoreBase list, int index) {
    return <Widget>[
      MyListTile(
        onTap: () {
          Navigator.pop(context);
        },
        leading: Text('复制'),
      ),
      MyListTile(
        onTap: () {
          Navigator.pop(context);
        },
        leading: Text('回复'),
      ),
      Offstage(
        offstage: comment.userId != Global.profile.user!.userId,
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
          leading: Text('删除'),
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
        leading: Text('复制'),
      ),
      MyListTile(
        onTap: () {
          Navigator.pop(context);
        },
        leading: Text('回复'),
      ),
      Offstage(
        offstage: reply.userId != Global.profile.user!.userId,
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
          leading: const Text('删除'),
        ),
      ),
    ];
  }
}
