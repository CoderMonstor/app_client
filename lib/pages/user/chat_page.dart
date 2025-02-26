import 'package:client/core/model/user.dart';
import 'package:flutter/material.dart';
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required User user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Page"),
      ),
      body: const Center(
        child: Text("Chat Page"),
      ),
    );
  }
}
