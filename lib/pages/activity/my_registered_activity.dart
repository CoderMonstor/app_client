import 'package:client/pages/activity/common_activity.dart';
import 'package:flutter/material.dart';

import '../../core/global.dart';
class MyRegisteredActivity extends StatefulWidget {
  const MyRegisteredActivity({super.key});

  @override
  State<MyRegisteredActivity> createState() => _MyRegisteredActivityState();
}

class _MyRegisteredActivityState extends State<MyRegisteredActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('已报名的活动'),
        elevation: 0,
      ),
      body:  CommonActivity(type: 5,userId: Global.profile.user!.userId!,),
    );
  }
}
