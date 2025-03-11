import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/global.dart';
import '../core/model/post.dart';
import '../core/net/my_api.dart';
import '../core/net/net_request.dart';
import '../util/toast.dart';
import 'my_list_tile.dart';

class DialogBuild {

  static Future showPostDialog(BuildContext context,int? postId) async {
    bool isCurrentUser=false;
    var res = await NetRequester.request(Apis.getPostByPostId(postId!));
    Post post= Post.fromJson(res['data']);
    if(Global.profile.user!.userId==post.userId) {
      isCurrentUser=true;
    }
    return showDialog(
      context: context,
      barrierDismissible: true, // 是否允许点击屏幕或物理键关闭对话框
      builder: (BuildContext context) {
        return Material(
          textStyle: TextStyle(fontSize: ScreenUtil().setSp(48), color: Colors.black),
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
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(21)),
                  ),
                  child: Container(
                    width: ScreenUtil().setWidth(300),
                    height: ScreenUtil().setHeight(isCurrentUser?160:130),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(60),
                        vertical: ScreenUtil().setHeight(40)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        MyListTile(
                          onTap: () async {
                            String url;
                            if (post.isStar==1) {
                              url = Apis.cancelStarPost(postId);
                            } else {
                              url = Apis.starPost(postId);
                            }
                            var res = await NetRequester.request(url);
                            if (res['code'] == '1') {
                              Navigator.pop(context);
                              Toast.popToast('已收藏');
                              post.isStar =
                              post.isStar == 1 ? 0 : 1;
                            }
                          },
                          leading:
                          Text(post.isStar == 0 ? '收藏' : '取消收藏'),
                        ),
                        MyListTile(
                          onTap: () {},
                          leading: const Text('举报'),
                        ),
                        Offstage(
                          //当isCurrentUser为false时，不显示
                          offstage: !isCurrentUser,
                          child: MyListTile(
                            onTap: ()=>_deletePost(context,postId),
                            leading: const Text('删除'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });

  }

  static void _deletePost(BuildContext context,int postId) {
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('确定删除吗？'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  var res = await NetRequester.request(Apis.deletePost(postId));
                  if (res['code'] == '1') {
                    Navigator.pushNamed(context, 'root');
                    Toast.popToast('已删除');
                  }else {
                    Toast.popToast('删除失败');
                  }
                },
                child: const Text('确定'),
              ),
            ],
          );
        });
  }
}



