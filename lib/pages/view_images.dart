import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/net/net.dart';

class ViewImgPage extends StatefulWidget{
  final List? images;
  final int? index;
  final String? postId;
  const ViewImgPage({super.key, this.images, this.index, this.postId});
  @override
  State<StatefulWidget> createState() {
    return _ViewImgPageState();
  }

}

class _ViewImgPageState extends State<ViewImgPage> {
  late int currentIndex;
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    currentIndex = widget.index!;
  }
  @override
  Widget build(BuildContext context) {
    return  PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
        }
      },
      child: Material(
        color: Colors.black,
        child:Stack(
          children: <Widget>[
            ExtendedImageGesturePageView.builder(
              itemBuilder: (BuildContext context, int index) {
                var item = widget.images?[index];
                Widget image = ExtendedImage.network(
                  NetConfig.ip+item,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.gesture,
                );
                image = Container(
                  padding: const EdgeInsets.all(5.0),
                  child: image,
                );
                return InkWell(
                  onTap: (){
                    Navigator.pop(context);
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
                  },
                  child: Hero(
                    tag: widget.postId! +item + index.toString(),
                    child: image,
                  ),
                );
              },
              itemCount: widget.images?.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              controller: ExtendedPageController(
                initialPage: currentIndex,
              ),
              scrollDirection: Axis.horizontal,
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(60)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text((currentIndex+1).toString()+"/"+widget.images!.length.toString(),
                    style: TextStyle(color: Colors.white),),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


}