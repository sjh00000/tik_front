import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/video_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required String title});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Future<void> _login(BuildContext context) async {
    final String username = usernameController.text;
    final String password = passwordController.text;
    final response = await http.post(
      Uri.parse('http://your-api-url/douyin/user/login/?username=$username&password=$password'),
    );
    // 处理登录响应，根据需要进行跳转或提示
    if (response.statusCode == 200) {
      // 登录成功，跳转到视频页面
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>VideoPage()),
      );
    } else {
      // 登录失败，显示错误信息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录失败，请检查用户名和密码')),
      );
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
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
            ElevatedButton(onPressed: () => _login(context), child: const Text('登录')),
          ],
        ),
      ),
    );
  }
}
