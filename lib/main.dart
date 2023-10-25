import 'package:flutter/material.dart';
import 'dart:async';

import 'package:project_flutter/product.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '메인',
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    // 페이지 컨트롤러 초기화
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.8,
    );

    // 타이머를 사용하여 자동 슬라이드 구현
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
        title: Text("용채"),
      ),
      body: Center(
        child: ListView(
          children: [
            Container(
              height: 200, // 슬라이드 높이 설정
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: 100,
                    child: Container(
                      color: Colors.lightBlue,
                      margin: EdgeInsets.symmetric(horizontal: 10.0), // 슬라이드 간 간격
                    ),
                  );
                },
                itemCount: 3, // 슬라이드 개수
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Product()),
                );
              },
              icon: Icon(Icons.add_circle_outline),
            )
          ],
        ),
      ),
    );
  }
}