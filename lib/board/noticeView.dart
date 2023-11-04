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
      appBar: AppBar(title: Text("공지사항 View"),backgroundColor: Color(0xFFFF8C42),),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            Text(
              '${data['title']}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10,),
            Text('작성일 : ${data['timestamp'].toDate().toString()}'),
            SizedBox(height: 10,),
            Text('${data['content']}',
              style: TextStyle(
                fontSize: 18,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
