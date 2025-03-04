import 'package:client/pages/user/update_user_detail_page.dart';
import 'package:client/widget/setting_tail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../util/app_bar/my_app_bar.dart';
import '../util/my_icon/my_icon.dart';
import '../widget/my_list_tile.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.simpleAppbar("消息"),
      body: ListView(
        children: <Widget>[
          MyListTile(
            crossAxis: CrossAxisAlignment.center,
            leading: SizedBox(
              height: ScreenUtil().setWidth(100),
              child: const Row(
                children: [
                  SizedBox(width: 30,),
                  CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    maxRadius: 30.0,
                    child: Icon(
                      MyIcons.like,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            center: Row(
              children: [
                const SizedBox(width: 20,),
                Text(
                  '收到的赞',
                  style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                ),
              ],
            ),
            trailing: Row(
              children: [
                Icon(
                  MyIcons.right,
                  size: ScreenUtil().setWidth(30),
                  color: Colors.grey,
                ),
                const SizedBox(width: 30,),
              ],
            ),
            onTap: () {},
          ),
          MyListTile(
            crossAxis: CrossAxisAlignment.center,
            leading: SizedBox(
              height: ScreenUtil().setWidth(100),
              child: const Row(
                children: [
                  SizedBox(width: 30,),
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    maxRadius: 30.0,
                    child: Icon(
                      MyIcons.comment,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            center: Row(
              children: [
                const SizedBox(width: 20,),
                Text(
                  '收到的评论',
                  style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                ),
              ],
            ),
            trailing: Row(
              children: [
                Icon(
                  MyIcons.right,
                  size: ScreenUtil().setWidth(30),
                  color: Colors.grey,
                ),
                const SizedBox(width: 30,),
              ],
            ),
            onTap: () {},
          ),
          MyListTile(
            crossAxis: CrossAxisAlignment.center,
            leading: SizedBox(
              height: ScreenUtil().setWidth(100),
              child: const Row(
                children: [
                  SizedBox(width: 30,),
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    maxRadius: 30.0,
                    child: Icon(
                      MyIcons.comment,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            center: Row(
              children: [
                const SizedBox(width: 20,),
                Text(
                  '好友关注',
                  style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                ),
              ],
            ),
            trailing: Row(
              children: [
                Icon(
                  MyIcons.right,
                  size: ScreenUtil().setWidth(30),
                  color: Colors.grey,
                ),
                const SizedBox(width: 30,),
              ],
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
