import 'package:flutter/material.dart';
import 'package:project_flutter/expert/addPortfolio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';

class PortfolioItem {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;

  PortfolioItem(this.id, this.title, this.description, this.thumbnailUrl);
}

class Portfolio extends StatefulWidget {
  @override
  _PortfolioState createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  final CollectionReference portfolioCollection = FirebaseFirestore.instance.collection('expert');
  late List<PortfolioItem> portfolioItems = [];
  String user = "";

  @override
  void initState() {
    super.initState();
    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      user = um.userId!;
      print(user);
    } else {
      user = "없음";
      print("로그인 안됨");
    }
    // Firestore에서 포트폴리오 항목을 가져오는 메서드를 호출
    fetchPortfolioItems();
  }

  Future<void> fetchPortfolioItems() async {
    try {
      QuerySnapshot portfolioSnapshot = await portfolioCollection.get();
      List<PortfolioItem> items = portfolioSnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        return PortfolioItem(
          document.id, // 문서 ID를 사용하여 각 포트폴리오 항목을 고유하게 식별
          data['title'],
          data['description'],
          data['thumbnailUrl'],
        );
      }).toList();
      setState(() {
        portfolioItems = items;
      });
    } catch (e) {
      print('포트폴리오 항목 가져오기 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('포트폴리오'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
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
              leading: Image.network(
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

  void _showPortfolioDetailDialog(BuildContext context, PortfolioItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: [
                // 상세 정보를 표시하는 내용 추가
                Text('포트폴리오 ID: ${item.id}'),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text('아이디'),
                    IconButton(
                      onPressed: () {
                        // 즐겨찾기 버튼을 눌렀을 때의 동작 추가
                      },
                      icon: Icon(Icons.favorite),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Text('카테고리: IT 프로그래밍 > 홈페이지'),
                SizedBox(height: 10),
                Text(
                  '포트폴리오 제목: ${item.title}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                // 나머지 포트폴리오 항목 상세 정보를 여기에 추가
              ],
            ),
          ),
        );
      },
    );
  }
}
