import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  List<dynamic> videoList = [];

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    final response = await http.get(Uri.parse('http://your-api-url/douyin/feed/'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        videoList = jsonData['video_list'];
      });
    } else {
      // 处理错误
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('视频')),
      body: ListView.builder(
        itemCount: videoList.length,
        itemBuilder: (context, index) {
          final video = videoList[index];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(video['author']['avatar'])),
            title: Text(video['title']),
            subtitle: Text(video['author']['name']),
            onTap: () {
              // 处理点击事件，例如跳转到视频详情页
            },
          );
        },
      ),
    );
  }
}