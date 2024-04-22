import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:better_player/better_player.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late PageController _pageController;
  List<dynamic> videoList = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchVideos(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _fetchVideos(BuildContext context) {
    http.get(Uri.parse('http://47.115.203.81:8080/douyin/feed/'))
        .then((response) {
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          videoList = jsonData['video_list'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请求失败，请检查网络'),
          ),
        );
      }
    });
  }

  void _likeVideo(int index) {
    // 向后端发送点赞请求
    // 实现逻辑...
  }

  void _commentVideo(int index) {
    // 向后端发送评论请求
    // 实现逻辑...
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox( // 使用Container来确保填充整个页面
        height: MediaQuery.of(context).size.height, // 设置容器高度为屏幕高度
        child: PageView.builder(
          controller: _pageController,
          itemCount: videoList.length,
          itemBuilder: (context, index) {
            final video = videoList[index];
            final dataSource = BetterPlayerDataSource.network(video['play_url']);
            double videoWidth = 2;
            double videoHeight = 9;
            // 发送 HTTP 请求以获取视频的元数据信息
            http.get(Uri.parse(video['play_url'])).then((response) {
              if (response.statusCode == 200) {
                Map<String, dynamic> videoMetadata = json.decode(response.body);
                videoWidth = videoMetadata['width'];
                videoHeight = videoMetadata['height'];
              }
            });

            final betterPlayerController = BetterPlayerController(
               BetterPlayerConfiguration(
                autoPlay: true,
                looping: true,
                aspectRatio: videoWidth/videoHeight,
                // fit: BoxFit.cover,
              ),
              betterPlayerDataSource: dataSource
            );
            return GestureDetector(
              child: Container(
                color: Colors.black, // 设置背景色为黑色
                child: Stack(
                  children: [
                    BetterPlayer(
                      controller: betterPlayerController,
                    ), // 放置视频播放器
                    Positioned(
                      top: 250,
                      right: 20,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(video['author']['avatar']),
                        radius: 25,
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 60,
                      left: 0,
                      child: Text(
                        "@${video['author']['name']}",
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: 45,
                      right: 60,
                      left:0,
                      child: Text(
                        video['title'],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Positioned(
                      top: 330,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              video['is_favorite'] == true
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: video['is_favorite'] == true ? Colors.red : Colors.white,
                            ),
                            onPressed: () {
                              _likeVideo(index);
                            },
                          ),
                          Text(
                            video['favorite_count'] != null ? video['favorite_count'].toString():'0',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.comment),
                            onPressed: () {
                              _commentVideo(index);
                            },
                          ),
                          Text(
                              video['comment_count'] != null ? video['comment_count'].toString() : '0',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(
                            height: 80,
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              _fetchVideos(this.context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}