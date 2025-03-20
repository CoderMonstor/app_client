import 'package:client/core/model/product.dart';
import 'package:client/core/model/user.dart';

class ProductDetail{
  Product? product;
  User? user;

  ProductDetail({this.product, this.user});
  ProductDetail.fromJson(Map<String, dynamic> json) {
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }

}