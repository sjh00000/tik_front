import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final String token = ''; // 获取用户 token，可以通过 Provider 管理状态或其他方式获取
    final response = await http.get(Uri.parse('http://your-api-url/douyin/user/?token=$token'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        userInfo = jsonData['user'];
      });
    } else {
      // 处理错误
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('用户信息')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(userInfo['avatar'])),
          Text(userInfo['name']),
          Text(userInfo['signature']),
          // 其他用户信息展示
        ],
      ),
    );
  }
}