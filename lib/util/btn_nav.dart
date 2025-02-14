import 'package:badges/badges.dart' as badge_package;

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import 'bottom_bar/g_button.dart';
import 'bottom_bar/g_nav.dart';

class BtnNav extends StatefulWidget {

  const BtnNav({
    super.key,
  });

  @override
  State<BtnNav> createState() => _BtnNavState();
}

class _BtnNavState extends State<BtnNav> {

  @override
  Widget build(BuildContext context) {
    return GNav(
      tabBackgroundGradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Colors.lightBlue[100]!, Colors.cyan],
      ),
      //间隔
      gap: 8,
      // 圆角
      tabBorderRadius: 15,
      // 选中颜色
      color: Colors.grey[600],
      activeColor: Colors.white,
      iconSize: 16,
      textStyle: const TextStyle(fontSize: 12, color: Colors.white),
      tabBackgroundColor: Colors.grey[800]!,
      // 边框
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16.5),
      // 动画
      duration: const Duration(milliseconds: 800),
      tabs: const [
        GButton(
          icon: LineIcons.home,
          text: '主页',
        ),
        GButton(
          icon: LineIcons.shoppingBag,
          text: '交易',
        ),
        GButton(
          icon: LineIcons.bullhorn,
          text: '活动',
        ),
        GButton(
          icon: LineIcons.user,
          text: '我的',
        ),
      ],
    );
  }
}
