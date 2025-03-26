import 'package:client/widget/item_builder_goods.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/list_repository/goods_reply_repo.dart';
import '../../core/model/goods_comment.dart';
import '../../core/model/goods_reply.dart';
import '../../util/app_bar/my_app_bar.dart';
import '../../widget/build_indicator.dart';

class GoodsReplyPage extends StatefulWidget{

  final GoodsComment? comment;

  const GoodsReplyPage({super.key, this.comment});
  @override
  State<StatefulWidget> createState() {
    return _GoodsReplyPageState();
  }
}

class _GoodsReplyPageState extends State<GoodsReplyPage> {

  late GoodsReplyRepository _replyRepository;
  @override
  void initState() {
    super.initState();
    _replyRepository =  GoodsReplyRepository(widget.comment!.commentId!);
  }

  @override
  void dispose() {
    _replyRepository.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.simpleAppbar('共${widget.comment?.replyNum}条回复'),
      body: LoadingMoreList(
        ListConfig<GoodsReply>(
          itemBuilder: (BuildContext context, GoodsReply reply, int index){
            return ItemBuilderGoods.buildGoodsReplyRow(context, reply, _replyRepository, index);
          },
          sourceList: _replyRepository,
          indicatorBuilder: _buildIndicator,
        ),
      ),
    );
  }
  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _replyRepository);
  }
}