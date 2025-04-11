import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:intl/intl.dart';  // 用于格式化日期

import '../location_picker_page.dart';
import '../map_full.dart';

class PostActivityPage extends StatefulWidget {
  const PostActivityPage({Key? key}) : super(key: key);

  @override
  _PostActivityPageState createState() => _PostActivityPageState();
}

class _PostActivityPageState extends State<PostActivityPage> {
  final _formKey = GlobalKey<FormState>();

  // 控制器
  final TextEditingController _locationController = TextEditingController();

  // 活动字段
  String? _activityName;
  DateTime? _activityTime;
  int? _maxParticipants;
  String? _details;

  // 选择的图片
  List<AssetEntity> _selectedAssets = [];

  @override
  void initState() {
    super.initState();
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

  // 地图选择返回位置信息（地址、经纬度等）
  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapChoosePage(),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        _locationController.text = result["address"] ?? '';
      });
      print('收到的位置信息: $result');
    }
  }

  // 选择活动时间（仅选择日期）
  Future<void> _selectActivityTime() async {
    final DateTime now = DateTime.now();

    // 日期选择器
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now, // 禁止选择过去的日期
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    // 时间选择器
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (time == null) return;

    final DateTime selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    // 检查是否是过去的时间
    if (selectedDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('不能选择过去的时间')),
      );
      return;
    }

    setState(() {
      _activityTime = selectedDateTime;
    });
  }


  // 格式化日期显示
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // 提交表单
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // 打印提交数据，仅供调试
      print("活动名称: $_activityName");
      print("活动时间: $_activityTime");
      print("活动地点: ${_locationController.text}");
      print("最大参与人数: $_maxParticipants");
      print("活动详情: $_details");
      print("选择的图片数量: ${_selectedAssets.length}");

      // 可在此处调用接口或其他业务逻辑
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('活动发布成功！')),
      );
    }
  }

  // 构建活动名称输入框
  Widget _buildActivityName() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: '活动名称',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入活动名称';
        }
        return null;
      },
      onSaved: (value) {
        _activityName = value;
      },
    );
  }

  // 构建活动时间选择器
  Widget _buildActivityTime() {
    return GestureDetector(
      onTap: _selectActivityTime,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: const InputDecoration(
            labelText: '活动时间',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_activityTime == null) {
              return '请选择活动时间';
            }
            return null;
          },
          controller: TextEditingController(
            text: _activityTime == null ? '' : _formatDate(_activityTime!),
          ),
        ),
      ),
    );
  }

  // 构建最大参与人数输入框
  Widget _buildMaxParticipants() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: '最大参与人数',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入最大参与人数';
        }
        if (int.tryParse(value) == null) {
          return '请输入有效数字';
        }
        return null;
      },
      onSaved: (value) {
        _maxParticipants = int.tryParse(value!);
      },
    );
  }

  // 构建活动详情输入框（多行）
  Widget _buildDetails() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: '活动详情',
        border: OutlineInputBorder(),
      ),
      maxLines: 4,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入活动详情';
        }
        return null;
      },
      onSaved: (value) {
        _details = value;
      },
    );
  }

  // 构建图片选择器控件
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

  // 构建单个图片项
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

  // 使用 suffixIcon 实现固定的地图按钮，若需要自定义布局也可改为 Stack+Positioned 方式
  Widget _pickLocation() {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: '活动地点',
        prefixIcon: const Icon(Icons.location_on),
        suffixIcon: GestureDetector(
          onTap: _openMapPicker,
          child: Container(
            width: 120, // 可根据实际需求调整
            height: 55,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/map.png'),
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.grey, width: 0.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请选择活动地点';
        }
        return null;
      },
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
              _buildActivityName(),
              const SizedBox(height: 15),
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildActivityTime(),
              const SizedBox(height: 15),
              _pickLocation(),
              const SizedBox(height: 15),
              _buildMaxParticipants(),
              const SizedBox(height: 15),
              _buildDetails(),
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
