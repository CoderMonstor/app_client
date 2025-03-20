import 'package:flutter/foundation.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../util/toast.dart';
import '../model/product_list.dart';
import '../net/my_api.dart';
import '../net/net_request.dart';

class ProductRepository extends LoadingMoreBase<ProductList> {
  int pageIndex = 1;
  bool _hasMore = true;
  bool forceRefresh = false;

  int productId;
  int type;
  String? key;
  String? orderBy;
  int? category;
  ProductRepository(this.productId, this.type, [this.key, this.orderBy, this.category]);


  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _hasMore = true;
    pageIndex = 1;
    forceRefresh = !clearBeforeRequest;
    var result = await super.refresh(clearBeforeRequest);
    if(result){
      Toast.popToast('刷新成功');
    }
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    String url = '';
    switch (type) {
      case 1:
        url = Apis.getAllProduct(pageIndex);
        break;
      case 2:
        url = Apis.getProductByProductId(productId);
        break;
      case 3:
        url = Apis.getProductByCategory(category!, pageIndex);
        break;
      // case 4:
        // url = Apis.getProductByKey(key!, orderBy!, pageIndex);
        // break;
      default:
        throw Exception("Unsupported post type: $type");
    }
    bool isSuccess = false;
    try {
      Map result = await NetRequester.request(url);
      if (result.containsKey('data')) {
        if (pageIndex == 1) {
          clear();
        }
        List source = result['data'];
        if (source.isNotEmpty) {
          for (var item in source) {
            var product = ProductList.fromJson(item);
            if (!contains(product) && hasMore) add(product);
          }
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
