import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/myPage/myLikeService.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';
import '../search/searchPortfolioDetail.dart';
import '../test.dart';
import 'myLikePortfolio.dart';

class MyLike extends StatefulWidget {
  const MyLike({super.key});

  @override
  State<MyLike> createState() => _MyLikeState();
}

class _MyLikeState extends State<MyLike> {
  String sessionId = "";

  @override
  Widget build(BuildContext context) {
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
    } else {
      sessionId = "";
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '찜 목록',
            style: TextStyle(color:Color(0xff424242), fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 1.0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xff424242)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                text: '서비스',
              ),
              Tab(
                text: '포트폴리오',
              ),
            ],
            labelColor:Color(0xFFFF8C42), // 선택된 탭의 텍스트 컬러
            unselectedLabelColor: Color(0xff424242), // 선택되지 않은 탭의 텍스트 컬러
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFFF8C42), // 밑줄의 색상을 변경하려면 여기에서 지정
                  width: 3.0, // 밑줄의 두께를 조절할 수 있습니다.
                ),
              ),
            ),
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            ServiceView(),
            PortfolioView()
          ],
        ),
      ),
    );
  }
}
class ServiceView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.all(10),
          child: myLikeService()
      ),
    );
  }
}

class PortfolioView  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.all(10),
          child: myLikePortfolio()
      ),
    );
  }
}

class PortfolioList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("포트폴리오 목록이 비어 있습니다."),
    );
  }
}

class ServiceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("서비스 목록이 비어 있습니다."),
    );
  }
}