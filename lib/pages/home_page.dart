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
      appBar: MyAppbar.build(context,null),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '0',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GNavBar(
        selectedIndex: 0,
      ),
    );
  }
}
