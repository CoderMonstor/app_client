import 'package:client/pages/activity/common_activity.dart';
import 'package:flutter/material.dart';

import '../../core/global.dart';
class MyCollectedActivity extends StatefulWidget {
  const MyCollectedActivity({super.key});

  @override
  State<MyCollectedActivity> createState() => _MyCollectedActivityState();
}

class _MyCollectedActivityState extends State<MyCollectedActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('活动收藏'),
      ),
      body: CommonActivity(type: 3,userId: Global.profile.user!.userId,),
    );
  }
}
