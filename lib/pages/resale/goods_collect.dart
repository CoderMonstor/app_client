import 'package:client/widget/my_card/goods_card.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/global.dart';
import '../../core/list_repository/goods_repo.dart';
import '../../core/model/goods.dart';
import '../../widget/build_indicator.dart';
import '../../widget/my_card/my_goods_card.dart';
class GoodsCollectPage extends StatefulWidget {
  const GoodsCollectPage({super.key});

  @override
  State<GoodsCollectPage> createState() => _GoodsCollectPageState();
}

class _GoodsCollectPageState extends State<GoodsCollectPage> {
  late GoodsRepository _goodsRepository;

  @override
  void initState() {
    super.initState();
    _goodsRepository = GoodsRepository(Global.profile.user!.userId!, 4);
    _goodsRepository.refresh();
  }

  @override
  void dispose() {
    _goodsRepository.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品收藏'),
      ),
      body: LoadingMoreList(
        ListConfig<Goods>(
          itemBuilder: (context, goods, index) => MyGoodsCard(goods: goods),
          sourceList: _goodsRepository,
          indicatorBuilder: _buildIndicator,
          padding: const EdgeInsets.symmetric(horizontal: 16)
        ),
      ),
    );
  }
  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _goodsRepository);
  }
}
