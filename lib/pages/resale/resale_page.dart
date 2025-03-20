
import 'package:client/util/app_bar/my_app_bar.dart';
import 'package:client/widget/my_card/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../core/list_repository/product_repo.dart';
import '../../core/model/product_list.dart';
import '../../widget/send_button.dart';
class ResalePage extends StatefulWidget {
  const ResalePage({super.key});

  @override
  State<ResalePage> createState() => _ResalePageState();
}

class _ResalePageState extends State<ResalePage> {
  bool _isFabExpanded = false;
  final GlobalKey _fabKey = GlobalKey();

  List<ProductList> products=[
    ProductList(
      productId: 1,
      productImage: '0_1741706055897.jpg',
      productName: 'product_name_1,',
      description: 'description_1',
      price: 100.0,
    ),
    ProductList(
      productId: 2,
      productImage: '12_1741705822432.jpeg',
      productName: 'product_name_2',
      description: 'description_2',
      price: 200,
    ),
    ProductList(
      productId: 3,
      productImage: '12_1741705822605.jpg',
      productName: 'product_name_3',
      description: 'description_3',
      price: 300,
    ),
    ProductList(
      productId: 4,
      productImage: '0_1741705892868.jpeg',
      productName: 'product_name_4',
      description: 'description_4:this is the description of product_name_4,this product is very good and very cheap',
      price: 400,
    ),
    ProductList(
      productId: 5,
      productImage: '0_1741706055897.jpg',
      productName: 'product_name_5',
      description: 'description_5',
      price: 50,
    ),
    ProductList(
      productId: 6,
      productImage: '0_1741706055897.jpg',
      productName: 'product_name_6',
      description: 'description_6',
      price: 60000,
    ),
  ];


  Future<void> _refreshProducts() async {
    try {
      ProductRepository productRepo = ProductRepository(0, 1); // 假设我们想要获取所有产品，type 为 1
      await productRepo.refresh();
      setState(() {
        products = productRepo.toList(); // 更新产品列表
        print(products);
      });
    } catch (e) {
      // 处理错误
      print('Error refreshing products: $e');
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.buildNormalAppbar(context, false, true, null, null),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshProducts();
        },
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(
              productList: products[index],
            );
          },
        ),
      ),
      floatingActionButton: SendButton(
        key: _fabKey, // 绑定GlobalKey
        isExpanded: _isFabExpanded,
        onToggle: (value) => setState(() => _isFabExpanded = value),
      ),
    );
  }
}

