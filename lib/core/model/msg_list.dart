class MsgModel {
  late String imageUrl;
  late String name;
  late String msg;
  late String time;
  MsgModel({
    required this.imageUrl,
    required this.name,
    required this.msg,
    required this.time,
  });

  static fromJson(item) {
    return MsgModel(
      imageUrl: item['imageUrl'],
      name: item['name'],
      msg: item['msg']??'',
      time: item['time'],
    );
  }
}

