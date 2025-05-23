import 'package:client/pages/activity/activity_page.dart';
import 'package:client/pages/chat/message_page.dart';
import 'package:client/pages/post/send_post.dart';
import 'package:flutter/material.dart';

import '../pages/login_register/forget_page.dart';
import '../pages/login_register/register_page.dart';
import '../pages/first_lunch.dart';
import '../pages/login_register/login_page.dart';
import '../pages/post/post_page.dart';
import '../pages/resale/post_resale.dart';
import '../pages/resale/resale_page.dart';
import '../pages/user/about_me_page.dart';
import '../pages/root_route.dart';
import '../pages/search/search_page.dart';

final Map<String, WidgetBuilder> routes = {
  '/first_launch': (context) => const FirstLaunchPage(),
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/forget':(context)=>const ForgetPage(),
  '/root': (context) => const RootRoute(),
  '/home': (context) => const PostPage(),
  '/resale': (context) => const ResalePage(),
  '/gather': (context) => const GatherPage(),
  '/about_me': (context) => const AboutMePage(),
  '/search': (context) => const SearchPage(),
  '/message': (context) => const MessagePage(),
  '/send_post': (context) => const SendPostPage(),
  '/send_resale': (context) => const SendResalePage(),
  // '/send_gather': (context) => const SendGatherPage(),
};