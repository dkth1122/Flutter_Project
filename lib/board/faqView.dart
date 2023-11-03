import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FaqView extends StatefulWidget {
  final DocumentSnapshot document;
  FaqView({required this.document});


  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: Text("FAQ View"),),
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
