import 'package:client/pages/user/update_user_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/my_icon/my_icon.dart';
import '../widget/my_list_tile.dart';
import 'about_page.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: ScreenUtil().setHeight(40)),
          MyListTile(
            left: 40,
            leading: Text(
              '头像与个人信息',
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w500),
            ),
            trailing: Icon(
                MyIcons.right, size: ScreenUtil().setWidth(25), color: Colors.grey
            ),
            onTap: () {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => const UpdateUserDetailPage()));
            },
          ),
          Divider(indent: ScreenUtil().setWidth(40)),
          MyListTile(
            left: 40,
            leading: Text(
              '关于',
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w500),
            ),
            trailing: Icon(
              MyIcons.right,
              size: ScreenUtil().setWidth(25),
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => AboutPage()));
            },
          ),
          Divider(indent: ScreenUtil().setWidth(40)),
          TextButton(
            onPressed: () async {
              SharedPreferences _prefs = await SharedPreferences.getInstance();
              _prefs.remove('profile');
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              backgroundColor: Colors.white,
            ),
            child: Text(
              '退出登录',
              style: TextStyle(
                color: Colors.red,
                fontSize: ScreenUtil().setSp(24),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
