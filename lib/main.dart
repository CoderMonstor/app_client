import 'dart:io';

import 'package:client/core/global.dart';
import 'package:client/pages/first_lunch.dart';
import 'package:client/pages/root_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 添加导入
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'core/model/theme_model.dart';
import 'core/model/user_model.dart';
import 'core/routes.dart';

void main() async {
  final UserModel user = UserModel();
  final ThemeModel theme = ThemeModel();
  // 确保在使用 SharedPreferences 之前初始化
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences prefs = await SharedPreferences.getInstance();

  // 隐藏状态栏
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // 设置状态栏样式,如果是Android平台，则设置状态栏颜色为透明。
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent,);

    // 设置状态栏样式为浅色，并应用到状态栏。
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  // 设置设备方向为竖屏
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  Global.init();
  print("============================here is the initial status ============================");
  print("----current User is ${Global.profile.user}-----current SearchList is ${Global.profile.searchList}");
  runApp(
      MultiProvider(
            providers: [
              ChangeNotifierProvider<UserModel>.value(value: user),
              ChangeNotifierProvider<ThemeModel>.value(value: theme,),
            ],
        child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      dismissOtherOnShow: true,
      child: Consumer<ThemeModel>(
        builder: (BuildContext context, ThemeModel value, Widget? child) {
          return MaterialApp(
            title: 'client',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            // initialRoute: '/login', // 设置初始路由
            home: const FirstLaunchPage(),
            routes: routes, // 使用路由映射
            onUnknownRoute: (settings) {
              // 当找不到匹配路由时，返回一个默认页面
              return MaterialPageRoute(builder: (context) => const RootRoute());
            },
            builder: (context, child) {
              ScreenUtil.init(
                context,
                designSize: const Size(412, 915), // 根据设计稿尺寸设置为 412x915 dp
              );
              return child!;
            },
          );
        },
    ),
    );
  }
}