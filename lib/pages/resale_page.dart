import 'package:flutter/material.dart';

import '../util/bottom_bar/g_nav_bar.dart';
class ResalePage extends StatefulWidget {
  const ResalePage({super.key});

  @override
  State<ResalePage> createState() => _ResalePageState();
}

class _ResalePageState extends State<ResalePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Resale Page'),
      ),
      bottomNavigationBar: GNavBar(
        selectedIndex: 1,
      ),
    );
  }
}
