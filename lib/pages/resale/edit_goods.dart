import 'dart:io';

import 'package:client/core/model/goods.dart';
import 'package:client/util/toast.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../core/global.dart';
import '../../core/net/my_api.dart';
import '../../core/net/net.dart';
import '../../core/net/net_request.dart';
import '../../util/my_icon/my_icon.dart';
import '../../util/permission_request.dart';
import '../../util/upload.dart';
class EditGoods extends StatefulWidget {
  final int goodsId;
  const EditGoods({super.key, required this.goodsId});

  @override
  State<EditGoods> createState() => _EditGoodsState();
}

class _EditGoodsState extends State<EditGoods> {
  late Goods _goods;
  List<AssetEntity> images = [];
  final int _maxImgNum=9;
  late final TextEditingController _priceController ;
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  String? _selectedType;
  late PermissionUtil _permissionUtil;
  late Future<void> _initialEditFuture;
  @override
  void initState() {
    super.initState();
    _initialEditFuture = _initialEdit();

  }
  Future<void> _initialEdit() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _permissionUtil = PermissionUtil(context);
      } catch (e) {
        print('初始化权限工具失败: $e');
      }
    });
    var resGoods = await NetRequester.request(Apis.getGoodsByGoodsId(widget.goodsId));
    if (resGoods['code'] == '1'&& resGoods['data'] != null) {
      _goods = Goods.fromJson(resGoods['data']);
      _selectedType = _goods.type ?? GoodsType.idle;
      _nameController = TextEditingController(text: _goods.goodsName);
      _descController = TextEditingController(text: _goods.goodsDesc);
      _priceController = TextEditingController(
        text: _formatPrice(_goods.goodsPrice!),
      );
    }else{
      Toast.popToast('商品不存在！');
      Navigator.of(context).pop();
      throw '内容已经不在了';
    }
  }
  // 格式化价格（处理科学计数法、补全小数位）
  String _formatPrice(double price) {
    return price.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑商品'),
        actions: [
          TextButton(
            onPressed: () async {
              _sendHandler();
            },
            child: const Text('保存'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initialEditFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('加载失败'),
              );
            } else {
              return Stack(
                children: <Widget>[
                  _buildEditBody(),
                ],
              );
            }
          } else {
            return const Center(
              child: SpinKitRing(
                lineWidth: 3,
                color: Colors.blue,
              ),
            );
          }
        },
      ),
    );
  }
  Widget _buildEditBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
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
          const Text('交易类型:          ',style: TextStyle(fontSize: 16),),
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
          counterText: ' ',
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
          _goods.type = selectedValue; // 直接更新商品对象的 type 字段
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
    final imageList = _buildImageList();
    return Container(
        constraints: BoxConstraints(
            maxHeight: ScreenUtil().setWidth(_getHeight(imageList.length))
        ),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
        mainAxisSpacing: ScreenUtil().setWidth(18),
        crossAxisSpacing: ScreenUtil().setWidth(18),
        crossAxisCount: 3,
        children: List.generate(imageList.length, (index) {
          final item = imageList[index];
          if (item.isAddButton) {
            return _buildAdd();
          }
          return Stack(
            children: [
              _buildImageWidget(item),
              _buildDeleteButton(index),
            ],
          );
        }),
      )
    );
  }
  Widget _buildDeleteButton(int index) {
    return Positioned(
      right: 0,
      top: 0,
      child: GestureDetector(
        onTap: () => _handleDeleteImage(index),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: const Icon(Icons.close,
              color: Colors.white,
              size: 16
          ),
        ),
      ),
    );
  }
  void _handleDeleteImage(int index) {
    final imageList = _buildImageList();
    final item = imageList[index];
    setState(() {
      if (item.isNetwork) {
        _deleteNetworkImage(item.networkUrl!);
      } else {
        final networkCount = (_goods.image?.split('￥').length ?? 0);
        final localIndex = index - networkCount;
        if (localIndex >= 0 && localIndex < images.length) {
          images.removeAt(localIndex);
        }
      }
    });
  }
  void _deleteNetworkImage(String url) {
    final currentImages = _goods.image!.split('￥');
    currentImages.remove(url);
    _goods.image = currentImages.join('￥');
  }
  List<ImageItem> _buildImageList() {
    final List<ImageItem> result = [];

    final rawImages = _goods.image?.split('￥') ?? [];
    result.addAll(rawImages.where((e) => e.isNotEmpty).map(ImageItem.network));

    result.addAll(images.map((asset) => ImageItem.local(asset)));

    if (result.length < _maxImgNum) {
      result.add(ImageItem.addButton());
    }

    return result;
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
  //相册获取图片
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
      final currentCount = _buildImageList().where((e) => !e.isAddButton).length;
      final remaining = _maxImgNum - currentCount;
      List<AssetEntity>? resultList = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: remaining,
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
  Future<void> _sendHandler() async {
    var model=Global.profile;
    if (images.isNotEmpty) {
      Toast.popLoading('上传中...',20);
    }
    var flag = 1;
    String imageUrl='';
    _buildImageList().forEach((element) {
      if(element.isNetwork){
        imageUrl+='${element.networkUrl!}￥';
      }
    });
    for (final asset in images) {
      try {
        final String? fileName = asset.title;
        final String extension = fileName != null && fileName.contains('.')
            ? '.${fileName.split('.').last}' // 提取扩展名（如 ".JPG"）
            : '.jpg'; // 默认扩展名
        final String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String filename = '${model.user?.userId}_$timeStamp$extension';
        final File? file = await asset.file;
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
          // imageUrl += "/images/$filename￥";
          imageUrl+='/images/$filename￥';
          print(imageUrl);
        }
      } catch (e) {
        flag = 0;
        debugPrint('上传错误: $e');
      }
    }
    if(flag == 1){
      var result;
      //去除最后的￥
      imageUrl = imageUrl.substring(0,imageUrl.length-1);
      _goods.goodsName=_nameController.text;
      _goods.goodsDesc=_descController.text;
      _goods.goodsPrice=double.parse(_priceController.text);
      var map={
        'userId':Global.profile.user?.userId,
        'type':_selectedType,
        'goodsName':_goods.goodsName,
        'goodsDesc':_goods.goodsDesc,
        'goodsPrice':_goods.goodsPrice,
        'image':imageUrl,
        'goodsId':_goods.goodsId,
      };
      result = await NetRequester.request('/goods/edit',data: map);
      if(result['code'] =='1'){
        Toast.popToast('修改成功');
        Navigator.pop(context);
      }else{
        Toast.popToast('发布失败，请检查网络重试');
      }
    }
  }

  Widget _buildImageWidget(ImageItem item) {
    if (item.isNetwork) {
      return _buildNetworkImage(item.networkUrl!);
    } else {
      return _buildLocalImage(item.localAsset!);
    }
  }
  Widget _buildNetworkImage(String url) {
    return ExtendedImage.network(
      NetConfig.ip + url,
      fit: BoxFit.cover,
      shape: BoxShape.rectangle,
      border: Border.all(color: Colors.black12, width: 1),
      cache: true,
    );
  }
  Widget _buildLocalImage(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.hasData
              ? Image.memory(snapshot.data!, fit: BoxFit.cover)
              : _buildErrorPlaceholder();
        }
        return _buildLoadingPlaceholder();
      },
    );
  }
  Widget _buildLoadingPlaceholder() => Container(
    color: Colors.grey[200],
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _buildErrorPlaceholder() => Container(
    color: Colors.red[50],
    child: const Icon(Icons.error_outline, color: Colors.red),
  );
}
class ImageItem {
  final String? networkUrl; // 网络图片URL
  final AssetEntity? localAsset; // 本地相册资源
  final bool isAddButton; // 是否是添加按钮

  ImageItem.network(this.networkUrl)
      : localAsset = null,
        isAddButton = false;

  ImageItem.local(this.localAsset)
      : networkUrl = null,
        isAddButton = false;

  ImageItem.addButton()
      : networkUrl = null,
        localAsset = null,
        isAddButton = true;

  bool get isNetwork => networkUrl != null;
}