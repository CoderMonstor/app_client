import 'package:client/util/build_date.dart';
import 'package:client/widget/my_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/global.dart';
import '../../core/list_repository/goods_repo.dart';
import '../../core/model/goods.dart';
import '../../core/net/net.dart';
import '../../widget/build_indicator.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  late GoodsRepository _goodsRepository;

  @override
  void initState() {
    super.initState();
    _goodsRepository = GoodsRepository(Global.profile.user!.userId!, 8);
    _goodsRepository.refresh();
  }

  @override
  void dispose() {
    _goodsRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingMoreList(
      ListConfig<Goods>(
        itemBuilder: (context, item, index) {
          return _buildOrderItem(item);
        },
        sourceList: _goodsRepository,
        indicatorBuilder: _buildIndicator,
      ),
    );
  }

  /// 每个订单项的 Card 样式
  Widget _buildOrderItem(Goods item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图片区域
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    '${NetConfig.ip}${item.image?.split('￥').first ?? ''}',
                    width: 90.w,
                    height: 90.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12.w),
                // 文字信息区域
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.goodsName ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.goodsDesc ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      // 价格信息
                      Text(
                        '成交价：¥ ${item.goodsPrice.toString()}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // 分割线
            Divider(height: 1, color: Colors.grey[300]),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16.sp,
                  color: Colors.grey,
                ),
                SizedBox(width: 4.w),
                Text(
                  buildFormatTime(item.sellTime!),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 加载更多指示器（保持原有逻辑）
  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _goodsRepository);
  }
}
