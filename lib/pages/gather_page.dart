import 'package:client/util/app_bar/my_app_bar.dart';
import 'package:flutter/material.dart';

import '../core/net/net.dart';
import '../core/net/net_request.dart';

class GatherPage extends StatefulWidget {
  const GatherPage({super.key});

  @override
  State<GatherPage> createState() => _GatherPageState();
}

class _GatherPageState extends State<GatherPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.buildNormalAppbar(context, false, true, null, null),
      body: const Center(
        child: Text('GatherPage'),
      ),
    );
  }
}
