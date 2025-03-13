import 'package:client/core/model/msg_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../net/my_api.dart';
import '../net/net_request.dart';

class MsgListRepository extends LoadingMoreBase<MsgModel> {
  final int userId;
  int _pageIndex = 1;
  bool _hasMore = true;
  bool _forceRefresh = false;


  MsgListRepository(this.userId);

  @override
  bool get hasMore => _hasMore || _forceRefresh;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _pageIndex = 1;
    _forceRefresh = !notifyStateChanged;
    var result = await super.refresh(notifyStateChanged);
    _forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;

    try {
      var result = await NetRequester.request(Apis.getMsgUserList(userId, _pageIndex));
      if(result.containsKey('data')){
        if (_pageIndex == 1) {
          clear();
        }
        List source = result['data'] ?? [];
        for (var item in source) {
          var msgList = MsgModel.fromJson(item);
          if (!contains(msgList) && hasMore) add(msgList);
        }
        _hasMore = _pageIndex < result['totalPage'];
        _pageIndex++;
        isSuccess = true;
      }
    } catch (exception, stack) {
      isSuccess = false;
      debugPrint(exception.toString());
      debugPrint(stack.toString());
    }
    return isSuccess;
  }
}
