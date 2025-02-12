import 'package:flutter/material.dart';

import '../util/bottom_bar/g_nav_bar.dart';
class GatherPage extends StatefulWidget {
  const GatherPage({super.key});

  @override
  State<GatherPage> createState() => _GatherPageState();
}

class _GatherPageState extends State<GatherPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('GatherPage'),
      ),
      bottomNavigationBar: GNavBar(
        selectedIndex: 2,
      ),
    );
  }
}
