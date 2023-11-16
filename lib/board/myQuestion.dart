import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../firebase_options.dart';
import '../join/userModel.dart';
import '../subBottomBar.dart';
import 'myQuestionView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyQuestion());
}


class MyQuestion extends StatefulWidget {
  const MyQuestion({super.key});

  @override
  State<MyQuestion> createState() => _MyQuestionState();
}

class _MyQuestionState extends State<MyQuestion> {

  String sessionId = "";

  @override
  Widget build(BuildContext context) {
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
    } else {
      sessionId = "";
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '내 문의',
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
        child: ListView(
          children: [
            _myQuestion()
          ],
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
    );
  }
  Widget _myQuestion() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("question")
          .where('user', isEqualTo: sessionId)
          .snapshots(),
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
                    title: Text('작성일  : ${DateFormat('yyyy-MM-dd HH:mm:ss').format(data['timestamp'].toDate())}'),
                    subtitle: Text('${data['title']}'),
                    trailing: Text("답변 대기 중..."),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyQuestionView(document: doc),
                        ),
                      );
                    },
                  );
                } else {
                  // 추가: comments 컬렉션에 데이터가 있으면 답변완료로 표시
                  bool hasComments = commentsSnapshot.hasData &&
                      commentsSnapshot.data!.docs.isNotEmpty;

                  return ListTile(
                    title: Text('작성일  : ${DateFormat('yyyy-MM-dd HH:mm:ss').format(data['timestamp'].toDate())}'),
                    subtitle: Text('${data['title']}'),
                    trailing: hasComments ? Text("답변 완료") : Text("답변 대기 중..."),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyQuestionView(document: doc),
                        ),
                      );
                    },
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
