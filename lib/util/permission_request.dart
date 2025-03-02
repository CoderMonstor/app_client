import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  BuildContext _context;

  PermissionUtil(this._context);

  Future<void> checkPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isDenied) {
      log("拒绝了权限");
      showPermissionRequestDialog('您拒绝了申请权限，但是该应用需要该权限，继续吗', permission, false);
    } else if (status.isPermanentlyDenied) {
      log("永久拒绝了权限");
      showPermissionRequestDialog('您永久拒绝了权限，但是该应用需要该权限，继续吗', permission, true);
    } else {
      log("通过权限申请...");
    }
  }

  void showPermissionRequestDialog(String message, Permission permission, bool gotoAppSettings) {
    showDialog(
      context: _context,
      builder: (context) {
        return AlertDialog(
          title: const Text('权限申请'),
          content: SizedBox(width: 200, child: Text(message)),
          actions: <Widget>[
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (gotoAppSettings) {
                  openAppSettings();
                } else {
                  requestPermission(permission);
                }
              },
              child: const Text('确定'),
            ),
          ],
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        );
      },
    );
  }

  Future<void> requestPermission(Permission permission) async {
    // 请求权限并检查结果
    final status = await permission.request();

    await checkPermission(permission);
  }

  void closeApp() {
    SystemChannels.platform.invokeMethod("SystemNavigator.pop");
  }
}
