class ReceiveMsg {
  String? fromUserId;
  String? type;
  String? content;

  ReceiveMsg({this.fromUserId, this.type, this.content});

  ReceiveMsg.fromJson(Map<String, dynamic> json) {
    fromUserId = json['fromUserId'];
    type = json['type'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fromUserId'] = fromUserId;
    data['type'] = type;
    data['content'] = content;
    return data;
  }
}