import 'package:flutter/material.dart';

class PortfolioItem {
  final String title;
  final String description;
  final String thumbnailUrl; // 섬네일 이미지 URL 추가

  PortfolioItem(this.title, this.description, this.thumbnailUrl);
}

class Portfolio extends StatefulWidget {
  @override
  _PortfolioState createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  int currentIndex = 0; // 현재 선택된 포트폴리오 항목 인덱스

  final List<PortfolioItem> portfolioItems = [
    PortfolioItem('프로젝트 1', '프로젝트 1의 설명', 'assets/dog1.png'),
    PortfolioItem('프로젝트 2', '프로젝트 2의 설명', 'assets/dog2.png'),
    PortfolioItem('프로젝트 3', '프로젝트 3의 설명', 'assets/dog3.png'),
    // 다른 포트폴리오 항목 추가
  ];

  void changePortfolioItem(int newIndex) {
    setState(() {
      currentIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('나의 포트폴리오'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Display a list of the expert's projects and works
              Container(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '포트폴리오 항목',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                children: <Widget>[
                  Image.network(
                    portfolioItems[currentIndex].thumbnailUrl,
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 10),
                  Text(
                    portfolioItems[currentIndex].title,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    portfolioItems[currentIndex].description,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      if (currentIndex > 0) {
                        changePortfolioItem(currentIndex - 1);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (currentIndex < portfolioItems.length - 1) {
                        changePortfolioItem(currentIndex + 1);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}