import 'package:client/pages/map_full.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart' as amap;

class PostActivityPage extends StatefulWidget {
  const PostActivityPage({Key? key}) : super(key: key);

  @override
  _PostActivityPageState createState() => _PostActivityPageState();
}

class _PostActivityPageState extends State<PostActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  List<AssetEntity> _selectedAssets = [];
  amap.LatLng? _selectedLocation;

  // 高德定位服务实例（仅在本页面使用默认配置）
  final AMapFlutterLocation _locationService = AMapFlutterLocation();

  @override
  void initState() {
    super.initState();
    // 此处采用默认配置，无需额外设置
  }

  // 选择多张图片
  Future<void> _pickImages() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 9,
        selectedAssets: _selectedAssets,
        requestType: RequestType.image,
      ),
    );

    if (result != null) {
      setState(() => _selectedAssets = result);
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // builder: (context) => const LocationPickerPage(),
        builder: (context) => const AMap(),
      ),
    );

    if (result != null) {
      final loc = result['location'];
      if (loc is Map) {
        _selectedLocation = amap.LatLng(
          loc['latitude'] as double,
          loc['longitude'] as double,
        );
      } else if (loc is amap.LatLng) {
        _selectedLocation = loc;
      }
      _locationController.text = result['address'] as String;
    }
  }
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 处理提交逻辑
    }
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('活动图片 (最多9张)', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _selectedAssets.isEmpty
                ? const Center(child: Icon(Icons.add_photo_alternate, size: 50))
                : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: _selectedAssets.length +
                    (_selectedAssets.length < 9 ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _selectedAssets.length) {
                    return _buildImageItem(_selectedAssets[index]);
                  }
                  return const Center(child: Icon(Icons.add, size: 30));
                },
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem(AssetEntity asset) {
    return Stack(
      children: [
        Positioned.fill(
          child: AssetEntityImage(asset, isOriginal: false, fit: BoxFit.cover),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: () => setState(() => _selectedAssets.remove(asset)),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建新活动')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                readOnly: true,
                onTap: _openMapPicker,
                decoration: const InputDecoration(
                  labelText: '活动地点',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择活动地点';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('发布活动'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



