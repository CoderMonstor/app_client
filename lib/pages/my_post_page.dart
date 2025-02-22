import 'package:flutter/material.dart';
class MyPostPage extends StatefulWidget {
  const MyPostPage({super.key});

  @override
  State<MyPostPage> createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Center(
        child: Text("My Post Page"),
      ),
    );
  }
}
