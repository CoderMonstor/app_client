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
  String url = '${NetConfig.ip}/user/findUserById?askId=12&userId=11';
  late Future result;

  @override
  void initState() {
    super.initState();
    result = NetRequester.request(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.buildNormalAppbar(context, false, true, null, null),
      body: Center(
        child: FutureBuilder(
          future: result,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Text('${snapshot.data}');
            } else {
              return const Text('No data');
            }
          },
        ),
      ),
    );
  }
}
