import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late int userId=0;
  late String userToken="";

  @override
  void initState(){
    super.initState();
  }
  Future<void> _login() async {
    final String username = usernameController.text;
    final String password = passwordController.text;
    final response = await http.post(
      Uri.parse('http://47.115.203.81:8080/douyin/user/login/?username=$username&password=$password'),
    );
    final jsonData = jsonDecode(response.body);
    userId=int.parse(jsonData['user_id']??'0');
    userToken = jsonData['token'].toString();
    debugPrint('token是$userToken\nuser_id是$userId');

    // 处理登录响应，根据需要进行跳转或提示
    if (response.statusCode == 200) {
      // 登录成功，使用全局键执行页面导航
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => MyHomePage(userId,userToken)),
      );
    } else {
      // 登录失败，显示错误信息
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('登录失败，请检查用户名和密码')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: widget.title,
      home: Scaffold(
        appBar: AppBar(title: const Text('登录')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(controller: usernameController, decoration: const InputDecoration(labelText: '用户名')),
              TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: '密码')),
              const SizedBox(height: 32.0),
              ElevatedButton(onPressed: _login, child: const Text('登录')),
            ],
          ),
        ),
      ),
    );
  }
}