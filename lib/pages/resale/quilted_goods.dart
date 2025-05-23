import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/global.dart';
import '../../core/list_repository/goods_repo.dart';
import '../../core/model/goods.dart';
import '../../widget/build_indicator.dart';
import '../../widget/my_card/goods_card.dart';

class QuiltedGoods extends StatefulWidget {
  final int? type;
  final String? str;
  const QuiltedGoods({super.key, this.str, this.type});

  @override
  State<QuiltedGoods> createState() => _QuiltedGoodsState();
}

class _QuiltedGoodsState extends State<QuiltedGoods> {
  late GoodsRepository _goodsRepository;

  @override
  void initState() {
    super.initState();
    _goodsRepository = GoodsRepository(Global.profile.user!.userId!, widget.type!,widget.str);
  }

  @override
  void dispose() {
    _goodsRepository.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _goodsRepository.refresh,
        child: LoadingMoreList(
          ListConfig<Goods>(
            itemBuilder: (BuildContext context, Goods item, int index){
              return GoodsCard(goods: item);
            },
            sourceList: _goodsRepository,
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 2, // 列数
              repeatPattern: QuiltedGridRepeatPattern.inverted,
              pattern: const [
                QuiltedGridTile(2, 1),
                QuiltedGridTile(1, 1),
              ],
            ),
            indicatorBuilder: _buildIndicator,
          ),
        ),
      ),
    );
  }
  Widget _buildIndicator(BuildContext context, IndicatorStatus status){
    return buildIndicator(context, status,_goodsRepository);
  }
}


