import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../subBottomBar.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '내 질문 보기',
          style: TextStyle(
            color: Color(0xff424242),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xff424242),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 250,
                  child: Text(
                    '제목 : ${data['title']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${DateFormat('yyyy-MM-dd').format(data['timestamp'].toDate())}',),
                      Text('${DateFormat('HH:mm:ss').format(data['timestamp'].toDate())}',),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '내용 : ${data['content']}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    maxLines: null, // 텍스트가 여러 줄로 나뉘지 않도록 설정합니다.
                  ),
                ),

              ],
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                // 질문 컬렉션 삭제
                FirebaseFirestore.instance
                    .collection("question")
                    .doc(widget.document.id)
                    .delete()
                    .then((value) {
                  print("질문 삭제 성공");
                  // 해당 질문의 댓글 컬렉션 삭제
                  FirebaseFirestore.instance
                      .collection("question")
                      .doc(widget.document.id)
                      .collection("comments")
                      .get()
                      .then((querySnapshot) {
                    querySnapshot.docs.forEach((doc) {
                      doc.reference.delete();
                    });
                    print("댓글 컬렉션 삭제 성공");
                  }).catchError((error) {
                    print("댓글 컬렉션 삭제 오류: $error");
                  });
                }).catchError((error) {
                  print("질문 삭제 오류: $error");
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFFF8C42), // 원하는 색상으로 변경
              ),
              child: Text("질문 삭제하기"),
            ),


            SizedBox(height: 50,),
            Row(
              children: [
                Text( '운영자 답변', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 10,),
            Expanded(child: _listComments())

          ],
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
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

        if (snap.data!.docs.isEmpty) {
          // 데이터가 없을 때 '아직 답변이 없습니다.' 메시지를 반환
          return Container(child: Text('아직 답변이 없습니다.'));
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
                      Container(
                        width: 250,
                        child: Text(
                          commentData['comments'],
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${DateFormat('yyyy-MM-dd').format(commentData['timestamp'].toDate())}',),
                            Text('${DateFormat('HH:mm:ss').format(commentData['timestamp'].toDate())}',),
                          ],
                        ),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start, // 수직 정렬을 최상단으로 조정합니다.
                  ),

                  SizedBox(height: 20,),
                ]
            );
          },
        );
      },
    );
  }

}
