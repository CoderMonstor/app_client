import 'package:client/util/app_bar/my_app_bar.dart';
import 'package:flutter/material.dart';


class ResalePage extends StatefulWidget {
  const ResalePage({super.key});

  @override
  State<ResalePage> createState() => _ResalePageState();
}

class _ResalePageState extends State<ResalePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.buildNormalAppbar(context, false, true,null,null),
      body:const Center(
        child: Text('Resale Page'),
      ),

    );
  }
}
