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
    // 设置API Key及坐标系
    BMFMapSDK.setApiKeyAndCoordType(
        "Iqz97wmkFTMnFOBRzjk0MGDydy0SKqfN", BMF_COORD_TYPE.BD09LL);
    BMFMapSDK.setAgreePrivacy(true);
    _initializeLocation();

    // 监听搜索输入变化
    _searchController.addListener(_handleSearchInput);
    // 注册搜索建议回调
    _suggestionSearch
        .onGetSuggestSearchResult(callback: _onSuggestSearchResult);
  }

  void _handleSearchInput() {
    // 打印当前输入关键字（调试信息）
    debugPrint("搜索输入：${_searchController.text}");
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
        debugPrint(
            "定位结果: lat=${result.latitude}, lng=${result.longitude}, address=${result.address}");
        if (!mounted) return;
        // 增强型空值检查
        if (result.latitude == null || result.longitude == null) {
          debugPrint("定位数据异常: ${result}");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("获取定位信息失败，请检查GPS设置")),
            );
          }
          return;
        }
        setState(() {
          _currentLocation = result;
          _currentCoordinate =
              BMFCoordinate(result.latitude!, result.longitude!);
        });
        if (_isMapInitialized) {
          _mapController.updateMapOptions(BMFMapOptions(
            center: _currentCoordinate!,
            zoomLevel: 17,
          ));
        }
      });
    } catch (e) {
      debugPrint("启动定位服务失败: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("无法启动定位服务")),
        );
      }
    }
  }

  /// 更新地图中心到当前位置
  void _updateMapToCurrentLocation() {
    if (_currentCoordinate != null) {
      _mapController.updateMapOptions(BMFMapOptions(
        center: _currentCoordinate!,
        zoomLevel: 17,
      ));
    } else {
      debugPrint("No valid coordinate available");
      _startLocationService();
    }
  }

  void _onMapCreated(BMFMapController controller) {
    _mapController = controller;
    _mapController.showUserLocation(true);
    _mapController.setMapDidLoadCallback(callback: () {
      debugPrint("地图初始化完成");
      setState(() => _isMapInitialized = true);
      if (_currentCoordinate != null) {
        _tryUpdateMapCenter();
      } else {
        debugPrint("等待定位数据...");
        _startLocationService();
      }
    });
    // 监听地图移动
    _mapController.setMapRegionDidChangeWithReasonCallback(
      callback: (status, reason) {
        if (status.targetGeoPt != null) {
          _getPoiByLocation(status.targetGeoPt!);
        }
      },
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
        if (error != BMFSearchErrorCode.NO_ERROR) {
          debugPrint("逆地理编码错误码：$error");
          return;
        }
        setState(() {
          _poiList = result.poiList ?? [];
          // 更新当前定位信息为逆地理编码结果
          _currentLocation = BaiduLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            address: result.address ?? "未知地址",
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
    debugPrint("点击建议：${info.key}, 坐标：${coordinate.latitude}, ${coordinate.longitude}");
    setState(() {
      _currentLocation = BaiduLocation(
          latitude: coordinate.latitude,
          longitude: coordinate.longitude,
          address: _buildTemporaryAddress(info),
          city: info.city,
          district: info.district);
    });
    _mapController.updateMapOptions(BMFMapOptions(
      center: coordinate,
      zoomLevel: 17,
    ));
    _getPoiByLocation(coordinate);
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
  void _onSuggestSearchResult(
      BMFSuggestionSearchResult result, BMFSearchErrorCode error) {
    if (error != BMFSearchErrorCode.NO_ERROR) {
      debugPrint("搜索建议出错，错误码：$error");
      return;
    }
    debugPrint("搜索建议返回：${result.suggestionList?.length ?? 0}条数据");
    setState(() {
      _suggestionList = result.suggestionList ?? [];
      _isSearch = true;
    });
  }

  /// 执行搜索建议请求
  void _searchLocation(String keyword) async {
    debugPrint("开始搜索：$keyword");
    final option = BMFSuggestionSearchOption(
      keyword: keyword,
      cityname: _currentLocation.city ?? "全国",
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
            onPressed: () {
              debugPrint('返回的数据：lat=${_currentLocation.latitude}, lng=${_currentLocation.longitude}, address=${_currentLocation.address}');
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
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _isSearch = false);
                  },
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
          subtitle: Text("${info.city ?? ""} ${info.district ?? ""}"),
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
            debugPrint("点击POI: ${poi.name}");
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
