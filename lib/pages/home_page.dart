import 'package:flutter/material.dart';
import '../util/bottom_bar/g_button.dart';
import '../util/bottom_bar/g_nav.dart'; // 确保导入正确的文件路径

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // 添加 selectedIndex 状态

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('校园广场'),
      ),
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
      bottomNavigationBar: GNav( // 使用 GNav 构造函数
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
        tabs: const [
          GButton(
            icon: Icons.home,
            text: '首页',
          ),
          GButton(
            icon: Icons.search,
            text: '搜索',
          ),
          GButton(
            icon: Icons.notifications,
            text: '通知',
          ),
          GButton(
            icon: Icons.person,
            text: '个人',
          ),
        ],
      ),
    );
  }
}