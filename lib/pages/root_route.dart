import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:client/pages/post/post_page.dart';
import 'package:client/pages/resale_page.dart';
import 'package:client/util/my_icon/my_app_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../util/my_icon/my_icon.dart';
import 'about_me_page.dart';
import 'gather_page.dart';


class RootRoute extends StatefulWidget {
  const RootRoute({super.key});

  @override
  State<RootRoute> createState() => _RootRouteState();
}

class _RootRouteState extends State<RootRoute> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Widget> _pageList = []; //列表存放页面
  late int _selectedIndex; //bar下标
  late bool _hadCheckUpdate;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _hadCheckUpdate = false;
    _selectedIndex = 0;
    _pageController = PageController();
    //初始化页面列表
    _pageList
      ..add(const PostPage())
      ..add(const ResalePage())
      ..add(const GatherPage())
      ..add(const AboutMePage());
  }

  @override
  Widget build(BuildContext context) {
    if (!_hadCheckUpdate) {
      // CheckoutUpdateUtil.checkUpdate(context);
      _hadCheckUpdate = true;
    }
    return PopScope(
      onPopInvoked: (bool didPop) async{
          await _dialogExitApp(context);
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: _pageList,
        ),
        bottomNavigationBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                MyIcons.explore,
              ),
              label: '广场',
              activeIcon:
              Icon(MyIcons.explore_fill),
            ),
            BottomNavigationBarItem(
              icon: Icon(MyAppIcon.resale_solid),
              label: '交换',
              activeIcon:
              Icon(MyAppIcon.sale),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                MyAppIcon.bullhorn_solid,
              ),
              label: '搭子',
              activeIcon:
              Icon(MyAppIcon.bullhorn),
            ),
            BottomNavigationBarItem(
              icon: Icon(MyIcons.user),
              label: '我的',
              activeIcon:
              Icon(MyIcons.user_fill),
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: onTap,
        ),
      ),
    );
  }

  Future<bool> _dialogExitApp(BuildContext context) async {
    if (Platform.isAndroid) {
      AndroidIntent intent = const AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: "android.intent.category.HOME",
      );
      await intent.launch();
    }
    return Future.value(false);
  }

  void onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future onTap(int index) async {
      _pageController.jumpToPage(index);
  }
}
