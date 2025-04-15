import 'package:flutter/material.dart';

import '../../core/global.dart';
import 'common_post.dart';
class CollectedPost extends StatefulWidget {
  const CollectedPost({super.key});

  @override
  State<CollectedPost> createState() => _CollectedPostState();
}

class _CollectedPostState extends State<CollectedPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏的帖子'),
        elevation: 0,
      ),
      body: CommonPostPage(type: 3,userId: Global.profile.user!.userId!,),
    );
  }
}
