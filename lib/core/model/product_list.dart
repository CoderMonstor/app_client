class ProductList{
  int? productId;
  String? productImage;
  String? productName;
  String? description;
  double? price;


  ProductList({this.productId,this.productImage, this.productName,this.description, this.price});

  ProductList.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productImage = json['productImage'];
    productName = json['productName'];
    description = json['description'];
    price = json['price'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['productImage'] = productImage;
    data['productName'] = productName;
    data['description'] = description;
    data['price'] = price;
    return data;
  }
}