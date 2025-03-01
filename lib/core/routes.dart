import 'package:client/pages/gather_page.dart';
import 'package:client/pages/message_page.dart';
import 'package:client/pages/post/send_post.dart';
import 'package:flutter/material.dart';

import '../pages/gather/send_gather.dart';
import '../pages/login_register/forget_page.dart';
import '../pages/login_register/register_page.dart';
import '../pages/first_lunch.dart';
import '../pages/login_register/login_page.dart';
import '../pages/post/post_page.dart';
import '../pages/resale/send_resale.dart';
import '../pages/resale_page.dart';
import '../pages/user/about_me_page.dart';
import '../pages/root_route.dart';
import '../pages/search/search_page.dart';

final Map<String, WidgetBuilder> routes = {
  // '/': (context) => const FirstLaunchPage(),
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
  'send_Post': (context) => const SendPostPage(),
  'send_Resale': (context) => const SendResalePage(),
  'send_Gather': (context) => const SendGatherPage(),
};