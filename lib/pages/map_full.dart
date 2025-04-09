import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/src/map/bmf_models.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:permission_handler/permission_handler.dart';

class MapRoute extends StatefulWidget {
  const MapRoute({super.key});

  @override
  State<StatefulWidget> createState() => MapRouteState();
}

class MapRouteState extends State<MapRoute> {
  // 定位相关
  final LocationFlutterPlugin _locationPlugin = LocationFlutterPlugin();
  final BaiduLocationAndroidOption _androidOption = BaiduLocationAndroidOption(
    coordType: BMFLocationCoordType.gcj02,
  );
  final BaiduLocationIOSOption _iosOption = BaiduLocationIOSOption(
    coordType: BMFLocationCoordType.gcj02,
  );
  BaiduLocation _currentLocation = BaiduLocation();

  // 地图控制
  late BMFMapController _mapController;
  final List<BMFMarker> _markers = [];

  // 搜索相关
  final TextEditingController _searchController = TextEditingController();
  final BMFSuggestionSearch _suggestionSearch = BMFSuggestionSearch();
  List<BMFSuggestionInfo> _searchResults = [];


  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _setupSearchCallbacks();
  }

  @override
  void dispose() {
    // _mapController.dispose();
    _locationPlugin.stopLocation();
    super.dispose();
  }

  void _initializeLocation() async {
    _locationPlugin.setAgreePrivacy(true);
    _configureLocationCallbacks();
    await _startLocationService();
  }

  void _configureLocationCallbacks() {
    _locationPlugin.seriesLocationCallback(callback: (BaiduLocation result) {
      if (mounted) {
        setState(() => _currentLocation = result);
        _updateMapToCurrentLocation();
      }
    });
  }

  Future<void> _startLocationService() async {
    if (await _requestLocationPermission()) {
      _configureLocationOptions();
      _locationPlugin.startLocation();
    }
  }

  void _setupSearchCallbacks() {
    _suggestionSearch.onGetSuggestSearchResult(callback: _handleSearchResults);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildMapWidget()),
          _buildLocationInfoPanel(), // 新增定位信息面板
          if (_searchResults.isNotEmpty) _buildSearchResultsList(),
        ],
      ),
    );
  }
  // 新增定位信息面板
  Widget _buildLocationInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('地址：', _currentLocation.address ?? '正在获取中...'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoRow('纬度：',
                  _currentLocation.latitude?.toStringAsFixed(6) ?? '--'),
              _buildInfoRow('经度：',
                  _currentLocation.longitude?.toStringAsFixed(6) ?? '--'),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        )),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("地点选择", style: TextStyle(color: Colors.black)),
      actions: [
        TextButton(
            onPressed: () => _confirmLocation(),
            child: const Text("确认", style: TextStyle(color: Colors.blue))
        )
      ],
      // ... 其他AppBar配置
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          hintText: "输入地点关键词",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _searchController.clear(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  Widget _buildMapWidget() {
    return BMFMapWidget(
      onBMFMapCreated: _onMapCreated,
      mapOptions: BMFMapOptions(
        center: BMFCoordinate(39.917215, 116.380341),
        zoomLevel: 15,
        compassPosition: BMFPoint(20, 200), // 指南针位置
      ),
    );
  }
  void _onMapCreated(BMFMapController controller) {
    _mapController = controller;
    // 配置定位显示参数
    _mapController.showUserLocation(true);
  }

  Widget _buildSearchResultsList() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 5)],
      ),
      child: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(_searchResults[index].key!),
          subtitle: Text(_searchResults[index].city ?? ''),
          onTap: () => _selectSearchResult(_searchResults[index]),
        ),
      ),
    );
  }

  // void _onMapCreated(BMFMapController controller) {
  //   _mapController = controller;
  //   _mapController.showUserLocation(true);
  // }

  Future<bool> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("需要定位权限以获取当前位置"))
      );
    }
    return status.isGranted;
  }

  void _configureLocationOptions() {
    _androidOption
      ..setCoorType("bd09ll")
      ..setIsNeedAddress(true)
      ..setOpenGps(true)
      ..setLocationMode(BMFLocationMode.hightAccuracy);
    _locationPlugin.prepareLoc(_androidOption.getMap(), _iosOption.getMap());
  }

  void _performSearch() async {
    if (_searchController.text.isEmpty) return;

    final option = BMFSuggestionSearchOption(
      keyword: _searchController.text,
      cityname: _currentLocation.city ?? "北京市",
    );

    await _suggestionSearch.suggestionSearch(option);
  }

  void _handleSearchResults(BMFSuggestionSearchResult result, BMFSearchErrorCode errorCode) {
    if (errorCode != BMFSearchErrorCode.NO_ERROR || result.suggestionList == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("搜索失败，请重试"))
      );
      return;
    }

    setState(() => _searchResults = result.suggestionList!);
  }

  void _selectSearchResult(BMFSuggestionInfo result) {
    final coordinate = BMFCoordinate(
      result.location?.latitude ?? 0,
      result.location?.longitude ?? 0,
    );

    _mapController.updateMapOptions(BMFMapOptions(
      center: coordinate,
      zoomLevel: 17,
    ));

    _addLocationMarker(coordinate, result.key!);
    setState(() => _searchResults = []);
  }

  void _addLocationMarker(BMFCoordinate coordinate, String title) {
    // 移除之前添加的 marker
    for (var marker in _markers) {
      _mapController.removeMarker(marker);
    }
    _markers.clear();

    // 使用 BMFMarker.icon() 创建 marker，传入空字符串 icon 参数，即使用百度默认 marker 图标
    final marker = BMFMarker.icon(
      position: coordinate,
      title: title,
      icon: "", // 空字符串表示使用SDK自带的默认 marker 图标
    );
    _mapController.addMarker(marker);
    _markers.add(marker);

    print("Marker added with default icon: ${marker.toMap()}");
  }

  void _updateMapToCurrentLocation() {
    final coordinate = BMFCoordinate(
      _currentLocation.latitude ?? 39.917215,
      _currentLocation.longitude ?? 116.380341,
    );

    // 更新地图中心（若不希望每次自动移动可根据需求调整）
    _mapController.updateMapOptions(BMFMapOptions(
      center: coordinate,
      zoomLevel: 17,
    ));

    // 移除所有之前的 marker
    for (var marker in _markers) {
      _mapController.removeMarker(marker);
    }
    _markers.clear();

    // 添加新的定位 marker，显示当前位置
    _addLocationMarker(coordinate, "当前位置");
  }


  void _confirmLocation() {
    Navigator.pop(context, {
      'latitude': _currentLocation.latitude,
      'longitude': _currentLocation.longitude,
      'address': _currentLocation.address,
    });
  }
}