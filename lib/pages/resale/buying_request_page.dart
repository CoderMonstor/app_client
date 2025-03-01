import 'package:flutter/material.dart';
class BuyingRequestPage extends StatefulWidget {
  const BuyingRequestPage({super.key});

  @override
  State<BuyingRequestPage> createState() => _BuyingRequestPageState();
}

class _BuyingRequestPageState extends State<BuyingRequestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BuyingRequestPage'),
      ),
      body: const Center(
        child: Text('BuyingRequestPage'),
      ),
    );
  }
}
