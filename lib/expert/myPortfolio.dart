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
  final String category;

  PortfolioItem(this.id, this.title, this.description, this.thumbnailUrl, this.category);
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
  bool isLoading = true;

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

  //포트폴리오 출력
  Future<void> fetchPortfolioItems() async {
    try {
      QuerySnapshot expertSnapshot = await expertCollection.where('userId', isEqualTo: user).get();
      List<PortfolioItem> loadedItems = [];

      for (QueryDocumentSnapshot expertDoc in expertSnapshot.docs) {
        QuerySnapshot portfolioSnapshot = await expertDoc.reference.collection('portfolio').get();

        for (QueryDocumentSnapshot portfolioDoc in portfolioSnapshot.docs) {
          Map<String, dynamic> data = portfolioDoc.data() as Map<String, dynamic>;

          // 필수 필드의 존재 여부를 확인하고 처리
          if (data['title'] != null && data['description'] != null && data['thumbnailUrl'] != null && data['category'] != null) {
            item = PortfolioItem(
              portfolioDoc.id,
              data['title'],
              data['description'],
              data['thumbnailUrl'],
              data['category'],
            );
            loadedItems.add(item);
          } else {
            print('포트폴리오 항목 데이터가 올바르지 않습니다.');
          }
        }
      }

      setState(() {
        portfolioItems = loadedItems;
        isLoading = false;
      });
    } catch (e) {
      print('포트폴리오 항목 가져오기 오류: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 포트폴리오 삭제 기능
  Future<void> deletePortfolio(String title) async {
    try {
      final expertDoc = await expertCollection.doc(user).get();
      final portfolioRef = expertDoc.reference.collection('portfolio');

      await portfolioRef.where('title', isEqualTo: title).get().then((value) {
        for (var doc in value.docs) {
          doc.reference.delete();
        }
      });

      // 포트폴리오 삭제 후 목록을 업데이트
      fetchPortfolioItems();
    } catch (e) {
      print('포트폴리오 삭제 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '나의 포트폴리오',
          style: TextStyle(color: Color(0xff424242), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xff424242),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFFFF8C42),),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddPortfolio()));
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(), // 로딩 스피너 표시
        )
            : portfolioItems.isEmpty
            ? Center(
          child: Text(
            '등록하신 포트폴리오가 없습니다.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )
            : ListView.builder(
          itemCount: portfolioItems.length,
          itemBuilder: (context, index) {
            final item = portfolioItems[index];
            return InkWell(
              onTap: () {
                print(user);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PortfolioDetailPage(portfolioItem: item, user: user),
                  ),
                );
              },
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    height: 100,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.6,
                        color: Color.fromRGBO(182, 182, 182, 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                item.thumbnailUrl,
                                width: 130,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  width: 110,
                                  child: Text(
                                    item.description.length > 20
                                        ? '${item.description.substring(0, 20)}...'
                                        : item.description,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '카테고리 : ${item.category}',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
