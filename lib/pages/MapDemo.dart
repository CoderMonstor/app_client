// import 'dart:async';
//
// import 'package:amap_flutter_base/amap_flutter_base.dart';
// import 'package:amap_flutter_location/amap_flutter_location.dart';
// import 'package:amap_flutter_location/amap_location_option.dart';
// import 'package:amap_flutter_map/amap_flutter_map.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class MapDemo extends StatefulWidget {
//   const MapDemo({super.key});
//
//   @override
//   _MapDemoState createState() => _MapDemoState();
// }
//
// class _MapDemoState extends State<MapDemo> {
//   late final CameraPosition _kInitialPosition = const CameraPosition(
//     target: LatLng(39.909187, 116.397451),
//     zoom: 10.0,
//   );
//
//   late AMapController _mapController;
//   final List<Widget> _approvalNumberWidget = [];
//
//   Map<String, Object>? _locationResult;
//
//   StreamSubscription<Map<String, Object>>? _locationListener;
//   final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();
//
//   final Set<Marker> _markers = {};
//
//   @override
//   void initState() {
//     super.initState();
//     // AMapFlutterLocation.updatePrivacyShow(true, true); // 显示隐私弹窗
//     // AMapFlutterLocation.updatePrivacyAgree(true);      // 用户同意隐私政策
//
//     /// 动态申请定位权限
//     requestPermission();
//     ///注册定位结果监听
//     _locationListener = _locationPlugin.onLocationChanged().listen(
//           (Map<String, Object> result) {
//         setState(() {
//           _locationResult = result;
//           print('-------------------_locationResult: $_locationResult');
//           if (result.containsKey('latitude') &&
//               result.containsKey('longitude')) {
//             _markers.add(
//               Marker(
//                 draggable: true,
//                 clickable: true,
//                 onTap: (String id) {
//                   print('-------------onTap id:$id');
//                 },
//                 onDragEnd: (String id, LatLng endPosition) {
//                   print('-------------id:$id, endPosition:$endPosition');
//                 },
//                 position: LatLng(result['latitude'] as double,
//                     result['longitude'] as double),
//               ),
//             );
//             /// 移动地图到 当前（或则你想要的位置）  位置
//             _mapController.moveCamera(
//               CameraUpdate.newLatLngZoom(
//                   LatLng(result['latitude'] as double,
//                       result['longitude'] as double),
//                   18),
//             );
//           }
//         });
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     if (null != _locationListener) {
//       _locationListener?.cancel();
//     }
//     _locationPlugin.destroy();
//   }
//
//   void _setLocationOption() {
//     AMapLocationOption locationOption = AMapLocationOption();
//     ///是否单次定位
//     locationOption.onceLocation = true;
//     ///是否需要返回逆地理信息
//     locationOption.needAddress = true;
//     ///逆地理信息的语言类型
//     locationOption.geoLanguage = GeoLanguage.DEFAULT;
//     locationOption.desiredLocationAccuracyAuthorizationMode =
//         AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;
//     locationOption.fullAccuracyPurposeKey = "AMapLocationScene";
//     ///设置Android端连续定位的定位间隔
//     locationOption.locationInterval = 2000;
//     ///设置Android端的定位模式<br>
//     ///可选值：<br>
//     ///<li>[AMapLocationMode.Battery_Saving]</li>
//     ///<li>[AMapLocationMode.Device_Sensors]</li>
//     ///<li>[AMapLocationMode.Hight_Accuracy]</li>
//     locationOption.locationMode = AMapLocationMode.Hight_Accuracy;
//     ///设置iOS端的定位最小更新距离<br>
//     locationOption.distanceFilter = -1;
//     ///设置iOS端期望的定位精度
//     /// 可选值：<br>
//     /// <li>[DesiredAccuracy.Best] 最高精度</li>
//     /// <li>[DesiredAccuracy.BestForNavigation] 适用于导航场景的高精度 </li>
//     /// <li>[DesiredAccuracy.NearestTenMeters] 10米 </li>
//     /// <li>[DesiredAccuracy.Kilometer] 1000米</li>
//     /// <li>[DesiredAccuracy.ThreeKilometers] 3000米</li>
//     locationOption.desiredAccuracy = DesiredAccuracy.Best;
//     ///设置iOS端是否允许系统暂停定位
//     locationOption.pausesLocationUpdatesAutomatically = false;
//     ///将定位参数设置给定位插件
//     _locationPlugin.setLocationOption(locationOption);
//   }
//
//   ///开始定位
//   void _startLocation() {
//     ///开始定位之前设置定位参数
//     print('当前使用的 Key 是：8eebe9156478a3d3a0a30c6442faf969');
//     print('包名：com.example.client');
//     print('SHA1：77:51:45:1C:13:54:68:DD:CB:87:CE:83:55:AC:36:4E:58:76:06:F2');
//     _setLocationOption();
//     _locationPlugin.startLocation();
//   }
//
//   ///停止定位
//   void _stopLocation() {
//     _locationPlugin.stopLocation();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final AMapWidget map = AMapWidget(
//       initialCameraPosition: _kInitialPosition,
//       onMapCreated: onMapCreated,
//       markers: _markers,
//     );
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('AMap'),
//         ),
//         body: Column(children: [
//           Container(
//             height: 300,
//             color: Colors.amber,
//             child: Stack(children: [
//               map,
//               Positioned(
//                 right: 5,
//                 bottom: 5,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.indigo.withOpacity(0.5),
//                   ),
//                   child: IconButton(
//                     icon: const Icon(
//                       Icons.location_searching_rounded,
//                       color: Colors.white,
//                     ),
//                     onPressed: () {
//                       _startLocation();
//                     },
//                   ),
//                 ),
//               ),
//             ]),
//           ),
//           Expanded(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     print('开始定位');
//                     _startLocation();
//                   },
//                   child: const Text('开始定位'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     print('结束定位');
//                     _stopLocation();
//                   },
//                   child: const Text('结束定位'),
//                 ),
//               ],
//             ),
//           )
//         ]));
//   }
//
//   void onMapCreated(AMapController controller) {
//     setState(() {
//       _mapController = controller;
//       getApprovalNumber();
//     });
//   }
//
//   void getApprovalNumber() async {
//     //普通地图审图号
//     String? mapContentApprovalNumber =
//     await _mapController.getMapContentApprovalNumber();
//     //卫星地图审图号
//     String? satelliteImageApprovalNumber =
//     await _mapController.getSatelliteImageApprovalNumber();
//     setState(() {
//       if (null != mapContentApprovalNumber) {
//         _approvalNumberWidget.add(Text(mapContentApprovalNumber));
//       }
//       if (null != satelliteImageApprovalNumber) {
//         _approvalNumberWidget.add(Text(satelliteImageApprovalNumber));
//       }
//     });
//     print('地图审图号（普通地图）: $mapContentApprovalNumber');
//     print('地图审图号（卫星地图): $satelliteImageApprovalNumber');
//   }
//
//   /// 动态申请定位权限
//   void requestPermission() async {
//     // 申请权限
//     bool hasLocationPermission = await requestLocationPermission();
//     if (hasLocationPermission) {
//       print("定位权限申请通过");
//     } else {
//       print("定位权限申请不通过");
//     }
//   }
//
//   /// 申请定位权限
//   /// 授予定位权限返回true， 否则返回false
//   Future<bool> requestLocationPermission() async {
//     //获取当前的权限
//     var status = await Permission.location.status;
//     if (status == PermissionStatus.granted) {
//       //已经授权
//       return true;
//     } else {
//       //未授权则发起一次申请
//       status = await Permission.location.request();
//       if (status == PermissionStatus.granted) {
//         return true;
//       } else {
//         return false;
//       }
//     }
//   }
// }