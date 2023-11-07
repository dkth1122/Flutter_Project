import 'package:flutter/material.dart';
import 'package:project_flutter/board/faq.dart';
import 'package:project_flutter/board/notice.dart';

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
        title: Text('게시판 관리'),
        backgroundColor: Color(0xFF4E598C),
      ),
      body: Row(
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
              primary: Color(0xFF4E598C),
            ),
            child: Text('공지사항 등록하기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Faq()),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF4E598C),
            ),
            child: Text('FAQ 등록하기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuestionAnswer()),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF4E598C),
            ),
            child: Text('1:1문의 답변하기'),
          ),
        ],
      )
    );
  }
}