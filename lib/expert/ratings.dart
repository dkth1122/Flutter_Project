import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../join/userModel.dart';

class ExpertRatingData {
  final String level;
  final String conditions;
  final String duration;

  ExpertRatingData({
    required this.level,
    required this.conditions,
    required this.duration,
  });
}

List<ExpertRatingData> expertRatingData = [
  ExpertRatingData(
    level: 'New',
    conditions: '신규 전문가 / 등급 조건 미충족 전문가',
    duration: '30일',
  ),
  ExpertRatingData(
    level: 'LEVEL 1',
    conditions: '1건 이상 or 5,000원 이상',
    duration: '30일',
  ),
  ExpertRatingData(
    level: 'LEVEL 2',
    conditions: '15건 이상 or 500만 원 이상',
    duration: '60일',
  ),
  ExpertRatingData(
    level: 'LEVEL 3',
    conditions: '100건 이상 or 2,000만 원 이상',
    duration: '90일',
  ),
  ExpertRatingData(
    level: 'MASTER',
    conditions: '300건 이상 or 8,000만 원 이상',
    duration: '90일',
  ),
];

class ExpertRating extends StatefulWidget {
  @override
  _ExpertRatingState createState() => _ExpertRatingState();
}

class _ExpertRatingState extends State<ExpertRating> {
  String user = '';
  String expertRating = 'New'; // 기본 등급
  int documentCount = 0;
  num totalAmount = 0;

  @override
  void initState() {
    super.initState();
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      user = um.userId!;
      calculateExpertRating(user).then((rating) {
        setState(() {
          expertRating = rating;
        });
      });
    } else {
      user = '없음';
      print('로그인 X');
    }
  }

  Future<String> calculateExpertRating(String userId) async {
    // Firebase.initializeApp()를 호출하지 않고 이미 초기화되었다고 가정하고 진행
    final firestore = FirebaseFirestore.instance;

    // Calculate the total order amount for the user
    QuerySnapshot querySnapshot = await firestore
        .collection('orders')
        .where('seller', isEqualTo: userId)
        .get();

    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      totalAmount += document['price'];
    }

    //문서가 총 몇개 있는지
    documentCount = querySnapshot.size;

    // Determine the expert rating based on the total order amount
    String rating = 'New 🌱';

    if (documentCount >= 1 || totalAmount >= 5000) {
      setState(() {
        rating = 'LEVEL 1 🍀';
      });
    }

    if (documentCount >= 15 || totalAmount >= 5000000) {
      setState(() {
        rating = 'LEVEL 2 🌷';
      });
    }

    if (documentCount >= 100 || totalAmount >= 20000000) {
      setState(() {
        rating = 'LEVEL 3 🌺';
      });
    }

    if (documentCount >= 300 || totalAmount >= 80000000) {
      setState(() {
        rating = 'MASTER 💐';
      });
    }

    DocumentReference userDocumentRef = firestore.collection('rating').doc(userId);

    if (userDocumentRef != null) {
      // 이미 해당 사용자의 문서가 존재하는 경우, "set"을 사용하여 업데이트
      userDocumentRef.set({
        'user': userId,
        'rating': rating,
      });
    } else {
      // 해당 사용자의 문서가 없는 경우, "add"를 사용하여 새로운 문서 추가
      firestore.collection('rating').add({
        'user': userId,
        'rating': rating,
      });
    }
    return rating;
  }

  @override
  Widget build(BuildContext context) {
    String formattedTotalAmount = NumberFormat('#,###').format(totalAmount);
    String displayTotalAmount = totalAmount >= 10000
        ? '${formattedTotalAmount[0]}만'
        : formattedTotalAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text('전문가 등급', style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFFFCAF58),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.amber, // 배경색 설정
                  borderRadius: BorderRadius.circular(16.0), // 네모 모양 및 모서리 둥글게 설정
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$user',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // 글자 색상 설정
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '전문가 등급: $expertRating',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold// 글자 색상 설정
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 아이콘과 텍스트를 가운데 정렬
                      children: [
                        Icon(Icons.shopping_bag, size: 16, color: Colors.blue), // 판매건수 아이콘
                        SizedBox(width: 3), // 아이콘과 텍스트 간 간격 조절
                        Text('판매건수: $documentCount', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        SizedBox(width: 12),
                        Icon(Icons.money, size: 16, color: Colors.green), // 판매금액 아이콘
                        SizedBox(width: 3), // 아이콘과 텍스트 간 간격 조절
                        Text('판매금액: $displayTotalAmount', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Text(
                    '등급별 조건',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: expertRatingData.length,
              itemBuilder: (context, index) {
                final data = expertRatingData[index];
                return Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue, // 배경색 설정
                    borderRadius: BorderRadius.circular(16.0), // 네모 모양 및 모서리 둥글게 설정
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '등급: ${data.level}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white, // 글자 색상 설정
                        ),
                      ),
                      Text(
                        '조건: ${data.conditions}',
                        style: TextStyle(
                          color: Colors.white, // 글자 색상 설정
                        ),
                      ),
                      // 나머지 등급별 조건에 따른 내용 추가
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
