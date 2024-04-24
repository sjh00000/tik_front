import 'package:flutter/material.dart';
import 'package:untitled/push_page.dart';
import 'package:untitled/user_page.dart';
import 'package:untitled/video_page.dart';

class MyHomePage extends StatefulWidget {
  final int userId;
  final String userToken;
  const MyHomePage(this.userId,{super.key, required this.userToken});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late String userToken = '';
  late List<Widget> _widgetOptions=<Widget>[];

  @override
  void initState(){
    super.initState();
    userToken=widget.userToken;
    _widgetOptions = <Widget>[
      VideoPage(userToken: userToken),
      UserInfoPage(userToken: widget.userToken),
      PublishPage(userToken: widget.userToken),
    ];
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Publish',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}