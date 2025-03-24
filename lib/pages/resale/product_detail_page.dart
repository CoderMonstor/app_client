import 'package:client/core/model/product.dart';
import 'package:client/core/net/net_request.dart';
import 'package:client/util/toast.dart';
import 'package:flutter/material.dart';

import '../../core/net/my_api.dart';
class ProductDetailPage extends StatefulWidget {
  final int productId;
  const ProductDetailPage({super.key, required this.productId,});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? product;
  @override
  void initState() {
    getProduct();
    super.initState();
  }
  Future<void> getProduct() async {
    var res=await NetRequester.request(Apis.getProductByProductId(widget.productId));
    if(res['code']=='1'){
      print(res['data']);
      product = Product.fromJson(res['data'].toList()[0]);
      print('====================================================');
      print(product);
    }else{
      Toast.popToast('获取商品失败');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${product?.title}'),
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
