import 'package:client/core/model/product.dart';
import 'package:client/util/app_bar/my_app_bar.dart';
import 'package:client/widget/my_card/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:loading_more_list/loading_more_list.dart';

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
  late ProductRepository _productRepository;
  final GlobalKey _fabKey = GlobalKey();

  @override
  initState() {
    super.initState();
    _productRepository= ProductRepository(1);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.buildNormalAppbar(context, false, true, null, null),
      body: RefreshIndicator(
        onRefresh: _productRepository.refresh,
        child: LoadingMoreList(
          ListConfig<Product>(
            itemBuilder: (BuildContext context, Product item, int index) {
              return ProductCard(
                product: item,
              );
            },
            sourceList: _productRepository,
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 2, // 列数
              repeatPattern: QuiltedGridRepeatPattern.inverted,
              pattern: const [
                QuiltedGridTile(2, 1),
                QuiltedGridTile(1, 1),
              ],
            ),
          ),
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

// Future<void> _refreshProducts() async {
//   try {
//     ProductRepository productRepo = ProductRepository(1);
//     await productRepo.refresh();
//     setState(() {
//       // products = productRepo.toList(); // 更新产品列表
//       // print(products);
//     });
//   } catch (e) {
//     // 处理错误
//     print('Error refreshing products: $e');
//   }
// }

// List<Product> products=[
//   Product(
//     productId: 1,
//     images: '0_1741706055897.jpg',
//     title: 'product_name_1,',
//     description: 'description_1',
//     price: 100.0,
//   ),
//   Product(
//     productId: 2,
//     images: '12_1741705822432.jpeg',
//     title: 'product_name_2',
//     description: 'description_2',
//     price: 200,
//   ),
//   Product(
//     productId: 3,
//     images: '12_1741705822605.jpg',
//     title: 'product_name_3',
//     description: 'description_3',
//     price: 300,
//   ),
//   // ProductList(
//   //   productId: 4,
//   //   productImage: '0_1741705892868.jpeg',
//   //   productName: 'product_name_4',
//   //   description: 'description_4:this is the description of product_name_4,this product is very good and very cheap',
//   //   price: 400,
//   // ),
//   // ProductList(
//   //   productId: 5,
//   //   productImage: '0_1741706055897.jpg',
//   //   productName: 'product_name_5',
//   //   description: 'description_5',
//   //   price: 50,
//   // ),
//   // ProductList(
//   //   productId: 6,
//   //   productImage: '0_1741706055897.jpg',
//   //   productName: 'product_name_6',
//   //   description: 'description_6',
//   //   price: 60000,
//   // ),
// ];

// body: RefreshIndicator(
//   onRefresh: () async {
//     await _refreshProducts();
//   },
//   child: MasonryGridView.count(
//     crossAxisCount: 2,
//     mainAxisSpacing: 4,
//     crossAxisSpacing: 4,
//     itemCount: products.length,
//     itemBuilder: (context, index) {
//       return ProductCard(
//         productList: products[index],
//       );
//     },
//   ),
// ),
// body: RefreshIndicator(
//   onRefresh: _productRepository.refresh,
//   child: LoadingMoreList(
//     ListConfig<Product>(
//       itemBuilder: (BuildContext context, Product item, int index) {
//         return ProductCard(
//           product: item,
//         );
//       },
//       sourceList: _productRepository,
//       padding: const EdgeInsets.only(
//         top: 20,
//       ),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( // 修复此处
//         crossAxisCount: 2,
//         // mainAxisSpacing: 4,
//         // crossAxisSpacing: 4,
//       ),
//     ),
//   ),
// ),