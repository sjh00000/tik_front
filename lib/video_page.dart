import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:better_player/better_player.dart';

class VideoPage extends StatefulWidget {
  final String userToken;
  const VideoPage({Key? key, required this.userToken}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late PageController _pageController;
  List<dynamic> videoList = [];
  late String userToken='';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchVideos(context);
    userToken=widget.userToken;
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

  Future<void> _likeVideo(String index,bool? favorited) async {
    // 向后端发送点赞请求
    if(favorited == true){
      final response =await http.post(Uri.parse(
          'http://47.115.203.81:8080/douyin/favorite/action/?token=$userToken&video_id=$index&action_type=2'));
      if(response.statusCode == 200){
        setState(() {
          _fetchVideos(context);
        });
      }else{
        debugPrint('请求失败');
      }
    }else{
      final response =await http.post(Uri.parse(
          'http://47.115.203.81:8080/douyin/favorite/action/?token=$userToken&video_id=$index&action_type=1'));
      if(response.statusCode == 200){
        setState(() {
          _fetchVideos(context);
        });
      }else{
        debugPrint('请求失败');
      }
    }
  }

  Future<void> _fetchComments(String videoId) async {
    final response = await http.get(Uri.parse(
        'http://47.115.203.81:8080/douyin/comment/list/?token=$userToken&video_id=$videoId'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<dynamic> commentList = jsonData['comment_list']??[];
      // 显示评论区
      _showCommentsModal(commentList,videoId);
    } else {
      debugPrint('请求失败，请检查网络');
    }
  }

  void _showCommentsModal(List<dynamic> commentList,String videoId) {
      showModalBottomSheet(
      isDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '评论区',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: commentList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final comment = commentList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(comment['user']['avatar']),
                      ),
                      title: Text(comment['user']['name']),
                      subtitle: Text(comment['content']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // 执行删除评论操作
                          _deleteComment(comment['id'],videoId);
                        },
                      ),
                    );
                  },
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: '输入评论',
                ),
                onFieldSubmitted: (value) {
                  // 执行发送评论操作
                  _postComment(value,videoId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _postComment(String commentText,String videoId) async {
    final response = await http.post(Uri.parse(
        'http://47.115.203.81:8080/douyin/comment/action/?token=$userToken&action_type=1&video_id=$videoId&comment_text=$commentText'));
    if (response.statusCode == 200) {
      // 发送成功，刷新评论列表
      Navigator.of(context).pop();
      _fetchComments(videoId);
    } else {
      debugPrint('发送评论失败');
    }
  }

  Future<void> _deleteComment(int commentId,String videoId) async {
    final response = await http.post(Uri.parse(
        'http://47.115.203.81:8080/douyin/comment/action/?token=$userToken&action_type=2&video_id=$videoId&comment_id=$commentId'));
    if (response.statusCode == 200) {
      // 删除成功，刷新评论列表
      Navigator.of(context).pop();
      _fetchComments(videoId);
    } else {
      debugPrint('删除评论失败');
    }
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
            final videoId = video['id'].toString();
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
                              _likeVideo(videoId,video['is_favorite']);
                            },
                          ),
                          Text(
                            video['favorite_count'] != null ? video['favorite_count'].toString():'0',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(
                                Icons.comment,
                                color: Colors.white,
                            ),
                            onPressed: () {
                              _fetchComments(videoId);
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
                            icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                            ),
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