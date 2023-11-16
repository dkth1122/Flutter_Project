import 'package:flutter/material.dart';
import 'package:project_flutter/board/faq.dart';
import 'package:project_flutter/board/notice.dart';
import 'package:project_flutter/subBottomBar.dart';

import '../board/questionAnswer.dart';

class AdminBoard extends StatefulWidget {

  @override
  State<AdminBoard> createState() => _AdminBoardState();
}

class _AdminBoardState extends State<AdminBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "게시판 관리",
            style: TextStyle(
              color: Color(0xff424242),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Color(0xff424242),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notice()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFFF8C42),
              ),
              child: Text('공지사항 등록하기'),
            ),
            SizedBox(width: 10,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Faq()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFFF8C42),
              ),
              child: Text('FAQ 등록하기'),
            ),
            SizedBox(width: 10,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuestionAnswer()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFFF8C42),
              ),
              child: Text('1:1문의 답변하기'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
    );
  }
}