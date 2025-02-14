import 'package:client/util/toast.dart';
import 'package:client/util/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/net/my_api.dart';
import '../core/net/net_request.dart';

class CheckoutUpdateUtil {
  //检查更新
  static checkUpdate(BuildContext context) async {
    var res = await NetRequester.request(Apis.checkUpdate());
    //Log().i(res);
    if (res ['code'] == '1') {
      String version = res['data']['version'];
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String localVersion = packageInfo.version;
      if (version != localVersion) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return UpdateDialog(res: res);
            });
      } else {
        Toast.popToast('当前已经是最新版本！');
        //Log().i('版本号相同');
      }

    }
  }

}