import 'package:client/pages/activity/my_collected_activity.dart';
import 'package:client/pages/activity/my_registered_activity.dart';
import 'package:client/pages/post/common_post.dart';
import 'package:client/pages/user/update_user_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../about_page.dart';
import '../post/collected_post.dart';
import '../resale/goods_collect.dart';
import '../resale/my_order.dart';
import 'fans_page.dart';
import 'follow_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        children: [
          _buildSectionCard(
            context,
            items: [
              _buildSettingItem(context,'编辑资料', const UpdateUserDetailPage()),
              _buildSettingItem(context,'我的关注', const FollowPage()),
              _buildSettingItem(context,'我的粉丝', const FansPage()),
              _buildSettingItem(context,'收藏帖子', const CollectedPost()),
              _buildSettingItem(context,'收藏闲置', const GoodsCollectPage()),
              _buildSettingItem(context,'我的订单', const MyOrderPage()),
              _buildSettingItem(context,'收藏活动', const MyCollectedActivity()),
              _buildSettingItem(context,'报名记录', const MyRegisteredActivity()),
              _buildSettingItem(context,'关于软件', AboutPage()),
            ],
          ),
          SizedBox(height: 40.h),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {
    required List<Widget> items,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._divideItems(items),
        ],
      ),
    );
  }

  List<Widget> _divideItems(List<Widget> items) {
    return List.generate(items.length * 2 - 1, (index) {
      if (index.isOdd) return Divider(height: 1, indent: 16.w, endIndent: 16.w);
      return items[index ~/ 2];
    });
  }

  Widget _buildSettingItem(BuildContext context,String title, Widget page) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      title: Text(
        title,
        style: TextStyle(fontSize: 15.sp),
      ),
      trailing: Icon(Icons.chevron_right, size: 20.w, color: Colors.grey),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: Size(double.infinity, 48.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.remove('profile');
          Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
                  (route) => false
          );
        },
        child: Text(
          '退出登录',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}