import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/maps.dart';
import '../core/net/net.dart';
class ImageBuild {
    static Widget singlePostImage(List images){
      return Container(
        constraints: BoxConstraints(
            maxHeight: ScreenUtil().setHeight(800),
            maxWidth: ScreenUtil().setWidth(700)),
        child: ExtendedImage.network(
          NetConfig.ip + images[0],
          cache: true,
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.black12, width: 1),
        ),
      );
    }

    static Widget multiPostImage(List images){
      return Container(
        constraints: BoxConstraints(maxHeight: ScreenUtil().setWidth(gridHeight[images.length])),
        child: GridView.count(
          padding: const EdgeInsets.all(0),
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.0,
          mainAxisSpacing: ScreenUtil().setWidth(12),
          crossAxisSpacing: ScreenUtil().setWidth(12),
          crossAxisCount: images.length==2||images.length==4?2:3,
          children: List.generate(images.length, (index) {
            return ExtendedImage.network(
              NetConfig.ip + images[index],
              fit: BoxFit.cover,
              shape: BoxShape.rectangle,
              border: Border.all(color: Colors.black12, width: 1),
              cache: true,
            );
          }),
        ),
      );
    }

}
