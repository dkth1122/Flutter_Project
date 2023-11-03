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
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '제목 : ${data['title']}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('작성일 : ${data['timestamp'].toDate().toString()}'),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Text( '내용 : ${data['content']}',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50,),
            SizedBox(height: 10,),
            Expanded(child: _listComments())

          ],
        ),
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
            return Column(
              children:[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text( '운영자 답변', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    Text('작성일: ${commentData['timestamp'].toDate().toString()}'),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Text(
                      commentData['comments'],
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ]
            );
          },
        );
      },
    );
  }
}
