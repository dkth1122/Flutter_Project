import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyQuestionView extends StatefulWidget {
  final DocumentSnapshot document;
  MyQuestionView({required this.document});

  @override
  State<MyQuestionView> createState() => _MyQuestionViewState();
}

class _MyQuestionViewState extends State<MyQuestionView> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: Text("내 질문 보기"),),
      body: Column(
        children: [
          Text('작성일 : ${data['timestamp'].toDate().toString()}'),
          Text(
            '제목 : ${data['title']}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text( '내용 : ${data['content']}',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text( '운영자 답변', style: TextStyle(fontSize: 18,),
              ),
            ],
          ),
          Expanded(child: _listComments())

        ],
      ),
    );
  }
  Widget _listComments() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("question")
          .doc(widget.document.id)
          .collection("comments")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snap.data!.docs[index];
            Map<String, dynamic> commentData = doc.data() as Map<String, dynamic>;
            if (commentData['comments'] == null || commentData['timestamp'] == null) {
              return Container();
            }
            return ListTile(
              title: Text(commentData['comments']),
              subtitle: Text('작성일: ${commentData['timestamp'].toDate().toString()}'),
            );
          },
        );
      },
    );
  }
}
