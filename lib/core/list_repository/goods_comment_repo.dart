import 'package:flutter/foundation.dart';
import 'package:loading_more_list/loading_more_list.dart';
import '../model/comment.dart';
import '../model/goods_comment.dart';
import '../net/my_api.dart';
import '../net/net_request.dart';

class GoodsCommentRepository extends LoadingMoreBase<GoodsComment> {
  int pageIndex = 1;
  bool _hasMore = true;
  bool forceRefresh = false;
  int goodsId;
  GoodsCommentRepository(this.goodsId);

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
      var result = await NetRequester.request(Apis.getGoodsCommentByGoodsId(goodsId, pageIndex));
      if(result.containsKey('data')){
        if (pageIndex == 1) {
          clear();
        }
        List source = result['data'] ?? [];
        for (var item in source) {
          var comment = GoodsComment.fromJson(item);
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
