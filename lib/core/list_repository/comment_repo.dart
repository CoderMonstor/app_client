/*
这个类主要用于获取评论列表
@[param]:
postId: 帖子id
_hasMore: 是否还有更多数据
pageIndex: 当前页码
forceRefresh: 是否强制刷新
 */
import 'package:flutter/foundation.dart';
import 'package:loading_more_list/loading_more_list.dart';
import '../model/comment.dart';
import '../net/my_api.dart';
import '../net/net_request.dart';

class CommentRepository extends LoadingMoreBase<Comment> {
  int pageIndex = 1;
  bool _hasMore = true;
  bool forceRefresh = false;
  int postId;
  CommentRepository(this.postId);

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    pageIndex = 1;
    forceRefresh = !notifyStateChanged;
    var result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    bool isSuccess = false;

    try {
      var result = await NetRequester.request(Apis.getCommentByPostId(postId, pageIndex));
      if(result.containsKey('data')){
        if (pageIndex == 1) {
          clear();
        }
        List source = result['data'] ?? [];
        for (var item in source) {
          var comment = Comment.fromJson(item);
          if (!contains(comment) && hasMore) add(comment);
        }
        _hasMore = pageIndex < result['totalPage'];
        pageIndex++;
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
