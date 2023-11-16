import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/board/questionAnswerView.dart';

class QuestionAnswer extends StatefulWidget {
  const QuestionAnswer({super.key});

  @override
  State<QuestionAnswer> createState() => _QuestionAnswerState();
}

class _QuestionAnswerState extends State<QuestionAnswer> {
  final Stream<QuerySnapshot> questionStream = FirebaseFirestore.instance.collection("question").orderBy("timestamp", descending: true).snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '1:1 문의 답변하기',
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
      body: ListView(
        children: [
          _questionAnswer()
        ],
      ),
    );
  }
  Widget _questionAnswer() {
    return StreamBuilder(
      stream: questionStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Transform.scale(
            scale: 0.1,
            child: CircularProgressIndicator(strokeWidth: 20,),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snap.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            // 추가: 해당 문서의 comments 컬렉션에 대한 쿼리
            CollectionReference commentsCollection =
            FirebaseFirestore.instance.collection("question").doc(doc.id).collection("comments");

            return FutureBuilder(
              future: commentsCollection.get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> commentsSnapshot) {
                if (commentsSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text('${data['title']}'),
                    subtitle: Text("작성자 : ${data['user']}"),
                    trailing: Text("답변 대기 중..."),
                  );
                } else {
                  // 추가: comments 컬렉션에 데이터가 있으면 답변완료로 표시
                  bool hasComments = commentsSnapshot.hasData &&
                      commentsSnapshot.data!.docs.isNotEmpty;

                  return ListTile(
                    title: Text('${data['title']}'),
                    subtitle: Text("작성자 : ${data['user']}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionAnswerView(document: doc),
                        ),
                      );
                    },
                    trailing: hasComments ? Text("답변완료") : Text("답변 대기 중..."),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
