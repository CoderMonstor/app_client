import 'package:flutter/material.dart';
class SendGatherPage extends StatefulWidget {
  const SendGatherPage({super.key});

  @override
  State<SendGatherPage> createState() => _SendGatherPageState();
}

class _SendGatherPageState extends State<SendGatherPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SendGatherPage'),
      ),
      body: Center(
        child: Text('SendGatherPage'),
      ),
    );
  }
}
