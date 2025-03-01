import 'package:flutter/material.dart';
class SendResalePage extends StatefulWidget {
  const SendResalePage({super.key});

  @override
  State<SendResalePage> createState() => _SendResalePageState();
}

class _SendResalePageState extends State<SendResalePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Resale'),
      ),
      body: const Center(
        child: Text('Send Resale Page'),
      ),
    );
  }
}
