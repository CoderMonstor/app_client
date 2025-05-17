import 'package:client/pages/user/profile_page.dart';
import 'package:client/pages/user/qr_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:url_launcher/url_launcher.dart';

import '../core/global.dart';
import '../util/my_icon/my_icon.dart';
import '../util/toast.dart';



class MobileScanCameraDialog extends StatefulWidget {
  const MobileScanCameraDialog({super.key});

  @override
  State<MobileScanCameraDialog> createState() => _MobileScanCameraDialogState();
}

class _MobileScanCameraDialogState extends State<MobileScanCameraDialog>
    with TickerProviderStateMixin {
  Color backColor = Colors.black54;
  late MobileScannerController _controller;
  bool isFirst = true;

  late Animation _lineAnimation;
  late AnimationController _lineController;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _lineController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // 初始化线条动画
    _lineAnimation = Tween<double>(begin: 30, end: 290).animate(_lineController)
      ..addListener(() {
        // 当动画完成时，重置并重新启动动画
        if (_lineController.isCompleted) {
          _lineController.reset();
          _lineController.forward();
        }
        // 更新状态以触发界面重绘
        setState(() {});
      });

    _lineController.forward();

    // 初始化摄像头控制器
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  var border = BorderSide(width: 2.5, color: Theme.of(context).colorScheme.secondary);
      return Material(
        child: Stack(
          children: <Widget>[
          MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && isFirst) {
                  _handleResult(barcodes.first, context);
                }
              },
            ),
          Column(
            children: <Widget>[
              AppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text('扫一扫',style: TextStyle(color: Colors.white),),
                backgroundColor: backColor,
              ),
              Container(
                height: ScreenUtil().setHeight(150),
                decoration: BoxDecoration(
                    color: backColor,
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1, // 左侧部分
                    child: Container(
                      height: ScreenUtil().setWidth(350),
                      decoration: BoxDecoration(
                        color: backColor,
                        // border: Border.all(width: 0.04, color: backColor),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5, // 中间部分占据更多空间
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: ScreenUtil().setWidth(350),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.secondary),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  _buildContainer(context, Border(top: border, left: border)),
                                  _buildContainer(context, Border(top: border, right: border)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  _buildContainer(context, Border(bottom: border, left: border)),
                                  _buildContainer(context, Border(bottom: border, right: border)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: ScreenUtil().setHeight(_lineAnimation.value),
                            left: ScreenUtil().setHeight(15),
                            right: ScreenUtil().setHeight(15),
                          ),
                          width: double.infinity,
                          height: ScreenUtil().setWidth(1),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.secondary.withOpacity(0.01),
                                Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                                Theme.of(context).colorScheme.secondary,
                                Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                                Theme.of(context).colorScheme.secondary.withOpacity(0.01),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1, // 右侧部分
                    child: Container(
                      height: ScreenUtil().setWidth(350),
                      decoration: BoxDecoration(
                        color: backColor,
                        border: Border.all(width: 0.04, color: backColor),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: backColor,
                      border: Border.all(width: 0.04, color: backColor)),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: ScreenUtil().setHeight(30)),
                      const Text(
                        '将二维码图片对准取景框即可自动扫描',
                        style: TextStyle(
                            color: Colors.white,
                          fontSize: 20
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(50)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          _buildGridItem(MyIcons.qr_code, '我的二维码名片', () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => QrPage(
                                      user: Global.profile.user,
                                    )));
                          }),
                          _buildGridItem(MyIcons.image, '从相册读取', () async {
                            final ImagePicker picker = ImagePicker();
                            picker.pickImage(source: ImageSource.gallery).then((image) async {
                              if (image != null) {
                                try {
                                  final BarcodeCapture? capture = await _controller.analyzeImage(
                                    image.path,
                                    formats: [BarcodeFormat.qrCode],
                                  );
                                  if (capture != null && capture.barcodes.isNotEmpty) {
                                    final Barcode barcode = capture.barcodes.first;
                                    if (isFirst) {
                                      _handleResult(barcode, context);
                                    }
                                  }
                                } catch (e) {
                                  print('扫描失败: $e');
                                }
                              }
                            });
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container _buildContainer(BuildContext context, Border border) {
    return Container(
      width: ScreenUtil().setHeight(50),
      height: ScreenUtil().setHeight(50),
      decoration: BoxDecoration(border: border),
    );
  }

  Future<bool> getFlashMode() async {
    // if (!_controller.isRunning) return false; // 检查是否已启动
    return _controller.torchEnabled;
  }
  void toggleFlash() {
    _controller.toggleTorch(); // 自动切换开关
  }

  Widget _buildGridItem(IconData icon, String label, Function function) {
    return SizedBox(
      child: Column(
        children: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              shape: const CircleBorder(),
            ),
            onPressed: () => function(),
            child: Icon(
              icon,
              color: Colors.white,
              size: ScreenUtil().setWidth(45),
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(15)),
          Text(
            label,
            style: TextStyle(
                color: Colors.white, fontSize: ScreenUtil().setSp(20)),
          )
        ],
      ),
    );
  }


  //处理扫描结果
  Future<void> _handleResult(Barcode result, BuildContext context) async {
    isFirst = false;
    var data = result.rawValue;  // `rawValue` 是扫码结果的原始字符串
    print(data);
    if (data!.contains('userId=')) {
      var list = data.split('=');
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ProfilePage(userId: int.parse(list[1]))));
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return Material(
              color: Colors.black26,
              child: SizedBox(
                width: ScreenUtil().setWidth(1080),
                height: ScreenUtil().setHeight(1920),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(48),
                          vertical: ScreenUtil().setHeight(30)),
                      constraints: BoxConstraints(maxHeight: ScreenUtil().setHeight(350)),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(ScreenUtil().setWidth(21)))),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              SizedBox(
                                  width: ScreenUtil().setWidth(800),
                                  child: Text(data)),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                child: Text('复制', style: TextStyle(color: Theme.of(context).primaryColor)),
                                onPressed: () {
                                  Navigator.pop(context);
                                  try {
                                    Clipboard.setData(ClipboardData(text: data));
                                    Toast.popToast('文本已复制到剪贴板');
                                  } catch (e) {
                                    // 处理异常
                                  }
                                },
                              ),
                              TextButton(
                                child: Text('打开', style: TextStyle(color: Theme.of(context).primaryColor)),
                                onPressed: () async {
                                  try {
                                    final Uri url = Uri.parse(data);  // 将字符串转换为 Uri 对象
                                    if (await canLaunchUrl(url)) {  // 使用 canLaunchUrl 替代 canLaunch
                                      Navigator.pop(context);
                                      await launchUrl(url);  // 使用 launchUrl 替代 launch
                                    } else {
                                      Toast.popToast('打开失败');
                                    }
                                  } catch (e) {
                                    Toast.popToast('无效的 URL');
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
      ).then((v) {
        Future.delayed(const Duration(seconds: 1), () {
          isFirst = true;
        });
      });
    }
  }

}
