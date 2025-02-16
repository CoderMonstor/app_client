import 'package:flutter/foundation.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../model/reply.dart';
import '../net/my_api.dart';
import '../net/net_request.dart';

class ReplyRepository extends LoadingMoreBase<Reply> {
  int pageIndex = 1;
  bool _hasMore = true;
  bool forceRefresh = false;
  int commentId;

  ReplyRepository(this.commentId);

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _hasMore = true;
    pageIndex = 1;
    forceRefresh = !clearBeforeRequest;
    var result = await super.refresh(clearBeforeRequest);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    bool isSuccess = false;

    try {
      var result = await NetRequester.request(Apis.getReplyByCommentId(commentId, pageIndex));
      if(result.containsKey('data')){
        if (pageIndex == 1) {
          clear();
        }
        List source = result['data'] ?? [];
        for (var item in source) {
          var reply = Reply.fromJson(item);
          if (!contains(reply) && hasMore) add(reply);
        }
        _hasMore = pageIndex < result['totalPage'];
        pageIndex++;
        isSuccess = true;
      }
    } catch (exception, stack) {
      isSuccess = false;
      if (kDebugMode) {
        print(exception);
      }
      if (kDebugMode) {
        print(stack.toString());
      }
    }
    return isSuccess;
  }
}