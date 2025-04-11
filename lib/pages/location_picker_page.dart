import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:permission_handler/permission_handler.dart';

class MapChoosePage extends StatefulWidget {
  const MapChoosePage({super.key});

  @override
  _MapChoosePageState createState() => _MapChoosePageState();
}

class _MapChoosePageState extends State<MapChoosePage> {
  // 定位相关
  final LocationFlutterPlugin _locationPlugin = LocationFlutterPlugin();
  final BaiduLocationAndroidOption _androidOption = BaiduLocationAndroidOption(
    coordType: BMFLocationCoordType.bd09ll, // 统一坐标系
  );
  final BaiduLocationIOSOption _iosOption = BaiduLocationIOSOption(
    coordType: BMFLocationCoordType.bd09ll,
  );
  BaiduLocation _currentLocation = BaiduLocation();

  // 地图相关
  late BMFMapController _mapController;
  // final BMFMapOptions _mapOptions = BMFMapOptions(
  //   zoomLevel: 15,
  // );
  final BMFMapOptions _mapOptions = BMFMapOptions(
    center: BMFCoordinate(39.915, 116.404), // 默认北京坐标
    zoomLevel: 15,
    mapType: BMFMapType.Standard,
  );

  // 搜索相关
  final TextEditingController _searchController = TextEditingController();
  final BMFSuggestionSearch _suggestionSearch = BMFSuggestionSearch();
  List<BMFSuggestionInfo> _suggestionList = [];
  List<BMFPoiInfo> _poiList = [];
  bool _isSearch = false;
  Timer? _debounceTimer; // 防抖计时器
  // 新增地图初始化完成标记
  bool _isMapInitialized = false;
  // 新增定位坐标缓存
  BMFCoordinate? _currentCoordinate;

  @override
  void initState() {
    super.initState();
    BMFMapSDK.setApiKeyAndCoordType("Iqz97wmkFTMnFOBRzjk0MGDydy0SKqfN", BMF_COORD_TYPE.BD09LL); // 必须设置
    BMFMapSDK.setAgreePrivacy(true);
    _initializeLocation();
    _searchController.addListener(_handleSearchInput);
    _suggestionSearch.onGetSuggestSearchResult(callback: _onSuggestSearchResult);
  }

  void _handleSearchInput() {
    // 添加防抖处理（500毫秒）
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isEmpty) {
        setState(() => _isSearch = false);
      } else {
        _searchLocation(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _locationPlugin.stopLocation();
    _searchController.dispose();
    super.dispose();
  }

  /// 初始化定位服务
  void _initializeLocation() async {
    // 先设置隐私协议
    await _locationPlugin.setAgreePrivacy(true);
    // 配置定位参数
    _configureLocationOptions();
    // 请求权限
    if (await _requestLocationPermission()) {
      _startLocationService();
    }
  }
  Future<bool> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      if (mounted) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("需要定位权限"),
              actions: [
                TextButton(
                  child: const Text("去设置"),
                  onPressed: () => openAppSettings(),
                ),
                TextButton(
                  child: const Text("取消"),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
      }
      return false;
    }
    return true;
  }
  void _configureLocationOptions() {
    // Android配置
    _androidOption
      ..setCoorType("bd09ll")
      ..setIsNeedAddress(true)
      ..setOpenGps(true)
      ..setLocationMode(BMFLocationMode.hightAccuracy)
      ..setScanspan(3000); // 设置定位间隔
    _locationPlugin.prepareLoc(_androidOption.getMap(), _iosOption.getMap());
  }

