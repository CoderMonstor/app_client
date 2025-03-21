import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/model/product.dart';
import '../../core/net/net.dart';
import '../../pages/resale/product_detail_page.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _navigateToDetail,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageSection(constraints.maxHeight * 0.65),
                _buildContentSection(constraints.maxHeight * 0.35),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageSection(double height) {
    return SizedBox(
      height: height,
      child: ClipRRect(
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
      ),
    );
  }

  Widget _buildContentSection(double maxHeight) {
    return Flexible(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceRow(),
            const SizedBox(height: 6),
            _buildDescriptionText(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            widget.product.title ?? '未命名商品',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
        _buildPriceTag(),
      ],
    );
  }

  Widget _buildDescriptionText() {
    return Flexible(
      child: Text(
        widget.product.description ?? '暂无商品描述',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildPriceTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: '¥',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: widget.product.price?.toStringAsFixed(2) ?? '0.00',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }

  String _getImageUrl() {
    final imagePath = widget.product.images?.split(',').first ?? '';
    return '${NetConfig.ip}/images/$imagePath';
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ProductDetailPage(
          productId: widget.product.productId!,
        ),
      ),
    );
  }
}