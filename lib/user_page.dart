import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserInfoPage extends StatefulWidget {
  final String userToken;
  const UserInfoPage({Key? key, required this.userToken}) : super(key: key);

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Map<String, dynamic> userInfo = {};
  List<Map<String, dynamic>> publishList = [];
  List<Map<String, dynamic>> likeList = [];
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchPublishList();
    _fetchLikeList();
  }

  Future<void> _fetchUserInfo() async {
    final response = await http.get(Uri.parse('http://47.115.203.81:8080/douyin/user/?token=${widget.userToken}'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        userInfo = jsonData['user'];
      });
    } else {
      debugPrint('请求失败');
    }
  }

  Future<void> _fetchPublishList() async {
    await _fetchUserInfo(); // 等待 _fetchUserInfo 方法完成

    if (userInfo.isEmpty || userInfo['id'] == null) {
      // 如果 userInfo 为空或者 userInfo['id'] 为 null，则不执行请求
      debugPrint('userInfo 尚未设置或者用户 ID 为空');
      return;
    }

    final response = await http.get(Uri.parse('http://47.115.203.81:8080/douyin/publish/list/?token=${widget.userToken}&user_id=${userInfo['id']}'));

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        List<Map<String, dynamic>> videoList = List<Map<String, dynamic>>.from(jsonData['video_list']);
        setState(() {
          publishList = videoList;
        });
      } catch (e) {
        debugPrint('解析 JSON 数据时出现异常: $e');
      }
    } else {
      debugPrint('请求失败: ${response.statusCode}');
    }
  }

  Future<void> _fetchLikeList() async {
    final response = await http.get(Uri.parse('http://47.115.203.81:8080/douyin/favorite/list/?token=${widget.userToken}'));

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        List<Map<String, dynamic>> favoriteList = List<Map<String, dynamic>>.from(jsonData['favorite_list']);
        setState(() {
          likeList = favoriteList;
        });
      }catch (e) {
        debugPrint('解析 JSON 数据时出现异常: $e');
      }
    } else {
      debugPrint('请求失败: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户信息')),
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! > 0) {
            // 用户向右滑动
            if (_currentPageIndex > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            }
          } else if (details.primaryVelocity! < 0) {
            // 用户向左滑动
            if (_currentPageIndex < 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            }
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息部分
              Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    userInfo.containsKey('background_image') && userInfo['background_image'] != null
                        ? Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(userInfo['background_image']),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.1),
                            BlendMode.dstATop,
                          ),
                        ),
                      ),
                    )
                        : const SizedBox(),
                    userInfo['avatar'] != null && userInfo['avatar'] != ''
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(userInfo['avatar']),
                      radius: 40,
                    )
                        : const SizedBox(),
                    const SizedBox(height: 10),
                    Text(
                      '${userInfo['name'] ?? ''}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '签名: ${userInfo['signature'] ?? ''}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '作品数: ${userInfo.containsKey('work_count') ? userInfo['work_count'] : '0'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    // 添加其他用户信息字段
                  ],
                ),
              ),
              const Divider(color: Colors.black, thickness: 2.0),

              // 添加黑线上方的标题行
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '发布列表',
                      style: TextStyle(
                        fontWeight: _currentPageIndex == 0 ? FontWeight.bold : FontWeight.normal,
                        color: _currentPageIndex == 0 ? Colors.black : Colors.grey,
                      ),
                    ),
                    Text(
                      '喜欢列表',
                      style: TextStyle(
                        fontWeight: _currentPageIndex == 1 ? FontWeight.bold : FontWeight.normal,
                        color: _currentPageIndex == 1 ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // 列表部分
              SizedBox(
                height: 150, // 限制列表的高度，以便在页面切换时滚动
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  children: [
                    // 发布列表
                    // 发布列表
                    ListView.builder(
                      itemCount: publishList.length,
                      itemBuilder: (context, index) {
                        // 获取当前视频信息
                        Map<String, dynamic> videoInfo = publishList[index];
                        // 检查视频信息是否包含 "cover_url" 和 "title" 属性
                        if (videoInfo.containsKey('cover_url') && videoInfo.containsKey('title')) {
                          // 构建发布列表项
                          return ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(videoInfo['cover_url']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text('发布顺序 ${index + 1}'),
                            subtitle: Text('标题: ${videoInfo['title']}'),
                            // 添加其他发布信息字段
                          );
                        } else {
                          // 如果视频信息不包含所需属性，则返回空容器
                          return Container();
                        }
                      },
                    ),
                    // 喜欢列表
                    ListView.builder(
                      itemCount: likeList.length,
                      itemBuilder: (context, index) {
                        // 获取当前视频信息
                        Map<String, dynamic> videoInfo = likeList[index];
                        // 检查视频信息是否包含 "cover_url" 和 "title" 属性
                        if (videoInfo.containsKey('cover_url') && videoInfo.containsKey('title')) {
                          // 构建喜欢列表项
                          return ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(videoInfo['cover_url']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text('喜欢顺序 ${index + 1}'),
                            subtitle: Text('标题: ${videoInfo['title']}'),
                            // 添加其他发布信息字段
                          );
                        } else {
                          // 如果视频信息不包含所需属性，则返回空容器
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}