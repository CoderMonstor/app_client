import 'package:client/pages/about_me_page.dart';
import 'package:client/pages/gather_page.dart';
import 'package:client/pages/resale_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_icons/line_icons.dart';

import 'home_page.dart';

class RootRoute extends StatefulWidget {
  const RootRoute({super.key});

  @override
  State<RootRoute> createState() => _RootRouteState();
}

class _RootRouteState extends State<RootRoute> {
  final List<Widget> _pageList = [];
  late int selectedIndex;
  late PageController _pageController;

  void onTap(int index) {
    setState(() {
      selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  void onPageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
    _pageController = PageController();
    // 初始化页面列表
    _pageList
      ..add(MyHomePage())
      ..add(ResalePage())
      ..add(GatherPage())
      ..add(AboutMePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _pageList,
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              LineIcons.home,
              size: ScreenUtil().setWidth(75),
            ),
            label: '首页',
            activeIcon: Icon(
              LineIcons.home,
              size: ScreenUtil().setWidth(75 * 1.2), // 放大1.2倍
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              LineIcons.handHoldingUsDollar,
              size: ScreenUtil().setWidth(75),
            ),
            label: '交易',
            activeIcon: Icon(
              LineIcons.handHoldingUsDollar,
              size: ScreenUtil().setWidth(75 * 1.2),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              LineIcons.bullhorn,
              size: ScreenUtil().setWidth(75),
            ),
            label: '通知',
            activeIcon: Icon(
              LineIcons.bullhorn,
              size: ScreenUtil().setWidth(75 * 1.2),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              LineIcons.user,
              size: ScreenUtil().setWidth(75),
            ),
            label: '我',
            activeIcon: Icon(
              LineIcons.user,
              size: ScreenUtil().setWidth(75 * 1.2),
            ),
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onTap,
      ),
    );
  }
}
