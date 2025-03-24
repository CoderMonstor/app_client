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
  Goods ? goods;
  Future<Goods?> fetchGoods() async {
    try {
      var res = await NetRequester.request(Apis.getGoodsByGoodsId(widget.goodsId));
      if (res['code'] == '1') {
        print("-------------------------res['code']=='1'----------------------");
        // 直接解析 Map 数据
        if (res['data'] is Map<String, dynamic>) {
          print("----------------------res['data'] is Map------------------------");
          goods = Goods.fromJson(res['data']);
          print(goods?.goodsName);
          return Goods.fromJson(res['data']);
        } else {
          print("----------------------res['data'] is not Map------------------------");
          Toast.popToast('商品数据格式错误');
          return null;
        }
      } else {
        print("-------------------------res['code']!=1----------------------");
        Toast.popToast('获取商品失败');
        return null;
      }
    } catch (e) {
      Toast.popToast('请求异常: $e');
      print(e);
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品详情'),
      ),
      body: FutureBuilder<Goods?>(
        future: fetchGoods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            final goods = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goods.goodsName ?? '无商品名', style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 16),
                  Text('描述: ${goods.goodsDesc ?? "暂无"}'),
                  const SizedBox(height: 8),
                  Text('价格: ${goods.goodsPrice ?? "暂无"}'),
                  const SizedBox(height: 8),
                  Text('状态: ${goods.status ?? "未知"}'),
                  const SizedBox(height: 8),
                  Text('创建时间: ${goods.createTime ?? "未知"}'),
                  // 根据需要添加更多字段
                ],
              ),
            );
          } else {
            return const Center(child: Text('暂无商品信息'));
          }
        },
      ),
    );
  }
}
