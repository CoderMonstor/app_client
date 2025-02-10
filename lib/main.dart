import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 添加导入
import 'package:client/config/routes.dart'; // 添加导入

void main() async {
  // 确保在使用 SharedPreferences 之前初始化
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences prefs = await SharedPreferences.getInstance();

  // 隐藏状态栏
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'client',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/home', // 设置初始路由
      routes: routes, // 使用路由映射
    );
  }
}