import 'package:client/core/list_repository/msg_list_repo.dart';
import 'package:client/core/model/msg_list.dart';
import 'package:client/core/net/net.dart';
import 'package:client/core/net/net_request.dart';
import 'package:client/pages/chat/chat_page.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/global.dart';
import '../../core/model/user.dart';
import '../../core/net/my_api.dart';
import '../../util/build_date.dart';
import '../../util/toast.dart';
import '../my_list_tile.dart';

class MsgListCard extends StatefulWidget {
  final MsgModel? msg;
  final MsgListRepository? list;
  final int? index;

  const MsgListCard({super.key, this.msg, this.list, this.index});

  @override
  State<MsgListCard> createState() => _MsgListCardState();
}

class _MsgListCardState extends State<MsgListCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: MyListTile(
        onTap: () async {
          var res;
          User? _user;
          res=await NetRequester.request(Apis.findUserByName(Global.profile.user!.userId!,widget.msg!.name));
          if(res['code'] == '0'){
            Toast.popToast('用户不存在');
            Future.delayed(const Duration(milliseconds: 500), (){
              Navigator.pop(context);
            });
          }else{
            _user = User.fromJson(res["data"]);
          }
          Navigator.push(context,CupertinoPageRoute(builder: (context)=>ChatPage(user: _user)));
        },
        left: 20,
        right: 20,
        top: 10,
        bottom: 10,
        leading: SizedBox(
          height: ScreenUtil().setWidth(50),
          child: widget.msg?.imageUrl == '' || widget.msg?.imageUrl == null
              ? Image.asset("assets/images/app_logo.png")
              : ClipOval(
                child: ExtendedImage.network(
                    '${NetConfig.ip}/images/${widget.msg?.imageUrl}',
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
                Text(widget.msg!.name,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 200, // 设置最大宽度
                  child: Text(
                    widget.msg!.msg,
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          buildDate(widget.msg!.time),
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}