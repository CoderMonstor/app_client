
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../util/check_out_up_date.dart';

class AboutPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => _AboutPageState();

}

class _AboutPageState extends State<AboutPage> {
  late String localVersion ;
  late PackageInfo packageInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: FutureBuilder(
        future: getPackageInfo(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            localVersion = packageInfo.version;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                Column(
                  children: <Widget>[
                    SizedBox(width: ScreenUtil().setWidth(1080),
                      height: ScreenUtil().setHeight(50),),
                    Image.asset('assets/images/app_logo.png', width: ScreenUtil().setWidth(200),height: ScreenUtil().setHeight(200)),
                    SizedBox(height: ScreenUtil().setHeight(20),),
                    Text('Hi CDU',style: TextStyle(fontFamily: 'chocolate',fontSize: ScreenUtil().setSp(50))),
                    Text(localVersion,style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Column(
                  children: <Widget>[
                    TextButton(
                      child: Text(
                        '检查更新',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                        ),
                      ),
                      onPressed: () {
                        CheckoutUpdateUtil.checkUpdate(context);
                      },
                    ),
                    // SizedBox(height:50.h),
                    Text('develop by lmy',style: TextStyle(fontSize: ScreenUtil().setSp(15),color: Colors.grey),),
                    // SizedBox(height:40.h,)
                  ],
                ),
              ],
            );
          }else{
            return Container();
          }

        },
      ),
    );
  }

  getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
  }
}