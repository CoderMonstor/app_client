import 'package:client/util/btn_nav.dart';
import 'package:flutter/material.dart';
import '../util/app_bar/my_app_bar.dart';
import '../util/bottom_bar/g_nav_bar.dart'; // 使用封装后的 GNavBar 组件

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.buildNormalAppbar(context,false,true,null),
      body: Container(
        color: Colors.blue,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text('跳转到首页'),
              ),
            ]
          )
        ),
      ),
    );
  }
}
