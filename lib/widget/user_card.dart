import 'package:client/core/list_repository/user_repo.dart';
import 'package:client/core/model/user.dart';
import 'package:client/util/my_icon/my_app_icons.dart';
import 'package:client/widget/my_list_tile.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/net/net.dart';
import '../pages/user/chat_page.dart';
import '../pages/user/profile_page.dart';
class UserCard extends StatefulWidget {
  final User? user;
  final UserRepository? list;
  final int? index;
  const UserCard({super.key, this.user, this.list, this.index});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: MyListTile(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                      ProfilePage(userId: widget.user?.userId)));
        },
        left: 30,
        right: 20,
        top: 10,
        bottom: 10,
        leading: SizedBox(
          height: ScreenUtil().setWidth(50),
          child: widget.user?.avatarUrl == '' || widget.user?.avatarUrl == null
              ? Image.asset("assets/images/app_logo.png")
              : ClipOval(
                child: ExtendedImage.network(
                    '${NetConfig.ip}/images/${widget.user!.avatarUrl}',
                    cache: true),
              ),
        ),
        center: Row(
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(10),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user!.username!),
                Text(widget.user!.bio!),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>  ChatPage(user: widget.user),
              ),
            );
          },
          icon: const Icon(MyAppIcon.envelope_regular),
        ),
      ),
    );
  }
}
