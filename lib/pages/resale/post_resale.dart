import 'dart:io';

import 'package:client/core/global.dart';
import 'package:client/core/model/goods.dart';
import 'package:client/util/my_icon/my_icon.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../core/model/user_model.dart';
import '../../core/net/net_request.dart';
import '../../util/permission_request.dart';
import '../../util/toast.dart';
import '../../util/upload.dart';
class SendResalePage extends StatefulWidget {

  const SendResalePage({super.key});

  @override
  State<SendResalePage> createState() => _SendResalePageState();
}

class _SendResalePageState extends State<SendResalePage> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  late final Goods? goods;

  String? _selectedType;
  List<AssetEntity> images = [];
   int _maxImgNum=9;
  late PermissionUtil _permissionUtil;
  @override
  void initState() {
    super.initState();
    goods = Goods();
    _selectedType = goods?.type ?? GoodsType.idle;
    goods?.type ??= GoodsType.idle;
    _initializePermissionUtil();
    _priceFocusNode.addListener(() {
      if (!_priceFocusNode.hasFocus) _autoCompleteDecimal();
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _nameFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializePermissionUtil() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _permissionUtil = PermissionUtil(context);
      } catch (e) {
        print('初始化权限工具失败: $e');
      }
    });
  }
  // 自动补全小数点后两位
  void _autoCompleteDecimal() {
    String text = _priceController.text;
    if (text.isEmpty) return;

    if (!text.contains('.')) {
      _priceController.text = '$text.00';
    } else {
      List<String> parts = text.split('.');
      if (parts[1].length == 1) {
        _priceController.text = '${parts[0]}.${parts[1]}0';
      } else if (parts[1].isEmpty) {
        _priceController.text = '${parts[0]}.00';
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二手交易'),
        actions: <Widget>[
          Consumer<UserModel>(builder: (BuildContext context, model, _) {
            return IconButton(
              icon: const Icon(MyIcons.send),
              onPressed: () {
                _sendHandler(model);
              },
            );
          })
        ],
      ),
      body: _buildResaleBody(),
    );
  }
  Widget _buildResaleBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          _buildGoodsType(),
          _buildGoodsName(),
          _buildGoodsDesc(),
          _buildGoodsPrice(),
          _buildGoodsImages(),
        ],
      ),
    );
  }
  _buildGoodsType() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          const Text('类型:    ',style: TextStyle(fontSize: 16),),
          Expanded(
            child: _buildRadioTile('闲置', GoodsType.idle),
          ),
          Expanded(
            child: _buildRadioTile('求购', GoodsType.wanted),
          ),
        ],
      ),
    );
  }
  Widget _buildGoodsName() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: TextFormField(
        controller: _nameController,
        focusNode: _nameFocusNode,
        decoration: InputDecoration(
          labelText: '商品名称',
          hintText: '例: 九成新 iPhone 13 Pro',
          prefixIcon: const Icon(Icons.title),
          counterText: ' ', // 预留空间给错误提示
          suffixIcon: _buildClearButton(), // 清空按钮
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        maxLength: 30, // 最大字符数
        textCapitalization: TextCapitalization.words, // 单词首字母大写
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'[\\/<>{}[\]~]')), // 过滤危险符号
          TextInputFormatter.withFunction((oldValue, newValue) {
            // 自动替换全角字符为半角
            return newValue.copyWith(
                text: newValue.text
                    .replaceAll('＃', ',')
                    .replaceAll('．', '.')
            );
          }),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) return '名称不能为空';
          if (value.trim().length < 2) return '至少需要2个有效字符';
          if (value.length > 30) return '名称不能超过30个字符';
          if (RegExp(r'\d{6,}').hasMatch(value)) return '避免纯数字编号';
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction, // 实时验证
        onChanged: (value) => _autoFormatName(value), // 自动格式化
      ),
    );
  }

  Widget _buildGoodsDesc() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: TextFormField( // 改用 TextFormField
        controller: _descController,
        decoration: InputDecoration(
          labelText: '商品描述',
          hintText: '详细描述商品状况或求购要求...（最多255字）',
          prefixIcon: const Icon(Icons.description),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
          alignLabelWithHint: true,
          counterText: ' ', // 预留错误提示空间
          suffix: _buildCharCounter(), // 显示字数统计
        ),
        keyboardType: TextInputType.multiline,
        maxLength: 255, // 关键点：严格限制字符数
        maxLines: 5, // 设置最大行数防止界面过度膨胀
        minLines: 3,
        textInputAction: TextInputAction.newline,
        style: const TextStyle(fontSize: 16),
        // 输入内容过滤
        inputFormatters: [
          TextInputFormatter.withFunction((oldValue, newValue) {
            // 处理粘贴超长内容自动截断
            if (newValue.text.length > 255) {
              return TextEditingValue(
                text: newValue.text.substring(0, 255),
                selection: const TextSelection.collapsed(offset: 255),
              );
            }
            return newValue;
          }),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) return '描述不能为空';
          if (value.length > 255) return '描述不能超过255个字符';
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildGoodsPrice() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: TextFormField(
        controller: _priceController,
        focusNode: _priceFocusNode,
        decoration: InputDecoration(
          labelText: '价格 (元)',
          hintText: '例: 99.99',
          prefixIcon: const Icon(Icons.attach_money),
          suffixText: '元',
          errorStyle: const TextStyle(color: Colors.red),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // 允许数字和最多两位小数
          TextInputFormatter.withFunction((oldValue, newValue) {
            // 禁止输入多个小数点
            if (newValue.text.split('.').length > 2) return oldValue;
            // 禁止负数
            if (newValue.text.startsWith('-')) return oldValue;
            return newValue;
          }),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) return '请输入价格';
          final numValue = double.tryParse(value);
          if (numValue == null) return '请输入有效数字';
          if (numValue <= 0) return '价格必须大于0元';
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction, // 实时验证
      ),
    );
  }

  _buildGoodsImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
          child: const Align(
            alignment: Alignment.centerLeft, // 左对齐 + 垂直居中
            child: Text(
              '添加图片',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        buildGridView(),
      ],
    );
  }
