import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/list_repository/reply_repo.dart';
import '../../core/model/comment.dart';
import '../../core/model/reply.dart';
import '../../util/app_bar/my_app_bar.dart';
import '../../widget/build_indicator.dart';
import '../../widget/item_builder.dart';

class ReplyPage extends StatefulWidget{

  final Comment? comment;

  const ReplyPage({super.key, this.comment});
  @override
  State<StatefulWidget> createState() {
    return _ReplyPageState();
  }
}

class _ReplyPageState extends State<ReplyPage> {

  late ReplyRepository _replyRepository;
  @override
  void initState() {
    super.initState();
    _replyRepository =  ReplyRepository(widget.comment!.commentId!);
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
        ListConfig<Reply>(
          itemBuilder: (BuildContext context, Reply reply, int index){
            return ItemBuilder.buildReplyRow(context, reply, _replyRepository, index);
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