  void _startLocationService() {
    try {
      _locationPlugin.startLocation();
      _locationPlugin.seriesLocationCallback(callback: (BaiduLocation result) {
        print("定位结果: lat=${result.latitude}, lng=${result.longitude}, address=${result.address}");
        if (!mounted) return;
        // 增强型空值检查
        if (result.latitude == null || result.longitude == null) {
          print("定位数据异常: ${result}");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("获取定位信息失败，请检查GPS设置")),
            );
          }
          return;
        }
        setState(() {
          _currentLocation = result;
          _currentCoordinate = BMFCoordinate(
              result.latitude!,
              result.longitude!
          );
        });
        if (_isMapInitialized) {
          _mapController.updateMapOptions(BMFMapOptions(
            center: _currentCoordinate!,
            zoomLevel: 17,
          ));
        }
        // _tryUpdateMapCenter();
      });
    }catch(e){
      print("启动定位服务失败: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("无法启动定位服务")),
        );
      }
    }

  }
  /// 更新地图中心到当前位置
  void _updateMapToCurrentLocation() {
    // _getPoiByLocation(coordinate);
    if (_currentCoordinate != null) {
      _mapController.updateMapOptions(BMFMapOptions(
        center: _currentCoordinate!,
        zoomLevel: 17,
      ));
    } else {
      print("No valid coordinate available");
      // 添加重新定位逻辑
      _startLocationService();
    }
  }

  void _onMapCreated(BMFMapController controller) {
    _mapController = controller;
    // BMFUserLocationOptions options = BMFUserLocationOptions(
    //   locationMode: BMFUserLocationMode.FOLLOW,
    //   isAccuracyCircleShow: true,
    //   accuracyCircleFillColor: Colors.blue.withOpacity(0.3),
    //   icon: BitmapDescriptor.fromAsset('assets/my_location_icon.png'),
    // );
    //
    // _mapController.showUserLocationWithOptions(options);
    _mapController.showUserLocation(true);
    _mapController.setMapDidLoadCallback(callback: () {
      setState(() => _isMapInitialized = true);
      _tryUpdateMapCenter();
    });
    _mapController.setMapDidLoadCallback(callback: () {
      print("地图初始化完成");
      setState(() => _isMapInitialized = true);
      if (_currentCoordinate != null) {
        _tryUpdateMapCenter();
      } else {
        print("等待定位数据...");
        _startLocationService(); // 如果还没有定位数据，重新请求
      }
    });
    // 监听地图移动
    _mapController.setMapRegionDidChangeWithReasonCallback(
      callback: (status, reason) => _getPoiByLocation(status.targetGeoPt!),
    );
  }

  void _tryUpdateMapCenter() {
    if (_isMapInitialized && _currentCoordinate != null) {
      _mapController.updateMapOptions(BMFMapOptions(
        center: _currentCoordinate,
        zoomLevel: 17,
      ));
      _getPoiByLocation(_currentCoordinate!);
    }
  }
  /// 逆地理编码获取POI
  void _getPoiByLocation(BMFCoordinate coordinate) async {
    final option = BMFReverseGeoCodeSearchOption(location: coordinate);
    final search = BMFReverseGeoCodeSearch();
    search.onGetReverseGeoCodeSearchResult(
      callback: (result, error) {
        if (error != BMFSearchErrorCode.NO_ERROR) return;
        setState(() {
          _poiList = result.poiList ?? [];
          // 更新当前定位信息为逆地理编码结果
          _currentLocation = BaiduLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            address: result.address ?? "未知地址", // 使用逆地理编码地址
            country: result.addressDetail?.country,
            province: result.addressDetail?.province,
            city: result.addressDetail?.city,
            district: result.addressDetail?.district,
            street: result.addressDetail?.streetName,
          );
        });
      },
    );
    await search.reverseGeoCodeSearch(option);
  }

  void _onSuggestionTap(BMFSuggestionInfo info) {
    if (info.location == null) return;
    final coordinate = info.location!;
    // 立即更新定位信息（临时地址）
    setState(() {
      _currentLocation = BaiduLocation(
          latitude: coordinate.latitude,
          longitude: coordinate.longitude,
          address: _buildTemporaryAddress(info), // 构建临时地址
          city: info.city,
          district: info.district
      );
    });
    _mapController.updateMapOptions(BMFMapOptions(
      center: coordinate,
      zoomLevel: 17,
    ));
    _getPoiByLocation(coordinate); // 后续会通过逆地理编码更新详细地址
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

// 构建临时地址的辅助方法
  String _buildTemporaryAddress(BMFSuggestionInfo info) {
    return [
      info.city?.replaceAll("市", "") ?? "",
      info.district ?? "",
      info.key ?? ""
    ].join(" ");
  }
  /// 处理搜索建议结果
  void _onSuggestSearchResult(BMFSuggestionSearchResult result, BMFSearchErrorCode error) {
    if (error != BMFSearchErrorCode.NO_ERROR) {
      print("搜索失败，错误码：$error");
      return;
    }
    setState(() {
      _suggestionList = result.suggestionList ?? [];
      _isSearch = true;
    });
  }
  /// 执行搜索建议请求
  void _searchLocation(String keyword) async {
    final option = BMFSuggestionSearchOption(
      keyword: keyword,
      cityname: _currentLocation.city ?? "全国", // 使用当前定位城市
    );
    await _suggestionSearch.suggestionSearch(option);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("选址"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _updateMapToCurrentLocation,
          ),
          TextButton(
            onPressed: (){
              print('返回的数据：');
              Navigator.pop(context, {
                "latitude": _currentLocation.latitude,
                "longitude": _currentLocation.longitude,
                "address": _currentLocation.address,
              });
            },
            child: const Text("确定"),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                BMFMapWidget(
                  onBMFMapCreated: _onMapCreated,
                  mapOptions: _mapOptions,
                ),
                const Icon(Icons.location_pin, size: 40, color: Colors.red),
              ],
            ),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "搜索地点...",
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isSearch
                ? _buildSuggestionList()
                : _buildPoiList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionList() {
    return ListView.builder(
      itemCount: _suggestionList.length,
      itemBuilder: (context, index) {
        final info = _suggestionList[index];
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(info.key ?? "未知地点"),
          subtitle: Text("${info.city} ${info.district}"),
          onTap: () => _onSuggestionTap(info),
        );
      },
    );
  }

  Widget _buildPoiList() {
    return ListView.builder(
      itemCount: _poiList.length,
      itemBuilder: (context, index) {
        final poi = _poiList[index];
        return ListTile(
          leading: const Icon(Icons.place),
          title: Text(poi.name ?? "未知名称"),
          subtitle: Text(poi.address ?? "无地址信息"),
          onTap: () {
            _mapController.updateMapOptions(BMFMapOptions(
              center: poi.pt,
              zoomLevel: 18,
            ));
          },
        );
      },
    );
  }
}