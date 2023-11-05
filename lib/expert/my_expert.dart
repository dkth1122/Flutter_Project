import 'package:flutter/material.dart';
import 'package:project_flutter/expert/ratings.dart';
import 'package:project_flutter/expert/revenue.dart';
import 'package:project_flutter/expert/vacation.dart';

import '../myPage/customerLike.dart';
import 'adManagement.dart';
import 'adRequest.dart';
import 'messageResponse.dart';

class MyExpert extends StatefulWidget {
  @override
  State<MyExpert> createState() => _MyExpertState();
}

class _MyExpertState extends State<MyExpert> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '보낸 제안',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // 작업 가능한 프로젝트 목록
                // 프로젝트 보러가기 버튼
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
            thickness: 5.0,
          ),

          // 판매 정보 섹션
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '판매 정보',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '3개월 이내 판매중인 건수:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '50',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // 파란색 텍스트
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
            thickness: 5.0,
          ),
          // 나의 서비스 섹션
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '나의 서비스',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  leading: Icon(Icons.monetization_on), // 아이콘 추가
                  title: Text(
                    '수익 관리',
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => Revenue()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.beach_access), // 아이콘 추가
                  title: Text(
                    '휴가 설정',
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => Vacation()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.star), // 아이콘 추가
                  title: Text(
                    '나의 전문가 등급',
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ExpertRating()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.portrait), // 아이콘 추가
                  title: Text(
                    '나의 포트폴리오',
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => Portfolio()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.message), // 아이콘 추가
                  title: Text(
                    '메시지 응답 관리',
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => MessageResponse()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
