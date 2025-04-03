import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/maps.dart';
import '../core/net/net.dart';
import '../pages/view_images.dart';
class ImageBuild {
  static Widget singlePostImage(BuildContext context,int id,List images){
    return InkWell(
        onTap: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ViewImgPage(
                  images: images,index: 0,id: id.toString())));
        },
        child: Hero(
            tag: '${id.toString()+images[0]}0',
            child: Container(
              constraints: BoxConstraints(maxHeight: ScreenUtil().setHeight(800),
                  maxWidth: ScreenUtil().setWidth(700)),
              child: ExtendedImage.network(
                NetConfig.ip+images[0],
                cache: true,
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.black12,width: 1),
                // borderRadius: BorderRadius.circular(ScreenUtil().setWidth(21))
              ),
            ))
    );
  }

  static Widget multiPostImage(BuildContext context,int id,List images){
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
          return InkWell(
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ViewImgPage(
                      images: images,index: index,id: id.toString())));
            },
            child: Hero(
              tag: id.toString()+images[index] +index.toString(),
              child: ExtendedImage.network(
                NetConfig.ip+images[index],
                fit: BoxFit.cover,
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.black12,width: 1),
                cache: true,
              ),
            ),
          );
        }),
      ),
    );
  }
// 轮播图展示
  static Widget carouselImages(BuildContext context, int id, List images) {
    // String baseUrl = NetConfig.ip;
    return CarouselSlider(
      options: CarouselOptions(
        height: 300.w,
        // autoPlay: true, // 自动播放
        enlargeCenterPage: true, // 居中放大
        viewportFraction: 0.9, // 视图占比
        enableInfiniteScroll: false, // 禁用无限滚动
      ),
      items: images.map((img) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewImgPage(
                      images: images,
                      index: images.indexOf(img),
                      id: id.toString(),
                    ),
                  ),
                );
              },
              child: Hero(
                // tag: id.toString() + img + images.indexOf(img).toString(),
                tag: 'imagesId_${images.indexOf(img).toString()}',
                child: Image.network(
                  // imageUrl,
                  NetConfig.ip+img,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text("加载失败"));
                  },
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
