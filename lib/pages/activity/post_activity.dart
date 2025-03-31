import 'package:flutter/material.dart';
class PostActivityPage extends StatefulWidget {
  const PostActivityPage({super.key});

  @override
  State<PostActivityPage> createState() => _PostActivityPageState();
}

class _PostActivityPageState extends State<PostActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PostActivityPage'),
      ),
      body: Center(
        child: Text('PostActivityPage'),
      ),
    );
  }
}

