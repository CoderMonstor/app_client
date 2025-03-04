import 'package:client/pages/fans_page.dart';
import 'package:client/pages/follow_page.dart';
import 'package:client/pages/user/update_user_detail_page.dart';
import 'package:client/widget/setting_tail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/my_icon/my_icon.dart';
import '../widget/my_list_tile.dart';
import 'about_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Column(
        children: <Widget>[
          const SettingTail(title: '编辑资料',page: UpdateUserDetailPage(), ),
          const SettingTail(title: '我的关注',page: FollowPage(),),
          const SettingTail(title: '我的粉丝',page: FansPage(),),
          SettingTail(title: '我的关注',page: AboutPage(),),
          SettingTail(title: '主题肤色', page: AboutPage(),),
          SettingTail(title: '我的粉丝',page: AboutPage(),),
          SizedBox(height: ScreenUtil().setHeight(100)),
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
              // backgroundColor: Colors.white,
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
