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
  final LocationFlutterPlugin _locationPlugin = LocationFlutterPlugin();
  final BaiduLocationAndroidOption _androidOption = BaiduLocationAndroidOption(
    coordType: BMFLocationCoordType.bd09ll,
  );
  final BaiduLocationIOSOption _iosOption = BaiduLocationIOSOption(
    coordType: BMFLocationCoordType.bd09ll,
  );
  BaiduLocation _currentLocation = BaiduLocation();

  late BMFMapController _mapController;
  BMFCoordinate? _initialCenter;

  final TextEditingController _searchController = TextEditingController();
  final BMFSuggestionSearch _suggestionSearch = BMFSuggestionSearch();
  List<BMFSuggestionInfo> _suggestionList = [];
  List<BMFPoiInfo> _poiList = [];
  bool _isSearch = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    BMFMapSDK.setAgreePrivacy(true);
    _initializeLocation();
    _searchController.addListener(_handleSearchInput);
    _suggestionSearch.onGetSuggestSearchResult(callback: _onSuggestSearchResult);
  }

  void _handleSearchInput() {
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

  void _initializeLocation() async {
    await _locationPlugin.setAgreePrivacy(true);
    _configureLocationOptions();

    if (await _requestLocationPermission()) {
      _startLocationService();
    }
  }

  Future<bool> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("需要定位权限以获取当前位置")),
      );
      return false;
    }
    return true;
  }

  void _configureLocationOptions() {
    _androidOption
      ..setCoorType("bd09ll")
      ..setIsNeedAddress(true)
      ..setOpenGps(true)
      ..setLocationMode(BMFLocationMode.hightAccuracy);

    _locationPlugin.prepareLoc(_androidOption.getMap(), _iosOption.getMap());
  }

  void _startLocationService() {
    _locationPlugin.startLocation();
    _locationPlugin.seriesLocationCallback(callback: (BaiduLocation result) {
      if (!mounted || result.latitude == null) return;

      setState(() {
        _currentLocation = result;
        _initialCenter ??= BMFCoordinate(result.latitude!, result.longitude!);
      });

      _updateMapToCurrentLocation();
    });
  }

  void _updateMapToCurrentLocation() {
    if (_currentLocation.latitude == null || _mapController == null) return;

    final coordinate = BMFCoordinate(
      _currentLocation.latitude!,
      _currentLocation.longitude!,
    );

    _mapController.updateMapOptions(BMFMapOptions(
      center: coordinate,
      zoomLevel: 17,
    ));

    _getPoiByLocation(coordinate);
  }

  void _onMapCreated(BMFMapController controller) {
    _mapController = controller;
    _mapController.showUserLocation(true);
    _mapController.setMapDidLoadCallback(callback: _updateMapToCurrentLocation);
    _mapController.setMapRegionDidChangeWithReasonCallback(
      callback: (status, reason) => _getPoiByLocation(status.targetGeoPt!),
    );
  }

  void _getPoiByLocation(BMFCoordinate coordinate) async {
    final option = BMFReverseGeoCodeSearchOption(location: coordinate);
    final search = BMFReverseGeoCodeSearch();

    search.onGetReverseGeoCodeSearchResult(
      callback: (result, error) {
        if (error != BMFSearchErrorCode.NO_ERROR) return;
        setState(() => _poiList = result.poiList ?? []);
      },
    );

    await search.reverseGeoCodeSearch(option);
  }

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

  void _searchLocation(String keyword) async {
    final option = BMFSuggestionSearchOption(
      keyword: keyword,
      cityname: _currentLocation.city ?? "全国",
    );

    await _suggestionSearch.suggestionSearch(option);
  }

  void _onSuggestionTap(BMFSuggestionInfo info) {
    if (info.location == null) return;

    final coordinate = info.location!;
    _mapController.updateMapOptions(BMFMapOptions(
      center: coordinate,
      zoomLevel: 17,
    ));

    _getPoiByLocation(coordinate);
    _searchController.clear();
    FocusScope.of(context).unfocus();
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
            onPressed: () => Navigator.pop(context, {
              "latitude": _currentLocation.latitude,
              "longitude": _currentLocation.longitude,
              "address": _currentLocation.address,
            }),
            child: const Text("确定", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _initialCenter != null
                    ? BMFMapWidget(
                  onBMFMapCreated: _onMapCreated,
                  mapOptions: BMFMapOptions(
                    center: _initialCenter!,
                    zoomLevel: 15,
                  ),
                )
                    : const Center(child: CircularProgressIndicator()),
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
      height: 240,
      decoration: BoxDecoration(
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
            child: _isSearch ? _buildSuggestionList() : _buildPoiList(),
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
