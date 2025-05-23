import 'package:client/pages/login_register/login_page.dart';
import 'package:client/pages/root_route.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchPage extends StatefulWidget {
  const FirstLaunchPage({super.key});

  @override
  State<FirstLaunchPage> createState() => _FirstLaunchPageState();
}

class _FirstLaunchPageState extends State<FirstLaunchPage> {
  int _start = 5; // 倒计时时间，单位为秒
  late Timer _timer;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
        goToHomePage();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: goToHomePage,
      child: Scaffold(
        backgroundColor: Colors.deepOrange, // 设置背景颜色
        body: Stack(
          children: [
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Hi CDU',
                    style: TextStyle(
                      fontFamily: 'chocolate', // 使用自定义字体
                      fontSize: 36, // 第一行字体较大
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '— 校园学生一站式服务app —',
                    style: TextStyle(
                      fontSize: 18, // 第二行字体较小
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Positioned(
              top: 30,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  _timer.cancel();
                  goToHomePage();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFFF9B7FF),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('跳过  |   $_start'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future goToHomePage() async {
    if(mounted){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //如果页面还未跳转过则跳转页面
      if (prefs.getString('profile') != null) {
        //跳转主页 且销毁当前页面
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const RootRoute()),
                (Route<dynamic> rout) => false);
      } else {
        //跳转登录页 且销毁当前页面
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> rout) => false);
      }
    }
  }
}
