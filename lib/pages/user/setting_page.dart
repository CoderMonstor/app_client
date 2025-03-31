import 'package:client/pages/resale/goods_collect.dart';
import 'package:client/pages/user/fans_page.dart';
import 'package:client/pages/user/follow_page.dart';
import 'package:client/pages/user/update_user_detail_page.dart';
import 'package:client/widget/setting_tail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../about_page.dart';

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
          const SettingTail(title: '我的收藏',page: GoodsCollectPage(),),
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
