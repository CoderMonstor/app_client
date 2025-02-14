import 'package:client/util/app_bar/my_app_bar.dart';
import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:MyAppbar.simpleAppbar('消息'),
      body: const Center(
        child: Text('Message Page is showing'),
      ),
    );
  }
}
