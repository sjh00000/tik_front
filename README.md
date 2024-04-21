# 短视频前端页面及接口设计


## 用户注册登录页面

- 用户登录接口

  **Post:**/douyin/user/login/?username=sun&password=123456

  ```json
  {
      "status_code": 0,
      "user_id": 1,
      "token": "sun_123456"
  }
  ```

  

- 用户注册接口

  **Post:**/douyin/user/register/?username=cat1&password=123456

  ```json
  {
      "status_code": 0,
      "user_id": 3,
      "token": "cat1_123456"
  }
  ```

## 视频页面

- 视频流接口

  **Get:**/douyin/feed/

  ```json
  {
      "status_code": 0,
      "video_list": [
          {
              "id": 5,
              "author": {
                  "id": 1,
                  "name": "sun",
                  "avatar": "http://47.115.203.81:8080/douyin_image.jpg",
                  "background_image": "http://47.115.203.81:8080/douyin_image.jpg",
                  "signature": "sun",
                  "work_count": 2,
                  "token": "sun_123456"
              },
              "play_url": "http://47.115.203.81:8080/zip_1_VID_20240209_204258.mp4",
              "cover_url": "http://47.115.203.81:8080/zip_1_VID_20240209_204258.mp4_image.jpg",
              "title": "烟花"
          },
      ],
      "next_time": 1712664087
  }
  ```

  

- 点赞接口

  **Post:**/douyin/favorite/action/?token=sun_123456&video_id=1&action_type=1

  ```json
  {
      "status_code": 0
  }
  ```

  

- 评论接口

  **Post:**/douyin/comment/action/?token=sun_123456&action_type=1&video_id=1&comment_text=真好

  ```json
  {
      "status_code": 0,
      "comment": {
          "id": 1,
          "user": {
              "id": 1,
              "name": "sun",
              "avatar": "http://47.115.203.81:8080/douyin_image.jpg",
              "background_image": "http://47.115.203.81:8080/douyin_image.jpg",
              "signature": "sun",
              "work_count": 2,
              "token": "sun_123456"
          },
          "content": "真好",
          "create_date": "04-09"
      }
  }
  ```

  **删除评论**：/douyin/comment/action/?token=sun_123456&action_type=2&video_id=1&comment_id=1

  ```json
  {
      "status_code": 0,
      "comment": {
          "user": {}
      }
  }
  ```

  

- 评论列表接口

  **Post:**/douyin/comment/list/?token=sun_123456&video_id=1

  ```json
  {
      "status_code": 0,
      "comment_list": [
          {
              "id": 4,
              "user": {
                  "id": 1,
                  "name": "sun",
                  "avatar": "http://47.115.203.81:8080/douyin_image.jpg",
                  "background_image": "http://47.115.203.81:8080/douyin_image.jpg",
                  "signature": "sun",
                  "total_favorited": 1,
                  "work_count": 2,
                  "favorite_count": 1,
                  "token": "sun_123456"
              },
              "content": "真好",
              "create_date": "04-09"
          }
      ]
  }
  ```

  

## 投稿页面

- 投稿接口

  **Post:**/douyin/publish/action/

  ​	Body参数:form-data:token:,title:

  ```json
  {
      "status_code": 1,
      "status_msg": "http: no such file"
  }
  ```

  

## 用户信息页面

- 用户信息接口

  **Get:**/douyin/user/?token=sun_123456

  ```json
  {
      "status_code": 0,
      "user": {
          "id": 1,
          "name": "sun",
          "avatar": "http://47.115.203.81:8080/douyin_image.jpg",
          "background_image": "http://47.115.203.81:8080/douyin_image.jpg",
          "signature": "sun",
          "work_count": 2,
          "token": "sun_123456"
      }
  }
  ```

  

- 发布列表接口

  **Get:**/douyin/publish/list/?token=sun_123456&user_id=1

  ```json
  {
      "status_code": 0,
      "video_list": [
          {
              "id": 1,
              "author": {
                  "id": 1,
                  "name": "sun",
                  "avatar": "http://47.115.203.81:8080/douyin_image.jpg",
                  "background_image": "http://47.115.203.81:8080/douyin_image.jpg",
                  "signature": "sun",
                  "work_count": 2,
                  "token": "sun_123456"
              },
              "play_url": "http://47.115.203.81:8080/1_video.mp4",
              "cover_url": "http://47.115.203.81:8080/douyin_image.jpg",
              "title": "demo"
          },
      ]
  }
  ```

  

- 喜欢列表接口

  **Get:**/douyin/favorite/list/?token=sun_123456

  ```json
  {
      "status_code": 0,
      "favorite_list": [
          {
              "id": 1,
              "author": {
                  "id": 1,
                  "name": "sun",
                  "avatar": "http://47.115.203.81:8080/douyin_image.jpg",
                  "background_image": "http://47.115.203.81:8080/douyin_image.jpg",
                  "signature": "sun",
                  "total_favorited": 1,
                  "work_count": 2,
                  "favorite_count": 1,
                  "token": "sun_123456"
              },
              "play_url": "http://47.115.203.81:8080/1_video.mp4",
              "cover_url": "http://47.115.203.81:8080/douyin_image.jpg",
              "favorite_count": 1,
              "is_favorite": true,
              "title": "demo"
          }
      ]
  }
  ```

  
