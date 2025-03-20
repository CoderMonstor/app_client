import 'package:client/core/model/product_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/net/net.dart';
import '../../pages/resale/product_detail_page.dart';
import '../my_list_tile.dart';

class ProductCard extends StatefulWidget {
  ProductList productList;
  ProductCard({super.key, required this.productList});

  @override
  State<ProductCard> createState() => _ProductCardState();
}
class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context)=>ProductDetailPage(productId: widget.productList.productId!)));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children: [
            Image(image: NetworkImage('${NetConfig.ip}/images/${widget.productList.productImage}')),
            const SizedBox(height: 4),
            MyListTile(
              left: 8,
              center: SizedBox(
                width: 190,
                  child: Text(
                    widget.productList.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
              )
            ),
            const SizedBox(height: 4),
            MyListTile(
              left: 4,
              right: 8,
              betweenLeadingAndCenter: 4,
              center: SizedBox(
                width: 110,
                child: Text(
                widget.productList.productName!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              trailing: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('￥',style: TextStyle(fontSize: 20, color: Colors.red,fontWeight: FontWeight.bold),),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${widget.productList.price}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                ],
              ),
            )
          ]
        )
      ),
    );
  }
}
