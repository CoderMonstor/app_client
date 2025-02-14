import 'package:client/util/app_bar/my_app_bar.dart';
import 'package:flutter/material.dart';

class AboutMePage extends StatefulWidget {
  const AboutMePage({super.key});

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.buildNormalAppbar(context, false, true,null),
      body: const Center(
        child: Text('About Me Page'),
      ),

    );
  }
}

