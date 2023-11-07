import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../join/userModel.dart';

class ExpertRatingData {
  final String level;
  final String conditions;
  final String duration;
  final double satisfaction;
  final int responseRate;
  final int orderSuccessRate;
  final int complianceRate;

  ExpertRatingData({
    required this.level,
    required this.conditions,
    required this.duration,
    required this.satisfaction,
    required this.responseRate,
    required this.orderSuccessRate,
    required this.complianceRate,
  });
}

List<ExpertRatingData> expertRatingData = [
  ExpertRatingData(
    level: 'New',
    conditions: '신규 전문가 / 등급 조건 미충족 전문가',
    duration: '30일',
    satisfaction: 4.7,
    responseRate: 90,
    orderSuccessRate: 85,
    complianceRate: 85,
  ),
  ExpertRatingData(
    level: 'LEVEL 1',
    conditions: '1건 이상 or 5,000원 이상',
    duration: '30일',
    satisfaction: 4.7,
    responseRate: 90,
    orderSuccessRate: 85,
    complianceRate: 85,
  ),
  ExpertRatingData(
    level: 'LEVEL 2',
    conditions: '15건 이상 or 500만 원 이상',
    duration: '60일',
    satisfaction: 4.7,
    responseRate: 90,
    orderSuccessRate: 85,
    complianceRate: 85,
  ),
  ExpertRatingData(
    level: 'LEVEL 3',
    conditions: '100건 이상 or 2,000만 원 이상',
    duration: '90일',
    satisfaction: 4.7,
    responseRate: 90,
    orderSuccessRate: 85,
    complianceRate: 85,
  ),
  ExpertRatingData(
    level: 'MASTER',
    conditions: '300건 이상 or 8,000만 원 이상',
    duration: '90일',
    satisfaction: 4.7,
    responseRate: 90,
    orderSuccessRate: 85,
    complianceRate: 85,
  ),
];

class ExpertRating extends StatefulWidget {
  @override
  _ExpertRatingState createState() => _ExpertRatingState();
}

class _ExpertRatingState extends State<ExpertRating> {
  String user = '';
  String expertRating = 'New'; // Default expert rating

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
      print('로그인X');
    }
  }

  Future<String> calculateExpertRating(String userId) async {
    // Firebase.initializeApp()를 호출하지 않고 이미 초기화되었다고 가정하고 진행합니다.
    final firestore = FirebaseFirestore.instance;

    // Calculate the total order amount for the user
    QuerySnapshot querySnapshot = await firestore
        .collection('orders')
        .where('seller', isEqualTo: userId)
        .get();

    num totalAmount = 0;
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      totalAmount += document['price'];
    }

    int documentCount = querySnapshot.size;

    print("문서 갯수 ===> $documentCount");
    print("총 금액 ===> $totalAmount");

    // Determine the expert rating based on the total order amount
    String rating = 'New';

    if (documentCount >= 1 || totalAmount >= 5000) {
      setState(() {
        rating = 'LEVEL 1';
      });
    }

    if (documentCount >= 15 || totalAmount >= 5000000) {
      setState(() {
        rating = 'LEVEL 2';
      });
    }

    if (documentCount >= 100 || totalAmount >= 20000000) {
      setState(() {
        rating = 'LEVEL 3';
      });
    }

    if (documentCount >= 300 || totalAmount >= 80000000) {
      setState(() {
        rating = 'MASTER';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('전문가 등급'),
        backgroundColor: Color(0xFFFCAF58),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$user',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '전문가 등급: $expertRating',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
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
                return ListTile(
                  title: Text('등급: ${data.level}'),
                  subtitle: Text('조건: ${data.conditions}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
