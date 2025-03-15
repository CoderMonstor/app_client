import 'package:flutter/material.dart';
class ProductDetailPage extends StatefulWidget {
  final int productId;
  const ProductDetailPage({super.key, required this.productId,});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品详情'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('商品详情页面'),
            SizedBox(
              child: Text('商品ID：${widget.productId}'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
