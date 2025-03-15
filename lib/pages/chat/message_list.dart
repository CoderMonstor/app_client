import 'package:client/widget/my_card/msg_list_card.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';


import '../../core/global.dart';
import '../../core/list_repository/msg_list_repo.dart';
import '../../core/model/msg_list.dart';
import '../../widget/build_indicator.dart';


class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}


class _MessageListState extends State<MessageList> {

  // late PostRepository _postRepository;
  late MsgListRepository _msgListRepository;
  @override
  void initState() {
    super.initState();
    // _postRepository =  PostRepository(Global.profile.user!.userId!, widget.type!,widget.str,widget.orderBy);
    _msgListRepository = MsgListRepository(Global.profile.user!.userId!);
  }

  @override
  void dispose() {
    // _postRepository.dispose();
    _msgListRepository.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        // onRefresh: _postRepository.refresh,
        onRefresh: _msgListRepository.refresh,
        child: LoadingMoreList(
          ListConfig<MsgModel>(
            itemBuilder: (BuildContext context, MsgModel item, int index){
              // return PostCard(post: item,list: _msgListRepository,index: index);
              return MsgListCard(msg:item,list: _msgListRepository,index: index,);
            },
            // sourceList: _postRepository,
            sourceList: _msgListRepository,
            indicatorBuilder: _buildIndicator,
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _msgListRepository);
  }

}