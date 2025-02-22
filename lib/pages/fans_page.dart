import 'package:flutter/material.dart';
class FansPage extends StatefulWidget {
  const FansPage({super.key});

  @override
  State<FansPage> createState() => _FansPageState();
}

class _FansPageState extends State<FansPage> {
  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Center(
        child: Text("Fans Page"),
      ),
    );
  }
}
