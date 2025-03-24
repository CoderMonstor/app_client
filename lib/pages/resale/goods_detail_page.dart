import 'package:flutter/material.dart';

import '../../core/model/goods.dart';
import '../../core/net/my_api.dart';
import '../../core/net/net_request.dart';
import '../../util/toast.dart';
class GoodsDetailPage extends StatefulWidget {
  final int goodsId;
  const GoodsDetailPage({super.key, required this.goodsId});

  @override
  State<GoodsDetailPage> createState() => _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> {
  late Goods goods;
  @override
  void initState() {
    getGoods();
    super.initState();
  }
  Future<void> getGoods() async {
    var res=await NetRequester.request(Apis.getGoodsByGoodsId(widget.goodsId));
    if(res['code']=='1'){
      goods = Goods.fromJson(res['data'].toList()[0]);
    }else{
      Toast.popToast('获取商品失败');
      Navigator.pop(context);
    }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品详情'),
      ),
      body: Column(
        children: [
          Text(goods.goodsDesc!),
          const Center(
            child: Text('goods detail page'),
          ),
        ],
      ),
    );
  }
}
