import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';

class PortfolioDetailPage extends StatefulWidget {
  final portfolioItem;
  final user;

  PortfolioDetailPage({required this.portfolioItem, required this.user});

  @override
  _PortfolioDetailPageState createState() => _PortfolioDetailPageState();
}

class _PortfolioDetailPageState extends State<PortfolioDetailPage> {
  late DocumentSnapshot? portfolioDoc;

  @override
  void initState() {
    super.initState();
    fetchPortfolioDetails();
  }

  Future<void> fetchPortfolioDetails() async {
    try {
      portfolioDoc = await FirebaseFirestore.instance
          .collection('expert')
          .doc(widget.user)
          .collection('portfolio')
          .doc(widget.portfolioItem.id)
          .get();
    } catch (e) {
      print('포트폴리오 디테일 가져오기 오류: $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (portfolioDoc == null) {
      return CircularProgressIndicator();
    }

    Map<String, dynamic>? data = portfolioDoc!.data() as Map<String, dynamic>?;

    if (data == null) {
      return Text('포트폴리오 데이터를 찾을 수 없습니다.');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('포트폴리오 디테일'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(data['thumbnailUrl'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? '제목 없음',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    data['description'] ?? '설명 없음',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '해시태그: ${data['hashtags']?.join(', ') ?? '없음'}',
                    style: TextStyle(color: Colors.blue),
                  ),
                  // 여기서 다른 정보를 추가하세요.
                ],
              ),
            ),
            // 서브 이미지들 출력
            for (String imageUrl in data['subImageUrls'] ?? []) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
