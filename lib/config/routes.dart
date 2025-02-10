import 'package:flutter/material.dart';

import '../pages/register_page.dart';
import '../pages/first_lunch.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/resale_page.dart';
import '../pages/about_me_page.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const FirstLaunchPage(),
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/home': (context) => const MyHomePage(),
  '/resale': (context) => const ResalePage(),
  '/gather': (context) => const LoginPage(),
  '/aboutMe': (context) => const AboutMePage(),
};