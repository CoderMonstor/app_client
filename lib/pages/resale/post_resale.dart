import 'package:flutter/material.dart';
class SendResalePage extends StatefulWidget {
  const SendResalePage({super.key});

  @override
  State<SendResalePage> createState() => _SendResalePageState();
}

class _SendResalePageState extends State<SendResalePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布交换'),
      ),
    );
  }
}
