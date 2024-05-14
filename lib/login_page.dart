import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'registration_page.dart'; // 导入注册页面

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
  late String userId = '0';
  late String userToken = "";
  bool _rememberMe = false; // 记住密码状态

  @override
  void initState() {
    super.initState();
    _loadLoginState(); // 加载记住密码状态
  }

  // 加载记住密码状态
  void _loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        usernameController.text = prefs.getString('username') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  // 保存记住密码状态
  void _saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      prefs.setString('username', usernameController.text);
      prefs.setString('password', passwordController.text);
    } else {
      prefs.remove('username'); // 移除用户名
      prefs.remove('password'); // 移除密码
    }
  }

  //登录
  Future<void> _login() async {
    final String username = usernameController.text;
    final String password = passwordController.text;
    final response = await http.post(
      Uri.parse('http://47.115.203.81:8080/douyin/user/login/?username=$username&password=$password'),
    );
    _handleResponse(response);
  }

  //注册
  void _register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage()), // 跳转到注册页面
    );
  }

  void _handleResponse(http.Response response) {
    final jsonData = jsonDecode(response.body);
    final statusCode = (jsonData['status_code'] ?? '1').toString(); // 默认值为 1，表示失败
    final userId = (jsonData['user_id'] ?? '0').toString(); // 转换为字符串形式
    userToken = jsonData['token'].toString();
    debugPrint('token是$userToken\nuser_id是$userId');

    if (statusCode == '0') {
      // 注册或登录成功，进行页面导航
      _saveLoginState(); // 只有在登录成功后保存记住密码状态
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => MyHomePage(int.parse(userId), userToken: userToken,)),
      );
    } else {
      // 注册或登录失败，显示相应的提示信息
      final String errorMessage = jsonData['message'] ?? '账号或密码输入不正确，请重新再试！';
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text(errorMessage)),
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
              TextField(controller: usernameController, decoration: const InputDecoration(labelText: '账号')),
              TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: '密码')),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                        if (!_rememberMe) {
                          // 如果取消记住密码，立即清除保存的密码信息
                          _saveLoginState();
                        }
                      });
                    },
                  ),
                  const Text('记住密码'),
                ],
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(onPressed: _login, child: const Text('登录')),
              const SizedBox(height: 16.0),
              ElevatedButton(onPressed: _register, child: const Text('注册')),
            ],
          ),
        ),
      ),
    );
  }
}