import 'package:flutter/material.dart';

import '../util/bottom_bar/g_nav_bar.dart';
import '../util/btn_nav.dart';
class AboutMePage extends StatefulWidget {
  const AboutMePage({super.key});

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('About Me Page'),
      ),
      // bottomNavigationBar: GNavBar(
      //   selectedIndex: 3,
      // ),

    );
  }
}

