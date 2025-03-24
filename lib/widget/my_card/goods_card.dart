import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/model/goods.dart';
import '../../core/net/net.dart';
import '../../pages/resale/goods_detail_page.dart';

class GoodsCard extends StatefulWidget {
  final Goods goods;
  const GoodsCard({super.key, required this.goods});

  @override
  State<GoodsCard> createState() => _GoodsCardState();
}

class _GoodsCardState extends State<GoodsCard> {

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _navigateToDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildImageSection(),
            ),
            _buildContentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Image.network(
        _getImageUrl(),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stack) => _buildErrorPlaceholder(),
      ),
    );
  }

  Widget _buildContentSection() {
    return SizedBox(
      height: 90.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceRow(),
            SizedBox(height: 6.h),
            _buildDescriptionText(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
              widget.goods.goodsName ?? '未命名商品',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),),
        _buildPriceTag(),

      ],
    );
  }

  Widget _buildDescriptionText() {
    return Flexible(
      child: Text(
        widget.goods.goodsDesc ?? '暂无描述',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildPriceTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '¥',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: widget.goods.goodsPrice?.toStringAsFixed(2) ?? '0.00',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 其他辅助方法保持不变...
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.h,
          child: CircularProgressIndicator(strokeWidth: 2.w),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(child: Icon(Icons.broken_image, size: 24.w, color: Colors.grey)),
    );
  }

  String _getImageUrl() {
    final imagePath = widget.goods.image?.split('￥').first ?? '';
    return '${NetConfig.ip}/images/$imagePath';
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => GoodsDetailPage(
          goodsId: widget.goods.goodsId!,
        ),
      ),
    );
  }
}