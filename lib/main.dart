import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 添加导入
import 'package:client/config/routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 添加导入

void main() async {
  // 确保在使用 SharedPreferences 之前初始化
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences prefs = await SharedPreferences.getInstance();

  // 隐藏状态栏
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // 设置状态栏样式,如果是Android平台，则设置状态栏颜色为透明。
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent,);

    // 设置状态栏样式为浅色，并应用到状态栏。
    // SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  // 设置设备方向为竖屏
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);


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
      initialRoute: '/root', // 设置初始路由
      routes: routes, // 使用路由映射
      builder: (context, child) {
        ScreenUtil.init(
          context,
          designSize: const Size(412, 915), // 根据设计稿尺寸设置为 412x915 dp
        );
        return child!;
      },
    );
  }
}