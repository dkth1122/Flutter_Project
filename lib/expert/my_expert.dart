import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: MyPageScreen(),
  ));
}

class MyPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지'),
        backgroundColor: Color(0xFF00C695), // 초록색
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // 흰색 폰트
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.notifications, color: Colors.white), // 알림 아이콘
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.settings, color: Colors.white), // 설정 아이콘
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 프로필 정보 섹션
            Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/dog4.png'),
                      radius: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '사용자 닉네임',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '사용자 등급',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey, // 회색 텍스트
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 보낸 제안 섹션
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.ad_units), // 아이콘 추가
                    title: Text(
                      '광고 관리',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.add), // 아이콘 추가
                    title: Text(
                      '광고 신청',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.beach_access), // 아이콘 추가
                    title: Text(
                      '휴가 설정',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.star), // 아이콘 추가
                    title: Text(
                      '나의 전문가 등급',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.portrait), // 아이콘 추가
                    title: Text(
                      '나의 포트폴리오',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.message), // 아이콘 추가
                    title: Text(
                      '메시지 응답 관리',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
