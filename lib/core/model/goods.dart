class Goods {
  int? goodsId;
  int? userId;
  int? orderId;
  int? categoryId;
  String? type;
  String? goodsName;
  String? goodsDesc;
  double? goodsPrice;
  String? username;
  double? price;
  String? image;
  String? status;
  String? sellStatus;
  DateTime? createTime;
  int? isCollected;
  int? collectId;
  DateTime? sellTime;

  Goods({
      this.goodsId,
      this.userId,
      this.orderId,
      this.categoryId,
      this.type,
      this.goodsName,
      this.goodsDesc,
      this.goodsPrice,
      this.username,
      this.price,
      this.image,
      this.status,
      this.sellStatus,
      this.createTime,
      this.isCollected,
      this.collectId,
      this.sellTime,
      });

  Goods.fromJson(Map<String, dynamic> json):
    goodsId = json['goodsId'],
    userId = json['userId'],
    orderId = json['orderId'],
    categoryId = json['categoryId'],
    type = json['type'],
    goodsName = json['goodsName'],
    goodsDesc = json['goodsDesc'],
    goodsPrice = json['goodsPrice'],
    username = json['username'],
    price = json['price'],
    image = json['image'],
    status = json['status'],
    sellStatus = json['sellStatus'],
    createTime = json['createTime'] != null ? DateTime.parse(json['createTime']) : null,
    isCollected = json['isCollected'],
    collectId = json['collectId'],
    sellTime = json['sellTime'] != null ? DateTime.parse(json['sellTime']) : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['goodsId'] = goodsId;
    data['userId'] = userId;
    data['orderId'] = orderId;
    data['categoryId'] = categoryId;
    data['type'] = type;
    data['goodsName'] = goodsName;
    data['goodsDesc'] = goodsDesc;
    data['goodsPrice'] = goodsPrice;
    data['username'] = username;
    data['price'] = price;
    data['image'] = image;
    data['status'] = status;
    data['sellStatus'] = sellStatus;
    data['createTime'] = createTime?.toIso8601String();
    data['isCollected'] = isCollected;
    data['collectId'] = collectId;
    data['sellTime'] = sellTime?.toIso8601String();
    return data;
  }

}
// 商品类型定义
class GoodsType {
  static const String idle = "0"; // 闲置
  static const String wanted = "1"; // 求购
}