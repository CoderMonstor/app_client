import 'package:flutter/material.dart';

import '../util/bottom_bar/g_nav_bar.dart';
class MassagePage extends StatefulWidget {
  const MassagePage({super.key});

  @override
  State<MassagePage> createState() => _MassagePageState();
}

class _MassagePageState extends State<MassagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
      ),
      body: const Center(
        child: Text('消息'),
      ),
    );
  }
}
