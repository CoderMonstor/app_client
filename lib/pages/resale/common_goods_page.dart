//有点没用

import 'package:client/core/list_repository/goods_repo.dart';
import 'package:client/core/model/goods.dart';
import 'package:client/widget/my_card/my_goods_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/global.dart';
import '../../widget/build_indicator.dart';

class CommonGoodsPage extends StatefulWidget{
  final int? type;
  final int? userId;
  final String? str;
  const CommonGoodsPage({super.key, this.type, this.str, this.userId});

  @override
  State<StatefulWidget> createState() {
    return _CommonGoodsPageState();
  }
}

class _CommonGoodsPageState extends State<CommonGoodsPage> {

  late GoodsRepository _goodsRepository;
  @override
  void initState() {
    super.initState();
    _goodsRepository = GoodsRepository(widget.userId!, widget.type!,widget.str);
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
              return MyGoodsCard(goods: item);
            },
            sourceList: _goodsRepository,
            indicatorBuilder: _buildIndicator,
            padding: EdgeInsets.only(
                top:ScreenUtil().setWidth(20),
                left: ScreenUtil().setWidth(20),
                right: ScreenUtil().setWidth(20)
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _goodsRepository);
  }
}