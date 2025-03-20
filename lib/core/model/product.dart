class Product {
  int? productId;
  int? userId;
  String? username;
  String? date;
  String? avatarUrl;
  String? title;
  String? description;
  String? images;
  double? price;
  String? location;
  int? category;
  int? status;
  String? createTime;

  Product({
    this.productId,
    this.userId,
    this.username,
    this.date,
    this.avatarUrl,
    this.title,
    this.description,
    this.images,
    this.price,
    this.location,
    this.category,
    this.status,
    this.createTime,
  });

  Product.fromJson(Map<String, dynamic> json)
      : productId = json['productId'],
        userId = json['userId'],
        username = json['username'],
        date = json['date'],
        avatarUrl = json['avatarUrl'],
        title = json['title'],
        description = json['description'],
        images = json['images'],
        price = json['price'],
        location = json['location'],
        category = json['category'],
        status = json['status'],
        createTime =json['createTime'];

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'userId': userId,
      'username': username,
      'date': date,
      'avatarUrl': avatarUrl,
      'title': title,
      'description': description,
      'images': images,
      'price': price,
      'location': location,
      'category': category,
      'status': status,
      'createTime': createTime,
    };
  }

}