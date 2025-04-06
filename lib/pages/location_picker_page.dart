import 'package:amap_flutter_base/amap_flutter_base.dart' as amap;
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late AMapController _mapController;
  amap.LatLng? _selectedPosition;
  String _address = '正在获取位置...';

  // 在此页面单独创建定位服务实例
  final AMapFlutterLocation _locationService = AMapFlutterLocation();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    _locationService.startLocation();
    _locationService.onLocationChanged().listen((locationData) {
      if (locationData["latitude"] != null && locationData["longitude"] != null) {
        final latLng = amap.LatLng(
          locationData["latitude"] as double,
          locationData["longitude"] as double,
        );
        _updateAddress(latLng);
        _locationService.stopLocation(); // 获取一次后停止定位
      }
    });
  }


  void _updateAddress(amap.LatLng position) {
    // 这里只展示经纬度信息作为地址
    setState(() {
      _selectedPosition = position;
      _address = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择位置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_selectedPosition != null) {
                Navigator.pop(context, {
                  'location': _selectedPosition,
                  'address': _address,
                });
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AMapWidget(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _selectedPosition != null
                  ? {
                Marker(
                  position: _selectedPosition!,
                  icon: BitmapDescriptor.defaultMarker,
                )
              }
                  : <Marker>{},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_address),
          ),
        ],
      ),
    );
  }
}