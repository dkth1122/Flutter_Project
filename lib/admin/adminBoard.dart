import 'package:flutter/material.dart';

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
        backgroundColor: Color(0xff328772),
      ),
      body: Center(
      ),
    );
  }
}