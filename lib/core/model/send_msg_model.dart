class UserSendUserMsgModel {
  late String imageUrl;
  late String msg;
  late String? role;
  UserSendUserMsgModel(
      {required this.imageUrl,
      required this.msg,
      this.role = "sender"}); // sender receiver
}
