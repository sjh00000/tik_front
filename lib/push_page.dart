import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // 导入 image_picker 包
import 'package:http_parser/http_parser.dart'; // 导入 http_parser 包
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart'; // 导入 permission_handler 包

class PublishPage extends StatefulWidget {
  final String userToken;

  const PublishPage({Key? key, required this.userToken}) : super(key: key);

  @override
  State<PublishPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<PublishPage> {
  File? _videoFile;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  Future<void> _requestStoragePermission() async {
    final status = await Permission.manageExternalStorage.request();

    if (status.isDenied) {
      // 权限被拒绝
      if (kDebugMode) {
        print('权限被拒绝');
      }
    } else if (status.isGranted) {
      // 权限已授予
      if (kDebugMode) {
        print('权限已授予');
      }
    } else if (status.isPermanentlyDenied) {
      // 权限被永久拒绝
      if (kDebugMode) {
        print('权限被永久拒绝');
      }
      openAppSettings();
    }
  }

  Future<void> _selectVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _publish() async {
    if (_videoFile == null) {
      // 用户没有选择视频文件
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择视频文件')),
      );
      return;
    }

    final String token = widget.userToken;
    final String title = _titleController.text;

    // 构造multipart请求体
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://47.115.203.81:8080/douyin/publish/action/'),
    );
    // 添加表单字段
    request.fields['token'] = token;
    request.fields['title'] = title;
    // 添加文件
    request.files.add(
      await http.MultipartFile.fromPath(
        'data',
        _videoFile!.path,
        contentType: MediaType('video', 'mp4'), // 修改为你实际文件类型
      ),
    );

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      // 处理成功发布的逻辑
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('视频发布成功')),
      );
    } else {
      // 处理失败的逻辑
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('视频发布失败，请重试')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('上传视频')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _selectVideo,
              child: Text(_videoFile == null ? '选择视频文件' : '已选择视频'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '标题'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _publish,
              child: const Text('发布'),
            ),
          ],
        ),
      ),
    );
  }
}