import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login_page.dart'; // 导入登录页面

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? validateUsername(String? value) {
    // 账号不能含有特殊字符
    final RegExp regex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!regex.hasMatch(value!)) {
      return '账号只能包含大小写字母和数字';
    }
    return null;
  }

  String? validatePassword(String? value) {
    // 密码至少包含字母和数字两种字符且长度大于6位
    final RegExp regex = RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$');
    if (!regex.hasMatch(value!)) {
      return '密码至少需要包含字母和数字，并且长度≥6位';
    }
    return null;
  }

  Future<void> _register() async {
    final String username = usernameController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密码和确认密码不一致，请重新输入')),
      );
      return;
    }

    final String? usernameError = validateUsername(username);
    final String? passwordError = validatePassword(password);

    if (usernameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(usernameError)),
      );
      return;
    }

    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError)),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://47.115.203.81:8080/douyin/user/register/?username=$username&password=$password'),
    );
    _handleResponse(response);
  }

  void _handleResponse(http.Response response) {
    final jsonData = jsonDecode(response.body);
    final statusCode = (jsonData['status_code'] ?? '1').toString(); // 默认值为 1，表示失败
    final userId = (jsonData['user_id'] ?? '0').toString(); // 转换为字符串形式
    final userToken = jsonData['token'].toString();
    debugPrint('token是$userToken\nuser_id是$userId');

    if (statusCode == '0') {
      // 注册成功，可以进行相应的操作，比如跳转到登录页面
      Navigator.pop(context); // 返回到上一个页面
    } else {
      // 注册失败，显示相应的提示信息
      final String errorMessage = jsonData['message'] ?? '该账号已存在，请重新输入新的账号名！';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: '账号'),
              validator: validateUsername,
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密码'),
              validator: validatePassword,
            ),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '确认密码'),
              validator: (value) {
                if (value != passwordController.text) {
                  return '确认密码不一致，请重新输入';
                }
                return null;
              },
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(onPressed: _register, child: const Text('注册')),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage(title: '登录')), // 跳转到登录页面
                );
              },
              child: const Text('返回登录'),
            ),
          ],
        ),
      ),
    );
  }
}