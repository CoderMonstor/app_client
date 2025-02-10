import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  //目标界面
  final int targetIndex;

  const MyBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.targetIndex,
  });

  void onTap(int index) {
    if (index == targetIndex) {
      // 点击了目标界面
      // 处理点击事件
    } else {
      // 点击了其他界面
      // 处理点击事件
    }
  }
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(currentIndex == 0 ? Icons.home : Icons.home_outlined),
          label: '主页',
        ),
        BottomNavigationBarItem(
          icon: Icon(currentIndex == 1 ? Icons.monetization_on : Icons.monetization_on_outlined),
          label: '交易',
        ),
        BottomNavigationBarItem(
          icon: Icon(currentIndex == 2 ? Icons.campaign : Icons.campaign_outlined),
          label: '搭子',
        ),
        BottomNavigationBarItem(
          icon: Icon(currentIndex == 3 ? Icons.account_circle : Icons.account_circle_outlined),
          label: '我的',
        ),
      ],
    );
  }
}