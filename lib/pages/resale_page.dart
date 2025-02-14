import 'package:flutter/material.dart';

import '../util/btn_nav.dart';
class ResalePage extends StatefulWidget {
  const ResalePage({super.key});

  @override
  State<ResalePage> createState() => _ResalePageState();
}

class _ResalePageState extends State<ResalePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:const Center(
        child: Text('Resale Page'),
      ),

    );
  }
}
