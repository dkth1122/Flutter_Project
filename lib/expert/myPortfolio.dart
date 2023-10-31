import 'package:flutter/material.dart';
import 'package:project_flutter/expert/addPortfolio.dart';

class PortfolioItem {
  final String title;
  final String description;
  final String thumbnailUrl; // Thumbnail image URL

  PortfolioItem(this.title, this.description, this.thumbnailUrl);
}

class Portfolio extends StatelessWidget {
  final List<PortfolioItem> portfolioItems = [
    PortfolioItem('Project 1', 'Description of Project 1', 'assets/dog1.PNG'),
    PortfolioItem('Project 2', 'Description of Project 2', 'assets/dog2.PNG'),
    PortfolioItem('Project 3', 'Description of Project 3', 'assets/dog3.PNG'),
    // Add more portfolio items
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('포트폴리오'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Add your code to handle the "포트폴리오 등록하기" button press
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddPortfolio()));
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: portfolioItems.length,
          itemBuilder: (context, index) {
            final item = portfolioItems[index];
            return Card(
              child: ListTile(
                leading: Image.asset(
                  item.thumbnailUrl,
                  width: 100,
                  height: 100,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(item.description),
                onTap: () {
                  _showPortfolioDetailDialog(context, item);
                },
              ),
            );
          },
        ),
      );
  }

  // Function to show portfolio details in a dialog
  // 다이얼로그를 표시하는 함수
  void _showPortfolioDetailDialog(BuildContext context, PortfolioItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: [
                Row(
                  children: [
                    Text("아이디"),
                    IconButton(onPressed: (){}, icon: Icon(Icons.favorite))
                  ],
                ),
                SizedBox(height: 10),
                Text("IT 프로그래밍 > 홈페이지"),
                SizedBox(height: 10),
                Text(
                  '포트폴리오 제목',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                SizedBox(height: 10),
                Image.asset(
                  item.thumbnailUrl,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                Wrap(
                  children: [
                    Text('#카페로고'),
                    Text('#카페브랜딩'),
                    Text('#로고제작'),
                    Text('#로고디자인'),
                    Text('#카페'),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  '프로젝트 설명',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text('어디어디서 작업했음', style: TextStyle(color: Colors.black54)),
                Text("링크 : www.naver.com"),
                SizedBox(height: 20),
                Text('참여 기간', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('2023년 02월 ~ 2023년 02월'),
                SizedBox(height: 20),
                Text('클라이언트', style: TextStyle(fontWeight: FontWeight.bold)),
                Text("네이버"),
                SizedBox(height: 20),
                Text('적용기술 및 작업범위', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('디자인'),
                Text("- 기술"),
                Row(
                  children: [
                    Text("Photoshop"),
                    Text("illustrator"),
                    Text("Figma")
                  ],
                ),
                SizedBox(height: 20),
                Text('프론트엔드'),
                Text('- 언어'),
                Row(
                  children: [
                    Text("HTML5"),
                    Text("CSS3"),
                    Text("JavaScript"),
                    Text("jQuery")
                  ],
                ),
                SizedBox(height: 20),
                Text('백엔드'),
                Text('- 언어'),
                Text("PHP"),
                SizedBox(height: 10),
                Text("- DB"),
                Text("MySql"),
                Text("MariaDB"),
              ],
            ),
          ),
        );
      },
    );
  }
}
