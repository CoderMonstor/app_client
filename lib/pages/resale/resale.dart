// import 'package:amap_flutter_map/amap_flutter_map.dart';
// import 'package:amap_flutter_base/amap_flutter_base.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:ui' as ui;
//
//
// class ResalePage extends StatefulWidget {
//   const ResalePage({super.key});
//
//   @override
//   State<ResalePage> createState() => _ResalePageState();
// }
//
// class _ResalePageState extends State<ResalePage> {
//   late AMapController _mapController;
//   late Map<String, Marker> markerMap;
//   late double nowLatitude;
//   late double nowLongitude;
//   late AMapApiKey aMapApiKey;
//   late AMapPrivacyStatement aMapPrivacyStatement;
//
//   @override
//   void initState() {
//     markerMap = {};
//     nowLatitude = 39.906217;
//     nowLongitude = 116.3912757;
//     aMapApiKey = const AMapApiKey(
//       androidKey: "8eebe9156478a3d3a0a30c6442faf969",
//     );
//     aMapPrivacyStatement = const AMapPrivacyStatement(
//       hasContains: true,
//       hasShow: true,
//       hasAgree: true,
//     );
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SizedBox(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Stack(
//           children: [
//             AMapWidget(
//               apiKey: aMapApiKey,
//               privacyStatement: aMapPrivacyStatement,
//               onMapCreated: onMapCreated,
//               markers: Set.of(markerMap.values),
//             ),
//             Positioned(
//               right: 10,
//               bottom: 10,
//               child: FutureBuilder<String?>(
//                 future: getApprovalNumber(),
//                 builder: (ctx, snapshot) {
//                   return Column(
//                     children: [
//                       Text("${snapshot.data}"),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void onMapCreated(AMapController controller) {
//     CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
//       CameraPosition(
//         target: LatLng(nowLatitude, nowLongitude),
//         zoom: 10,
//         tilt: 30,
//         bearing: 0,
//       ),
//     );
//     controller.moveCamera(cameraUpdate);
//     setState(() {
//       _mapController = controller;
//     });
//     getMarker(
//       nowLatitude,
//       nowLongitude,
//       // image: "assets/images/my_position.png",
//       image: "assets/images/location.png",
//       title: "我",
//     );
//   }
//
//   Future<String?> getApprovalNumber() async {
//     // 普通地图审图号
//     String? mapContentApprovalNumber =
//     await _mapController.getMapContentApprovalNumber();
//     // // 卫星地图审图号
//     // String? satelliteImageApprovalNumber =
//     //     await _mapController.getSatelliteImageApprovalNumber();
//     return mapContentApprovalNumber;
//   }
//
//   Future<void> getMarker(
//       double latitude,
//       double longitude, {
//         String? image,
//         String? title,
//         String? snippet,
//       }) async {
//     LatLng position = LatLng(latitude, longitude);
//     Marker marker = Marker(
//       onTap: (s) {
//         print(s);
//       },
//       infoWindow: InfoWindow(
//         title: title,
//         snippet: snippet,
//       ),
//       position: position,
//       icon: image != null
//           ? await getBitmapDescriptorFromAssetBytes(image, 100, 100)
//           : BitmapDescriptor.defaultMarker,
//     );
//     markerMap[marker.id] = marker;
//     setState(() {});
//   }
//
//   Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(
//       String path,
//       double width,
//       double height,
//       ) async {
//     var imageFile = await rootBundle.load(path);
//     var pictureRecorder = ui.PictureRecorder();
//     var canvas = Canvas(pictureRecorder);
//     var imageUint8List = imageFile.buffer.asUint8List();
//     var codec = await ui.instantiateImageCodec(imageUint8List);
//     var imageFI = await codec.getNextFrame();
//     paintImage(
//       canvas: canvas,
//       rect: Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
//       image: imageFI.image,
//       filterQuality: FilterQuality.medium,
//     );
//     var image = await pictureRecorder
//         .endRecording()
//         .toImage(width.toInt(), height.toInt());
//     var data = await image.toByteData(format: ui.ImageByteFormat.png);
//     return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
//   }
// }