// 自动格式化名称
  void _autoFormatName(String value) {
    final newText = value
        .replaceAll(RegExp(r'\s{2,}'), ' ') // 多个空格转单个
        .trimLeft(); // 去除左侧空格

    if (newText != value) {
      _nameController.value = _nameController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }
  // 清空按钮
  Widget _buildClearButton() {
    return IconButton(
      icon: const Icon(Icons.clear, size: 18),
      onPressed: () => _nameController.clear(),
      splashRadius: 20, // 减小点击涟漪范围
    );
  }
  // 构建字符计数器
  Widget _buildCharCounter() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _descController,
      builder: (context, value, _) {
        final length = value.text.length;
        return Text(
          '$length/255',
          style: TextStyle(
            color: length > 255 ? Colors.red : Colors.grey,
            fontSize: 12,
          ),
        );
      },
    );
  }
  Widget _buildRadioTile(String title, String value) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: _selectedType,
      activeColor: Colors.blue,
      onChanged: (String? selectedValue) {
        setState(() {
          _selectedType = selectedValue; // 更新选中状态
          goods?.type = selectedValue; // 直接更新商品对象的 type 字段
        });
      },
    );
  }
  num _getHeight(int length) {
    if(length<3){
      return 130;
    }else if(length <6){
      return 240;
    }else{
      return 350;
    }
  }
  Widget deleteButton(int index) => Positioned(
    right: 0,
    top: 0,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          images.removeAt(index);
        });
      },
      child: Icon(
        Icons.dangerous,
        size: ScreenUtil().setWidth(25.0),
        color: Colors.black54,
      ),
    ),
  );
  Widget buildGridView() {
    return Container(
      constraints: BoxConstraints(
          maxHeight: ScreenUtil().setWidth(_getHeight(images.length))
      ),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
        mainAxisSpacing: ScreenUtil().setWidth(18),
        crossAxisSpacing: ScreenUtil().setWidth(18),
        crossAxisCount: 3,
        children:
        List.generate(images.length < 9 ? images.length + 1 : 9, (index) {
          if (images.length < 9 && index == images.length) {
            return _buildAdd();
          } else {
            AssetEntity asset = images[index];
            return Stack(
              children: <Widget>[
                FutureBuilder<Uint8List?>(
                  future: asset.thumbnailDataWithSize(
                    const ThumbnailSize(300, 300),
                    quality: 80,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      return Image.memory(snapshot.data!);
                    } else {
                      return const SizedBox(height: 300, width: 300);
                    }
                  },
                ),
                deleteButton(index)
              ],
            );
          }
        }),
      ),
    );
  }
  Widget _buildAdd() {
    return Container(
      color: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: loadAssets,
        child: Icon(
          MyIcons.plus,
          size: ScreenUtil().setWidth(50),
          color: Colors.grey,
        ),
      ),
    );
  }
  Future<void> loadAssets() async {
    try {
      // 检查并请求权限
      Permission permission;
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        permission = Permission.storage;
      } else {
        permission = Permission.photos;
      }
      await _permissionUtil.checkPermission(permission);

      // 如果权限已授予，继续选择图片
      List<AssetEntity>? resultList = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: _maxImgNum,
          selectedAssets: images,
          requestType: RequestType.image,
          gridThumbnailSize: const ThumbnailSize.square(80),
          previewThumbnailSize: const ThumbnailSize.square(150),
        ),
      );

      if (!mounted || resultList == null) return;
      setState(() => images = resultList);
    } catch (e) {
      print('图片选择错误: $e');
      Toast.popToast('图片选择错误，请重试');
    }
  }

  Future<void> _sendHandler(UserModel model) async {
    if(images.isEmpty){
      Toast.popToast('请选择图片');
      return;
    }
    if (images.isNotEmpty) {
      Toast.popLoading('上传中...',20);
    }
    var flag = 1;
    String imageUrl='';
    for (final asset in images) {
      try {
        final String? fileName = asset.title; // 获取带扩展名的文件名（如 "IMG_1234.JPG"）
        final String extension = fileName != null && fileName.contains('.')
            ? '.${fileName.split('.').last}' // 提取扩展名（如 ".JPG"）
            : '.jpg'; // 默认扩展名
        final String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String filename = '${model.user.userId}_$timeStamp$extension';
        // 3. 获取文件二进制数据
        final File? file = await asset.file; // 获取原图文件
        if (file == null) {
          Toast.popToast('文件读取失败');
          flag = 0;
          continue;
        }
        final Uint8List fileData = await file.readAsBytes();
        // 4. 上传文件
        final res = await UpLoad.upLoad(fileData, filename);
        if(res==1){
          print('picture upload success');
        }
        if (res == 0) {
          Toast.popToast('上传失败请重试');
          flag = 0;
        } else {
          imageUrl += "/images/$filename￥";
        }
      } catch (e) {
        flag = 0;
        debugPrint('上传错误: $e');
      }
    }
    if(flag == 1){
      var now = DateTime.now();
      var result;

      goods?.goodsName=_nameController.text;
      goods?.goodsDesc=_descController.text;
      goods?.goodsPrice=double.parse(_priceController.text);
      if(images.isNotEmpty){
        imageUrl=imageUrl.substring(0,imageUrl.length-1);
      }
      var map={
        'userId':Global.profile.user?.userId,
        'type':_selectedType,
        'goodsName':goods?.goodsName,
        'goodsDesc':goods?.goodsDesc,
        'goodsPrice':goods?.goodsPrice,
        'image':imageUrl,
        'date':now.toString().substring(0,19),
      };
      result = await NetRequester.request('/goods/addResale',data: map);
      // result = await NetRequester.request('/goods/addResale',data: map1);
      if(result['code'] =='1'){
        Toast.popToast('发布成功');
        Navigator.pop(context);
      }else{
        Toast.popToast('发布失败，请检查网络重试');
      }
    }
  }
}
