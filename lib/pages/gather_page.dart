import 'package:client/util/app_bar/my_app_bar.dart';
import 'package:flutter/material.dart';

import '../util/bottom_bar/g_nav_bar.dart';
import '../util/btn_nav.dart';
class GatherPage extends StatefulWidget {
  const GatherPage({super.key});

  @override
  State<GatherPage> createState() => _GatherPageState();
}

class _GatherPageState extends State<GatherPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.buildNormalAppbar(context, false, true, null),
      body:const Center(
        child: Text('GatherPage'),
      ),
      // bottomNavigationBar: GNavBar(
      //   selectedIndex: 2,
      // ),

    );
  }
}
