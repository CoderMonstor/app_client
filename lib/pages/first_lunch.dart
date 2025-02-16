import 'package:client/pages/thread/post_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
        Navigator.pushNamed(context, '/home');
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
    return Scaffold(
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
            top: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                _timer.cancel();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ThreadPage()),
                );
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
    );
  }
}
