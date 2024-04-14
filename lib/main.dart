import 'package:flutter/material.dart';
import 'package:untitled/push_page.dart';
import 'package:untitled/user_page.dart';
import 'login_page.dart';
import 'video_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(title: 'FlutterHome Page'),
      routes: {
        '/video': (context) => const VideoPage(),
        '/publish': (context) => PublishPage(),
        '/user_info': (context) => const UserInfoPage(),
      },
    );
  }
}