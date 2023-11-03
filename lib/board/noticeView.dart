import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoticeView extends StatefulWidget {
  final DocumentSnapshot document;
  NoticeView({required this.document});


  @override
  State<NoticeView> createState() => _NoticeViewState();
}

class _NoticeViewState extends State<NoticeView> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: Text("공지사항 View"),),
      body: ListView(
        children: [
          Text(
            '제목 : ${data['title']}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('작성일 : ${data['timestamp'].toDate().toString()}'),
          Text( '내용 : ${data['content']}',
            style: TextStyle(
              fontSize: 18,
            ),
          ),

        ],
      ),
    );
  }
}
