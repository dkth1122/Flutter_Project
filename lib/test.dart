import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController _pageController;
  int _currentPage = 0;
  int _pageCount = 3; // 전체 페이지 수

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _pageController.addListener(() {
      if (_pageController.page == _pageCount - 1) {
        // 페이지가 끝 페이지에 도달하면 첫 페이지로 되감음
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('무한 페이지 애니메이션'),
      ),
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          Container(color: Colors.blue, child: Center(child: Text('페이지 1'))),
          Container(color: Colors.red, child: Center(child: Text('페이지 2'))),
          Container(color: Colors.green, child: Center(child: Text('페이지 3'))),
        ],
      ),
    );
  }
}