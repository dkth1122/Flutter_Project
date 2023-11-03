import 'package:flutter/material.dart';
import 'package:project_flutter/expert/addPortfolio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_flutter/expert/portfolioDetail.dart';
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
  final CollectionReference expertCollection = FirebaseFirestore.instance.collection('expert');
  late List<PortfolioItem> portfolioItems = [];
  String user = "";
  late PortfolioItem item;

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
      QuerySnapshot expertSnapshot = await expertCollection.get();

      for (QueryDocumentSnapshot expertDoc in expertSnapshot.docs) {
        QuerySnapshot portfolioSnapshot = await expertDoc.reference.collection('portfolio').get();

        for (QueryDocumentSnapshot portfolioDoc in portfolioSnapshot.docs) {
          Map<String, dynamic> data = portfolioDoc.data() as Map<String, dynamic>;

          // 필수 필드의 존재 여부를 확인하고 처리
          if (data['title'] != null && data['description'] != null && data['thumbnailUrl'] != null) {
            item = PortfolioItem(
              portfolioDoc.id,
              data['title'],
              data['description'],
              data['thumbnailUrl'],
            );
            setState(() {
              portfolioItems.add(item);
            });
          } else {
            print('포트폴리오 항목 데이터가 올바르지 않습니다.');
          }
        }
      }
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PortfolioDetailPage(portfolioItem : item, user: user),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }



}
